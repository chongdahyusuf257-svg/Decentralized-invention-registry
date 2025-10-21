# 🔬 Decentralized Invention Registry

A blockchain-based patent and invention registration system built on the Stacks blockchain, enabling inventors to register, verify, license, and manage their intellectual property through transparent, decentralized smart contracts.

## 🚀 Features

- **Patent Registration** 📝: Register inventions with detailed descriptions, categories, and licensing fees
- **Verification System** ✅: Official verification process with cryptographic hash validation
- **Licensing Platform** 💰: Automated licensing with multiple license types and fee collection
- **Ownership Management** 👥: Transfer and manage invention ownership with percentage tracking
- **Revenue Tracking** 📊: Monitor licensing revenue and invention performance
- **Reputation System** ⭐: Build inventor reputation through successful registrations and licensing
- **Category Analytics** 📈: Track invention statistics across different categories
- **Patent Renewal** 🔄: Extend patent protection through renewal system

## 📁 Project Structure

```
Decentralized-invention-registry/
├── contracts/
│   └── decentralized-invention-registry.clar    # Main smart contract
├── tests/
│   └── decentralized-invention-registry.test.ts # TypeScript tests
├── Clarinet.toml                                # Project configuration
└── README.md                                    # This file
```

## 🛠️ Installation & Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) (for testing)

### Quick Start
```bash
# Clone the repository
git clone <your-repo-url>
cd Decentralized-invention-registry

# Check contract syntax
clarinet check

# Run tests
npm install
npm test

# Start local development network
clarinet integrate
```

## 📖 Contract Functions

### Public Functions

#### Patent Registration
- `register-invention` - Register new inventions with title, description, category, and license fee
- `verify-invention` - Official verification with cryptographic hash validation (admin only)
- `renew-patent` - Extend patent protection period with renewal fees

#### Licensing Operations
- `license-invention` - Purchase licenses for verified inventions with automatic fee transfer
- `update-license-fee` - Modify licensing fees (owner only)
- `revoke-license` - Deactivate specific licenses (owner only)

#### Ownership Management
- `transfer-ownership` - Transfer invention ownership with percentage control

### Read-Only Functions
- `get-invention` - Retrieve complete invention details and statistics
- `get-invention-ownership` - View current ownership information
- `get-invention-license` - Check specific license details and status
- `get-invention-verification` - Access verification records and notes
- `get-user-profile` - View user statistics and reputation scores
- `get-category-stats` - Analyze invention statistics by category
- `is-invention-valid` - Verify if invention patent is still active
- `is-license-active` - Check if a specific license is currently valid
- `get-invention-stats` - Get comprehensive invention analytics
- `get-registry-stats` - Access platform-wide statistics

## 🎯 Usage Examples

### Registering an Invention
```clarity
(contract-call? .decentralized-invention-registry register-invention
  "Quantum Computing Algorithm"
  "Revolutionary quantum algorithm for cryptographic security with 99.9% efficiency improvements over classical methods"
  "Technology"
  u10000000    ;; 10 STX license fee
)
```

### Verifying an Invention (Admin Only)
```clarity
(contract-call? .decentralized-invention-registry verify-invention
  u1    ;; Invention ID
  "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"  ;; Verification hash
  true  ;; Verification result
  "Patent approved after thorough technical review and prior art search"  ;; Notes
)
```

### Licensing an Invention
```clarity
(contract-call? .decentralized-invention-registry license-invention
  u1  ;; Invention ID
  u2  ;; Commercial license type
)
```

### Transferring Ownership
```clarity
(contract-call? .decentralized-invention-registry transfer-ownership
  u1                     ;; Invention ID
  'SP-NEW-OWNER-ADDRESS  ;; New owner principal
  u75                    ;; 75% ownership percentage
)
```

### Updating License Fees
```clarity
(contract-call? .decentralized-invention-registry update-license-fee
  u1        ;; Invention ID
  u15000000 ;; New fee: 15 STX
)
```

### Revoking a License
```clarity
(contract-call? .decentralized-invention-registry revoke-license
  u1                    ;; Invention ID
  'SP-LICENSEE-ADDRESS  ;; Licensee to revoke
)
```

### Renewing Patent Protection
```clarity
(contract-call? .decentralized-invention-registry renew-patent
  u1  ;; Invention ID
)
```

## 📊 Invention Status Flow

```
PENDING (0) → Verification → VERIFIED (1) → LICENSED (2)
     ↓                              ↓
DISPUTED (4)                   EXPIRED (3)
```

## 🏷️ License Types

```
EXCLUSIVE (0)     - Sole licensing rights
NON_EXCLUSIVE (1) - Multiple licensees allowed
COMMERCIAL (2)    - Commercial use permitted
ACADEMIC (3)      - Academic/research use only
```

## 💼 Business Model

### Fee Structure
- **Registration Fee**: 1 STX for new invention registration
- **Renewal Fee**: 0.5 STX for patent renewal (50% of registration fee)
- **License Fees**: Set by inventors, paid directly to patent owners
- **Platform Fees**: Registration and renewal fees collected for registry maintenance

