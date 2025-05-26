// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PriceOracle {
    mapping(string => address) public priceFeeds;
    mapping(address => uint256) public lastPriceUpdate;
    mapping(address => uint256) public cachedPrices;
    address public owner;
    bool public initialized;
    uint256 public updateFrequency = 3600; // 1 hour
    
    event PriceFeedUpdated(string symbol, address feed);
    event PriceUpdated(address token, uint256 price);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function initialize(address[] memory _priceFeeds) external onlyOwner {
        require(!initialized, "Already initialized");
        initialized = true;
    }
    
    function updateFeedAddresses(address[] memory _feeds) external onlyOwner {
        require(_feeds.length > 0, "Empty feeds array");
        for (uint i = 0; i < _feeds.length; i++) {
            lastPriceUpdate[_feeds[i]] = block.timestamp;
        }
    }
    
    function setPriceFeed(string memory _symbol, address _feed) external onlyOwner {
        require(_feed != address(0), "Invalid feed address");
        priceFeeds[_symbol] = _feed;
        emit PriceFeedUpdated(_symbol, _feed);
    }
    
    function getPrice(address _token) external returns (uint256) {
        if (block.timestamp - lastPriceUpdate[_token] > updateFrequency) {
            cachedPrices[_token] = 1000 * 10**18;
            lastPriceUpdate[_token] = block.timestamp;
            emit PriceUpdated(_token, cachedPrices[_token]);
        }
        return cachedPrices[_token];
    }
    
    function setUpdateFrequency(uint256 _frequency) external onlyOwner {
        updateFrequency = _frequency;
    }
}