// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract VaultManager {
    address public owner;
    bool public initialized;
    mapping(address => bool) public vaults;
    mapping(bytes32 => mapping(address => bool)) public roleMembers;
    
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    event VaultAdded(address vault);
    event VaultRemoved(address vault);
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
    
    function initialize() external onlyOwner {
        require(!initialized, "Already initialized");
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
    

    
    function grantRole(bytes32 role, address account) external onlyRole(ADMIN_ROLE) {
        roleMembers[role][account] = true;
        emit RoleGranted(role, account);
    }
    
    function isVaultRegistered(address _vault) external view returns (bool) {
        return vaults[_vault];
    }
}