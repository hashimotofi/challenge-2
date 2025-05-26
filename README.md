## Overview
Demonstrate expertise in deploying existing smart contracts to Plume testnet and configuring them for use.

## Provided Materials
- `TokenVault.sol` (main vault contract)
- `VaultManager.sol` (manager contract)
- `RewardDistributor.sol` (handles reward distribution)
- `PriceOracle.sol` (price feed oracle)
- Basic Hardhat project structure with dependencies
- Configuration templates

## Scenario
You need to deploy an existing vault ecosystem to Plume testnet. This is a connected system where 4 contracts must be deployed in the correct order and properly linked together to function as an integrated system.

## Tasks

### Task 1: Network Configuration
**Goal**: Set up Plume testnet configuration in Hardhat

**Requirements**:
- Add Plume testnet to `hardhat.config.ts`
- Configure RPC endpoint, chain ID, and gas settings
- Configure deployment account management

**Deliverable**: Updated `hardhat.config.ts` with Plume testnet network

### Task 2: Multi-Contract Deployment
**Goal**: Deploy interconnected contracts in correct dependency order

**Requirements**:
Write `scripts/deploy-vault.ts` that deploys contracts in this order:
1. **PriceOracle** (independent) 
2. **RewardDistributor** (needs PriceOracle address)
3. **VaultManager** (independent)
4. **TokenVault** (needs VaultManager, RewardDistributor, PriceOracle addresses)

**Deployment Dependencies**:
```typescript
// Deployment order matters!
const priceOracle = await deployPriceOracle(PLUME_FEEDS);

const rewardDistributor = await deployRewardDistributor(priceOracle.address);

const vaultManager = await deployVaultManager();

const tokenVault = await deployTokenVault({
  manager: vaultManager.address,
  distributor: rewardDistributor.address,
  oracle: priceOracle.address
});
```

**Network Parameters**:
```typescript
const PLUME_CONFIG = {
  // Price feed addresses for Plume testnet
  // Price feeds are mocked in the PriceOracle contract, use ANY valid evm address
  priceFeedAddresses: {
    PLUME: "0x...",  // Native Plume token price feed
    PUSD: "0x..."    // PUSD stable token price feed
  },
  feeRate: 100, // 1%
  minDeposit: ethers.parseEther("0.1")
};
```

**Deliverable**: Deployment script handling contract dependencies

### Task 3: Contract Integration & Linking
**Goal**: Configure all contracts to work together as an integrated system

**Requirements**:
Create `scripts/configure.ts` that performs these linking operations:

**Phase 1: Basic Linking**
```typescript
// Link TokenVault to its dependencies
await tokenVault.setManager(vaultManager.address);
await tokenVault.setRewardDistributor(rewardDistributor.address);
await tokenVault.setPriceOracle(priceOracle.address);

// Configure RewardDistributor
await rewardDistributor.addVault(tokenVault.address);
await rewardDistributor.setRewardToken("0x1E0E030AbCb4f07de629DCCEa458a271e0E82624"); // PUSD token

// Set up VaultManager
await vaultManager.addVault(tokenVault.address);
```

**Phase 2: Cross-Contract Permissions**
```typescript
// Grant necessary roles across contracts
await vaultManager.grantRole(OPERATOR_ROLE, tokenVault.address);
await rewardDistributor.grantRole(VAULT_ROLE, tokenVault.address);
```

**Phase 3: System Parameters**
- Configure price feed update frequencies in PriceOracle
- Set reward token and amounts in RewardDistributor
- Configure fee rates and minimum deposits in TokenVault

**Integration Validation**:
- Test vault can call reward distributor
- Verify price oracle responds to vault queries
- Validate manager flows work end-to-end

**Deliverable**: Complete system integration with cross-contract validation

### Task 4: Deployment Verification & Documentation
**Goal**: Verify deployment success and document the process

**Requirements**:
Create `scripts/verify.ts` that:
- Checks all contracts are deployed correctly
- Performs source code verification of deployed contracts on Plume testnet explorer
- Validates contract configurations match requirements
- Tests basic contract interactions
- Generates deployment summary report
- Documents contract addresses and configurations

**Deliverable**: 
- Verification script with health checks
- `DEPLOYMENT_REPORT.md` with all contract addresses and configurations

## Contract Interfaces

```solidity
interface ITokenVault {
    function initialize(uint256 _feeRate, uint256 _minDeposit) external;
    function setManager(address _manager) external;
    function setRewardDistributor(address _distributor) external;
    function setPriceOracle(address _oracle) external;
}

interface IVaultManager {
    function initialize() external;
    function addVault(address _vault) external;
    function grantRole(bytes32 role, address account) external;
}

interface IRewardDistributor {
    function initialize(address _priceOracle) external;
    function addVault(address _vault) external;
    function setRewardToken(address _token) external;
    function grantRole(bytes32 role, address account) external;
}

interface IPriceOracle {
    function initialize(address[] memory _priceFeeds) external;
    function updateFeedAddresses(address[] memory _feeds) external;
}
```

## Contract Dependency Graph
```
PriceOracle (independent)
    ↓
RewardDistributor (needs PriceOracle)
    ↓
VaultManager (independent)
    ↓
TokenVault (needs all: VaultManager, RewardDistributor, PriceOracle)
```

## Network Requirements

### Network Configuration Targets
- **RPC**: Plume testnet (https://testrpc.plume.org)
- **Chain ID**: 98867
- **Gas Settings**: Appropriate for Plume testnet
- **Verification**: Plume explorer source code verification
- **Faucet**: https://faucet.plume.org/ for testnet tokens

### Expected Deployment Addresses Format
```json
{
  "plume": {
    "PriceOracle": "0x...",
    "RewardDistributor": "0x...",
    "VaultManager": "0x...",
    "TokenVault": "0x...",
    "deploymentBlock": 12345678,
    "totalGasUsed": "2345678"
  }
}
```

## Evaluation Criteria

### Network Configuration
- **Hardhat Setup**: Correct network parameters, gas settings, verification
- **Environment Management**: Proper secret handling, RPC configuration

### Deployment Execution
- **Deployment Logic**: Correct contract deployment order, parameter passing
- **Error Handling**: Graceful failure handling, recovery mechanisms
- **Address Management**: Proper storage and retrieval of deployed addresses

### System Configuration
- **Contract Integration**: Correct linking between all 4 contracts
- **Cross-Contract Permissions**: Proper role assignments across contracts
- **Parameter Configuration**: Network-appropriate settings validation

### Workflow
- **Documentation**: Clear deployment report with integration status
- **Verification**: All 4 contracts verified on Plume testnet explorer

## Success Metrics
- [ ] Contracts deploy successfully to Plume testnet
- [ ] System is fully configured and operational
- [ ] Deployment addresses are properly documented
- [ ] Configuration matches network requirements

## Submission Requirements
Submit containing:
- Complete Hardhat project with deployment scripts (deploy-vault.ts, configure.ts, verify.ts)
- `deployments.json` with contract addresses
- `DEPLOYMENT_REPORT.md` with deployment summary

## Quick Start Commands
We expect the complete challenge to be able to run the following commands with intended results:
```bash
npm install
npx hardhat run scripts/deploy-vault.ts --network plume
npx hardhat run scripts/configure.ts --network plume
npx hardhat run scripts/verify.ts --network plume
```