### Patent Duration
- **Initial Period**: 525,600 blocks (~365 days)
- **Renewal**: Additional 525,600 blocks per renewal
- **Verification Period**: 1,440 blocks (~10 days for verification process)

## 🔒 Security Features

- **Admin Verification**: Only contract owner can verify inventions
- **Ownership Validation**: Only current owners can modify invention settings
- **License Protection**: Automatic expiration and revocation controls
- **Payment Security**: Direct STX transfers between parties
- **Hash Verification**: Cryptographic hash validation for patent authenticity
- **Expiration Tracking**: Automatic patent and license expiration management

## 💡 Use Cases

### Technology Patents
- **Software Algorithms**: Register and license proprietary algorithms
- **Hardware Designs**: Protect innovative hardware inventions
- **AI/ML Models**: Secure intellectual property for machine learning innovations
- **Blockchain Solutions**: Register decentralized technology patents

### Scientific Innovations
- **Medical Devices**: Patent breakthrough medical technology
- **Chemical Processes**: Protect innovative chemical formulations
- **Research Methods**: License scientific research methodologies
- **Biotechnology**: Secure biotech innovations and discoveries

### Creative Inventions
- **Consumer Products**: Register innovative consumer goods
- **Industrial Processes**: Patent manufacturing and industrial innovations
- **Environmental Solutions**: Protect green technology and sustainability innovations
- **Educational Tools**: License innovative educational technologies

## 🎨 Inventor Benefits

- **Global Registration** 🌍: Decentralized patent system accessible worldwide
- **Automated Licensing** 🤖: Smart contract handles licensing and payments
- **Revenue Generation** 💰: Direct monetization through licensing fees
- **Ownership Control** 🎛️: Full control over licensing terms and ownership transfers
- **Reputation Building** 📈: Build credibility through successful patent registrations
- **Transparent Process** 🔍: All transactions and verifications publicly recorded
- **Cost Efficient** 💡: Lower costs compared to traditional patent systems

## 📈 Platform Analytics

The contract provides comprehensive analytics:
- **Invention Performance**: Track registration success and licensing activity
- **Category Trends**: Monitor popular invention categories and market demand
- **Revenue Metrics**: Analyze licensing revenue and inventor earnings
- **User Statistics**: Track inventor activity and reputation scores
- **Verification Rates**: Monitor patent approval and dispute rates
- **Market Intelligence**: Understand patent landscape and opportunities

## 🧪 Testing

Run the comprehensive test suite:

```bash
npm install
npm test
```

Tests cover:
- Invention registration and verification workflows
- Licensing mechanisms and fee transfers
- Ownership transfer and management
- Patent renewal and expiration handling
- License revocation and management
- User profile and reputation updates
- Category statistics tracking
- Error handling and validation

## 🚦 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 401 | ERR_UNAUTHORIZED | Access denied for operation |
| 402 | ERR_INVENTION_NOT_FOUND | Invention ID doesn't exist |
| 403 | ERR_ALREADY_REGISTERED | User already has license for invention |
| 404 | ERR_INVALID_LICENSE | License doesn't exist or is inactive |
| 405 | ERR_LICENSE_EXPIRED | License or patent has expired |
| 406 | ERR_INSUFFICIENT_PAYMENT | Insufficient payment amount |
| 407 | ERR_INVALID_OWNERSHIP | Ownership record not found |
| 408 | ERR_VERIFICATION_FAILED | Invention verification failed |
| 409 | ERR_INVALID_AMOUNT | Invalid amount specified |
| 410 | ERR_TRANSFER_FAILED | Transfer operation failed |

## 🌟 Platform Benefits

- **Decentralized IP Rights** 🏛️: No central authority controls patent validation
- **Global Accessibility** 🌐: Anyone can register and license inventions worldwide
- **Transparent Operations** 📊: All patent activities publicly verifiable
- **Automated Processes** ⚡: Smart contracts handle licensing and payments
- **Lower Costs** 💸: Reduced fees compared to traditional patent systems
- **Faster Processing** 🚀: Quick verification and licensing processes
- **Immutable Records** 📜: Permanent blockchain record of all patent activities

## 🎯 Target Markets

- **Independent Inventors**: Individual inventors seeking patent protection
- **Startup Companies**: Early-stage companies protecting innovations
- **Research Institutions**: Universities and research labs monetizing discoveries
- **Technology Companies**: Tech companies managing patent portfolios
- **Innovation Hubs**: Accelerators and incubators supporting inventor communities
- **Patent Investors**: Entities investing in intellectual property assets

## 🌟 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add comprehensive tests
5. Run `clarinet check` to validate
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🤝 Support

For questions or support:
- Create an issue on GitHub
- Check the [Stacks documentation](https://docs.stacks.co/)
- Visit the [Clarinet documentation](https://docs.hiro.so/stacks/clarinet-js-sdk)

## 🚀 Deployment

Ready for deployment on:
- **Stacks Testnet**: For testing and development
- **Stacks Mainnet**: For production patent registration

---

Built with ❤️ for inventors and innovators using Stacks blockchain technology.
