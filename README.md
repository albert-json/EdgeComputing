# EdgeComputing Smart Contract

EdgeComputing is a synthetic assets smart contract that tracks edge computing and 5G infrastructure investments on the Stacks blockchain. This contract allows users to mint synthetic tokens backed by real-world infrastructure performance metrics, providing exposure to the growing edge computing and telecommunications infrastructure market.

## Features

- **Synthetic Asset Minting**: Mint EDGE tokens based on infrastructure investment amounts and current market prices
- **Multi-Infrastructure Support**: Support for edge computing, 5G infrastructure, and IoT networks
- **Oracle-Based Pricing**: Real-time price feeds for accurate asset valuation
- **Performance Tracking**: Dynamic performance multipliers that affect token redemption values
- **SIP-010 Compliance**: Full compatibility with Stacks fungible token standard
- **Access Control**: Owner-controlled functions for minter authorization and price oracle updates
- **Investment Tracking**: Comprehensive tracking of individual investments with unique IDs
- **Pausable Contract**: Emergency pause functionality for security

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity 2
- **Token Standard**: SIP-010
- **Token Symbol**: EDGE
- **Decimals**: 8
- **Contract Version**: 1.0.0

### Supported Infrastructure Types

- `edge-computing`: Edge computing infrastructure investments
- `5g-infrastructure`: 5G network infrastructure investments
- `iot-networks`: IoT network infrastructure investments

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) (v16 or higher)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd EdgeComputing
```

2. Install dependencies:
```bash
cd EdgeComputing_contract
npm install
```

3. Run tests:
```bash
npm run test
```

4. Start local development environment:
```bash
clarinet console
```

## Usage Examples

### Basic Token Operations

```clarity
;; Get token balance
(contract-call? .EdgeComputing get-balance 'SP1234567890ABCDEF)

;; Transfer tokens
(contract-call? .EdgeComputing transfer u1000 tx-sender 'SP1234567890ABCDEF none)

;; Get total supply
(contract-call? .EdgeComputing get-total-supply)
```

### Infrastructure Investment

```clarity
;; Mint synthetic tokens based on edge computing investment
(contract-call? .EdgeComputing mint-synthetic-tokens u10000 "edge-computing")

;; Calculate potential returns before investing
(contract-call? .EdgeComputing calculate-investment-return u10000 "5g-infrastructure")

;; Burn tokens and redeem investment
(contract-call? .EdgeComputing burn-synthetic-tokens u1000 u1)
```

### Oracle and Price Management (Owner Only)

```clarity
;; Update price oracle for edge computing infrastructure
(contract-call? .EdgeComputing update-price-oracle "edge-computing" u1200000)

;; Update performance multiplier for an investment
(contract-call? .EdgeComputing update-performance-multiplier u1 u150)

;; Get current price oracle data
(contract-call? .EdgeComputing get-price-oracle "edge-computing")
```

## Contract Functions Documentation

### SIP-010 Standard Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `transfer` | Transfer tokens between accounts | `amount`, `from`, `to`, `memo` |
| `get-name` | Get token name | None |
| `get-symbol` | Get token symbol | None |
| `get-decimals` | Get token decimals | None |
| `get-balance` | Get account balance | `who` |
| `get-total-supply` | Get total token supply | None |
| `get-token-uri` | Get token metadata URI | None |

### EdgeComputing-Specific Functions

#### Public Functions

| Function | Description | Access |
|----------|-------------|---------|
| `mint-synthetic-tokens` | Mint tokens based on infrastructure investment | All users |
| `burn-synthetic-tokens` | Burn tokens and redeem investment | Token holders |
| `update-price-oracle` | Update price data for infrastructure type | Owner only |
| `update-performance-multiplier` | Update investment performance multiplier | Owner only |
| `add-minter` | Authorize new minter | Owner only |
| `remove-minter` | Remove minter authorization | Owner only |
| `set-contract-pause` | Pause/unpause contract operations | Owner only |

#### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-price-oracle` | Get price oracle data for infrastructure type | Oracle data record |
| `get-investment-data` | Get investment details by ID | Investment record |
| `is-authorized-minter` | Check if principal is authorized minter | Boolean |
| `get-contract-status` | Get contract pause status and metrics | Status record |
| `calculate-investment-return` | Calculate potential returns for investment | Calculation result |

### Error Codes

| Code | Description |
|------|-------------|
| `u100` | Owner only operation |
| `u101` | Not token owner |
| `u102` | Insufficient balance |
| `u103` | Invalid amount |
| `u104` | Oracle not found |
| `u105` | Price data stale |
| `u106` | Investment not found |
| `u999` | Contract paused |

## Deployment Guide

### Local Deployment (Devnet)

1. Start Clarinet console:
```bash
clarinet console
```

2. Deploy the contract:
```clarity
::deploy_contracts
```

3. Interact with the contract:
```clarity
(contract-call? .EdgeComputing get-contract-status)
```

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`

2. Deploy to testnet:
```bash
clarinet deployments generate --testnet
clarinet deployments apply -p testnet
```

### Mainnet Deployment

1. Configure mainnet settings in `settings/Mainnet.toml`

2. Deploy to mainnet:
```bash
clarinet deployments generate --mainnet
clarinet deployments apply -p mainnet
```

## Security Notes

### Important Security Considerations

1. **Oracle Dependency**: The contract relies on price oracles for accurate valuations. Ensure oracle data sources are trusted and regularly updated.

2. **Owner Privileges**: The contract owner has significant control including:
   - Price oracle updates
   - Performance multiplier modifications
   - Contract pause functionality
   - Minter authorization

3. **Price Staleness**: The contract includes protection against stale price data with a 24-hour update requirement.

4. **Access Control**: Critical functions are protected by owner-only access controls.

### Best Practices

- Regularly monitor oracle updates and price accuracy
- Use multi-signature wallets for owner operations
- Implement gradual rollout for mainnet deployment
- Conduct thorough testing before production use
- Monitor contract for unusual activity or potential exploits

### Audit Recommendations

- Smart contract security audit before mainnet deployment
- Oracle price feed validation and monitoring
- Stress testing with various market conditions
- Review of economic incentives and tokenomics

## Development

### Running Tests

```bash
npm run test
```

### Watch Mode

```bash
npm run test:watch
```

### Coverage Report

```bash
npm run test:report
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the ISC License.

## Support

For questions or support, please open an issue in the repository or contact the development team.