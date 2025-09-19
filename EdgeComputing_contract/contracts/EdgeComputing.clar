
;; title: EdgeComputing
;; version: 1.0.0
;; summary: Synthetic assets smart contract for edge computing and 5G infrastructure investments
;; description: This contract implements a synthetic asset system that tracks edge computing
;;              and 5G infrastructure investments, allowing users to mint, burn, and trade
;;              synthetic tokens backed by real-world infrastructure performance metrics.

;; imports
(impl-trait .sip-010-trait.sip-010-trait)

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-oracle-not-found (err u104))
(define-constant err-price-stale (err u105))
(define-constant err-investment-not-found (err u106))

;; token definitions
(define-fungible-token edge-computing-token)

;; data vars
(define-data-var token-name (string-ascii 32) "EdgeComputing Token")
(define-data-var token-symbol (string-ascii 10) "EDGE")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var token-decimals uint u8)
(define-data-var total-supply uint u0)
(define-data-var contract-paused bool false)
(define-data-var oracle-update-interval uint u86400) ;; 24 hours in seconds

;; data maps
(define-map token-balances principal uint)
(define-map allowed-minters principal bool)
(define-map price-oracles
  {infrastructure-type: (string-ascii 50)}
  {price: uint, last-updated: uint, data-source: principal})
(define-map infrastructure-investments
  {investment-id: uint}
  {investor: principal, amount: uint, infrastructure-type: (string-ascii 50),
   timestamp: uint, performance-multiplier: uint})
(define-map investment-counter principal uint)

;; SIP-010 Functions

;; Transfer function
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (not (var-get contract-paused)) (err u999))
    (asserts! (is-eq from tx-sender) err-not-token-owner)
    (asserts! (>= (ft-get-balance edge-computing-token from) amount) err-insufficient-balance)
    (try! (ft-transfer? edge-computing-token amount from to))
    (match memo to-print (print to-print) 0x)
    (ok true)))

;; Get name
(define-read-only (get-name)
  (ok (var-get token-name)))

;; Get symbol
(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

;; Get decimals
(define-read-only (get-decimals)
  (ok (var-get token-decimals)))

;; Get balance
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance edge-computing-token who)))

;; Get total supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply edge-computing-token)))

;; Get token URI
(define-read-only (get-token-uri)
  (ok (var-get token-uri)))

;; EdgeComputing-specific Functions

;; Mint synthetic tokens based on infrastructure investment
(define-public (mint-synthetic-tokens (amount uint) (infrastructure-type (string-ascii 50)))
  (let (
    (oracle-data (unwrap! (map-get? price-oracles {infrastructure-type: infrastructure-type}) err-oracle-not-found))
    (current-price (get price oracle-data))
    (last-updated (get last-updated oracle-data))
    (investment-id (+ (default-to u0 (map-get? investment-counter tx-sender)) u1))
  )
    (asserts! (not (var-get contract-paused)) (err u999))
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (< (- block-height last-updated) (var-get oracle-update-interval)) err-price-stale)

    ;; Calculate synthetic tokens to mint based on current infrastructure price
    (let ((tokens-to-mint (/ (* amount current-price) u1000000))) ;; Normalize price
      (try! (ft-mint? edge-computing-token tokens-to-mint tx-sender))
      (map-set infrastructure-investments
        {investment-id: investment-id}
        {investor: tx-sender,
         amount: amount,
         infrastructure-type: infrastructure-type,
         timestamp: block-height,
         performance-multiplier: u100}) ;; 100 = 1.0x multiplier
      (map-set investment-counter tx-sender investment-id)
      (var-set total-supply (+ (var-get total-supply) tokens-to-mint))
      (ok tokens-to-mint))))

