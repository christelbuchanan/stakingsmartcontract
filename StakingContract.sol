// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title StakingContract
 * @dev A simple staking contract that allows users to stake tokens and earn rewards
 */
contract StakingContract is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Token being staked
    IERC20 public stakingToken;
    
    // Token given as reward
    IERC20 public rewardToken;
    
    // Reward rate per second
    uint256 public rewardRate;
    
    // Last time rewards were updated
    uint256 public lastUpdateTime;
    
    // Reward per token stored
    uint256 public rewardPerTokenStored;
    
    // Minimum staking period in seconds
    uint256 public minimumStakingPeriod = 1 days;
    
    // Mapping for user's staked balance
    mapping(address => uint256) public stakedBalance;
    
    // Mapping for user's staking timestamp
    mapping(address => uint256) public stakingTimestamp;
    
    // Mapping for user reward per token paid
    mapping(address => uint256) public userRewardPerTokenPaid;
    
    // Mapping for user's reward amount
    mapping(address => uint256) public rewards;
    
    // Total staked amount
    uint256 public totalStaked;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);

    /**
     * @dev Constructor to initialize the staking contract
     * @param _stakingToken Address of the token that will be staked
     * @param _rewardToken Address of the token that will be given as rewards
     * @param _rewardRate Initial reward rate per second
     */
    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
        lastUpdateTime = block.timestamp;
    }

    /**
     * @dev Updates the reward variables
     */
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /**
     * @dev Calculates the reward per token
     * @return Reward amount per token
     */
    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        
        return rewardPerTokenStored.add(
            block.timestamp
                .sub(lastUpdateTime)
                .mul(rewardRate)
                .mul(1e18)
                .div(totalStaked)
        );
    }

    /**
     * @dev Calculates the earned rewards for an account
     * @param account Address of the user
     * @return Earned reward amount
     */
    function earned(address account) public view returns (uint256) {
        return stakedBalance[account]
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
    }

    /**
     * @dev Allows users to stake tokens
     * @param amount Amount of tokens to stake
     */
    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        
        totalStaked = totalStaked.add(amount);
        stakedBalance[msg.sender] = stakedBalance[msg.sender].add(amount);
        stakingTimestamp[msg.sender] = block.timestamp;
        
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        
        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Allows users to withdraw their staked tokens
     * @param amount Amount of tokens to withdraw
     */
    function withdraw(uint256 amount) external nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(stakedBalance[msg.sender] >= amount, "Not enough staked tokens");
        require(
            block.timestamp >= stakingTimestamp[msg.sender] + minimumStakingPeriod,
            "Minimum staking period not reached"
        );
        
        totalStaked = totalStaked.sub(amount);
        stakedBalance[msg.sender] = stakedBalance[msg.sender].sub(amount);
        
        stakingToken.safeTransfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Allows users to claim their earned rewards
     */
    function claimReward() external nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        
        require(reward > 0, "No rewards to claim");
        
        rewards[msg.sender] = 0;
        rewardToken.safeTransfer(msg.sender, reward);
        
        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @dev Updates the reward rate (only owner)
     * @param _rewardRate New reward rate per second
     */
    function setRewardRate(uint256 _rewardRate) external onlyOwner updateReward(address(0)) {
        rewardRate = _rewardRate;
        emit RewardRateUpdated(_rewardRate);
    }

    /**
     * @dev Updates the minimum staking period (only owner)
     * @param _minimumStakingPeriod New minimum staking period in seconds
     */
    function setMinimumStakingPeriod(uint256 _minimumStakingPeriod) external onlyOwner {
        minimumStakingPeriod = _minimumStakingPeriod;
    }

    /**
     * @dev Allows the owner to recover any ERC20 tokens sent to the contract by mistake
     * @param tokenAddress Address of the token to recover
     * @param tokenAmount Amount of tokens to recover
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(
            tokenAddress != address(stakingToken),
            "Cannot recover staking token"
        );
        
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
    }
}
