pragma solidity ^0.5.0;

import "../payment/roles/TokenWithdrawerRole.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title TokenEscrow
 * @dev Allows retrieval of any ERC20 tokens sent to the contract
 */
contract TokenEscrow is TokenWithdrawerRole {

    event TokensWithdrawn(address withdrawer, IERC20 token, uint amount);

    /**
     * @dev Allows allows an approved token withdrawer address to withdraw any erc20 token held in this contract.
     * @param token The address of the ERC20 token to withdraw
     * @param amount The balance amount to withdraw
     */
    function withdrawToken(address token, uint amount) public onlyTokenWithdrawer {
        require(amount > 0);
        require(token != address(0));
        address to = msg.sender;
        IERC20 tokenContract = IERC20(token);
        tokenContract.transfer(to, amount);
        emit TokensWithdrawn(to, tokenContract, amount);
    }

}