;; Burn synthetic tokens and redeem investment
(define-public (burn-synthetic-tokens (amount uint) (investment-id uint))
  (let (
    (investment-data (unwrap! (map-get? infrastructure-investments {investment-id: investment-id}) err-investment-not-found))
    (investor (get investor investment-data))
    (infrastructure-type (get infrastructure-type investment-data))
    (oracle-data (unwrap! (map-get? price-oracles {infrastructure-type: infrastructure-type}) err-oracle-not-found))
    (current-price (get price oracle-data))
    (performance-multiplier (get performance-multiplier investment-data))
  )
    (asserts! (not (var-get contract-paused)) (err u999))
    (asserts! (is-eq investor tx-sender) err-not-token-owner)
    (asserts! (>= (ft-get-balance edge-computing-token tx-sender) amount) err-insufficient-balance)

    ;; Calculate redemption value with performance multiplier
    (let ((redemption-value (/ (* (* amount current-price) performance-multiplier) u100000000)))
      (try! (ft-burn? edge-computing-token amount tx-sender))
      (var-set total-supply (- (var-get total-supply) amount))
      (ok redemption-value))))

;; Update price oracle (only contract owner or authorized oracles)
(define-public (update-price-oracle (infrastructure-type (string-ascii 50)) (price uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> price u0) err-invalid-amount)
    (map-set price-oracles
      {infrastructure-type: infrastructure-type}
      {price: price, last-updated: block-height, data-source: tx-sender})
    (ok true)))

;; Update performance multiplier for an investment
(define-public (update-performance-multiplier (investment-id uint) (new-multiplier uint))
  (let (
    (investment-data (unwrap! (map-get? infrastructure-investments {investment-id: investment-id}) err-investment-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-multiplier u0) err-invalid-amount)
    (map-set infrastructure-investments
      {investment-id: investment-id}
      (merge investment-data {performance-multiplier: new-multiplier}))
    (ok true)))

;; Add authorized minter
(define-public (add-minter (minter principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set allowed-minters minter true)
    (ok true)))

;; Remove authorized minter
(define-public (remove-minter (minter principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-delete allowed-minters minter)
    (ok true)))

;; Pause/unpause contract
(define-public (set-contract-pause (paused bool))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused paused)
    (ok true)))

;; read only functions

;; Get price oracle data
(define-read-only (get-price-oracle (infrastructure-type (string-ascii 50)))
  (map-get? price-oracles {infrastructure-type: infrastructure-type}))

;; Get investment data
(define-read-only (get-investment-data (investment-id uint))
  (map-get? infrastructure-investments {investment-id: investment-id}))

;; Check if minter is authorized
(define-read-only (is-authorized-minter (minter principal))
  (default-to false (map-get? allowed-minters minter)))

;; Get contract status
(define-read-only (get-contract-status)
  {
    paused: (var-get contract-paused),
    total-supply: (var-get total-supply),
    oracle-update-interval: (var-get oracle-update-interval)
  })

;; Calculate potential return for investment
(define-read-only (calculate-investment-return (amount uint) (infrastructure-type (string-ascii 50)))
  (match (map-get? price-oracles {infrastructure-type: infrastructure-type})
    oracle-data
    (let (
      (current-price (get price oracle-data))
      (synthetic-tokens (/ (* amount current-price) u1000000))
    )
      (ok {synthetic-tokens: synthetic-tokens, current-price: current-price}))
    (err err-oracle-not-found)))

;; private functions

;; Initialize default price oracles (called during deployment)
(define-private (initialize-oracles)
  (begin
    (map-set price-oracles
      {infrastructure-type: "edge-computing"}
      {price: u1000000, last-updated: block-height, data-source: contract-owner})
    (map-set price-oracles
      {infrastructure-type: "5g-infrastructure"}
      {price: u1500000, last-updated: block-height, data-source: contract-owner})
    (map-set price-oracles
      {infrastructure-type: "iot-networks"}
      {price: u800000, last-updated: block-height, data-source: contract-owner})
    true))

;; Initialize contract
(initialize-oracles)
