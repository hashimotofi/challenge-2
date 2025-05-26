// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IPriceOracle {
    function getPrice(address _token) external returns (uint256);
}

contract RewardDistributor {
    IPriceOracle public priceOracle;
    address public owner;
    bool public initialized;
    
    mapping(address => bool) public vaults;
    address public rewardToken;
    mapping(bytes32 => mapping(address => bool)) public roleMembers;
    
    bytes32 public constant VAULT_ROLE = keccak256("VAULT_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    uint256 public lastDistribution;
    
    event VaultAdded(address vault);
    event VaultRemoved(address vault);
    event RewardTokenSet(address token);
    event RewardsDistributed(address vault, uint256 amount);
    event RoleGranted(bytes32 role, address account);
    
    constructor() {
        owner = msg.sender;
        roleMembers[ADMIN_ROLE][msg.sender] = true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyRole(bytes32 role) {
        require(roleMembers[role][msg.sender], "Missing role");
        _;
    }
    
    function initialize(address _priceOracle) external onlyOwner {
        require(!initialized, "Already initialized");
        priceOracle = IPriceOracle(_priceOracle);
        initialized = true;
    }
    
    function addVault(address _vault) external onlyRole(ADMIN_ROLE) {
        require(_vault != address(0), "Invalid vault");
        vaults[_vault] = true;
        emit VaultAdded(_vault);
    }
    
    function removeVault(address _vault) external onlyRole(ADMIN_ROLE) {
        vaults[_vault] = false;
        emit VaultRemoved(_vault);
    }
    
    function setRewardToken(address _token) external onlyRole(ADMIN_ROLE) {
        require(_token != address(0), "Invalid token address");
        rewardToken = _token;
        emit RewardTokenSet(_token);
    }
    
    function grantRole(bytes32 role, address account) external onlyRole(ADMIN_ROLE) {
        roleMembers[role][account] = true;
        emit RoleGranted(role, account);
    }
    
    function distributeRewards(address _vault) external onlyRole(VAULT_ROLE) {
        require(vaults[_vault], "Vault not registered");
        
        uint256 rewardAmount = 100 * 10**18;
        lastDistribution = block.timestamp;
        
        emit RewardsDistributed(_vault, rewardAmount);
    }
    
    function calculateRewards(address _vault) external view returns (uint256) {
        require(vaults[_vault], "Vault not registered");
        return 100 * 10**18;
    }
}