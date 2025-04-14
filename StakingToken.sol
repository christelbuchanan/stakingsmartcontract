// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StakingToken
 * @dev A simple ERC20 token that will be used for staking rewards
 */
contract StakingToken is ERC20, Ownable {
    constructor() ERC20("Staking Token", "STK") {
        // Mint initial supply to the contract creator
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    /**
     * @dev Allows the owner to mint additional tokens
     * @param to Address to receive the minted tokens
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
