// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVaultManager {
    function isVaultRegistered(address _vault) external view returns (bool);
}

interface IRewardDistributor {
    function distributeRewards(address _vault) external;
    function calculateRewards(address _vault) external view returns (uint256);
}

interface IPriceOracle {
    function getPrice(address _token) external returns (uint256);
}

contract TokenVault {
    IVaultManager public vaultManager;
    IRewardDistributor public rewardDistributor;
    IPriceOracle public priceOracle;
    
    address public owner;
    bool public initialized;
    uint256 public feeRate; // Basis points (e.g., 200 = 2%)
    uint256 public minDeposit;
    uint256 public totalDeposits;
    
    mapping(address => uint256) public userDeposits;
    mapping(address => uint256) public userRewards;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event ManagerUpdated(address newManager);
    event DistributorUpdated(address newDistributor);
    event OracleUpdated(address newOracle);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function initialize(uint256 _feeRate, uint256 _minDeposit) external onlyOwner {
        require(!initialized, "Already initialized");
        feeRate = _feeRate;
        minDeposit = _minDeposit;
        initialized = true;
    }
    
    function setManager(address _manager) external onlyOwner {
        require(_manager != address(0), "Invalid manager");
        vaultManager = IVaultManager(_manager);
        emit ManagerUpdated(_manager);
    }
    
    function setRewardDistributor(address _distributor) external onlyOwner {
        require(_distributor != address(0), "Invalid distributor");
        rewardDistributor = IRewardDistributor(_distributor);
        emit DistributorUpdated(_distributor);
    }
    
    function setPriceOracle(address _oracle) external onlyOwner {
        require(_oracle != address(0), "Invalid oracle");
        priceOracle = IPriceOracle(_oracle);
        emit OracleUpdated(_oracle);
    }
    
    function deposit(uint256 _amount) external {
        require(_amount >= minDeposit, "Below minimum");
        require(address(vaultManager) != address(0), "Manager not set");
        require(vaultManager.isVaultRegistered(address(this)), "Vault not registered");
        
        uint256 fee = (_amount * feeRate) / 10000;
        uint256 netAmount = _amount - fee;
        userDeposits[msg.sender] += netAmount;
        totalDeposits += netAmount;
        
        emit Deposit(msg.sender, netAmount);
    }
    
    function withdraw(uint256 _amount) external {
        require(userDeposits[msg.sender] >= _amount, "Insufficient balance");
        
        userDeposits[msg.sender] -= _amount;
        totalDeposits -= _amount;
        
        emit Withdrawal(msg.sender, _amount);
    }
    
    function claimRewards() external {
        require(address(rewardDistributor) != address(0), "Distributor not set");
        
        uint256 rewards = rewardDistributor.calculateRewards(address(this));
        require(rewards > 0, "No rewards");
        
        userRewards[msg.sender] += rewards;
        rewardDistributor.distributeRewards(address(this));
        
        emit RewardsClaimed(msg.sender, rewards);
    }
    
    function getTokenPrice(address _token) external returns (uint256) {
        require(address(priceOracle) != address(0), "Oracle not set");
        return priceOracle.getPrice(_token);
    }
}