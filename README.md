# Simple Staking Contract

This project contains a simple staking contract implementation in Solidity.

## Contracts

### StakingToken.sol
A basic ERC20 token that will be used for staking rewards.

### StakingContract.sol
A staking contract that allows users to:
- Stake tokens
- Withdraw tokens after a minimum staking period
- Earn and claim rewards based on staking duration

## Features

- Time-based rewards calculation
- Minimum staking period requirement
- Owner-configurable reward rate
- Security measures (ReentrancyGuard, SafeMath, SafeERC20)
- Token recovery function for mistakenly sent tokens

## Usage

1. Deploy the `StakingToken` contract
2. Deploy the `StakingContract` with the following parameters:
   - `_stakingToken`: Address of the token to be staked
   - `_rewardToken`: Address of the token to be given as rewards
   - `_rewardRate`: Initial reward rate per second

## Functions

- `stake(uint256 amount)`: Stake tokens
- `withdraw(uint256 amount)`: Withdraw staked tokens
- `claimReward()`: Claim earned rewards
- `earned(address account)`: View earned rewards for an account
- `setRewardRate(uint256 _rewardRate)`: Update the reward rate (owner only)
- `setMinimumStakingPeriod(uint256 _minimumStakingPeriod)`: Update the minimum staking period (owner only)

## Security Considerations

- The contract uses OpenZeppelin's security libraries
- Reentrancy protection is implemented
- Owner privileges are limited to necessary functions
