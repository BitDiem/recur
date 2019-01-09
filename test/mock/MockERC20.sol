pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

/**
 * @title SharesToken
 * @dev A standard ERC20 token derived from Open Zeppelin's implementation - 
 * with the addition of an internal array to track all current shareholders.
 */
contract MockERC20 is IERC20, ERC20, ERC20Detailed {

    uint8 private constant DECIMALS = 18;

    constructor(
        string name, 
        string symbol, 
        address holder,
        uint totalSupply
    ) 
        ERC20Detailed(name, symbol, DECIMALS) 
        public 
    {
        _mint(holder, totalSupply);
    }
}