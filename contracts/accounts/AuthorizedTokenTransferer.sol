pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";

/**
 * @title AuthorizedTokenTransferer
 * @dev Use this contract as a proxy for sending ERC20 tokens from one address to another.  The purpose 
 * of this contract is to have a a reusable destination for receiving ERC20 token approvals.  
 * The sender must call ERC20.approve(this address, amount) before attempting any transfer.
 *
 * This contract has two different flavors of token transfer functions:
 *   1) Transfer a specified amount; fail if that amount cannot be transferred.
 *   2) Calculates the amount of tokens that are transferable and send that amount.
 *
 * Calls to the transfer functions are gated behind whitelisted access, which should only be granted to subscriptions 
 * created in a trusted manner (i.e. via SubscriptionFrontEnd.sol or an equivalent factory/frontend created by a trusted developer).
 */
contract AuthorizedTokenTransferer is IAuthorizedTokenTransferer, WhitelistedRole { 

    event TokenTransferred(
        address indexed from, 
        address indexed to, 
        IERC20 indexed token, 
        uint amount
    );

    event TokenMaxTransferred(
        address indexed from, 
        address indexed to,
        IERC20 indexed token,
        uint amount, 
        uint remainingAmount
    );

    /**
     * @dev Transfers a specified amount of ERC20 tokens, and fails if that amount is not transferrable
     * (due to insufficient balance, lack of token approval for the input amount, etc.).
     * @param from The address tokens will be transferred from.
     * @param to The address tokens will be transferred to.
     * @param token The address of the IERC20 token that will be transferred.
     * @param amount The amount of tokens to transfer.
     */
    function transfer(
        address from, 
        address to, 
        IERC20 token,
        uint amount
    ) 
        public
        onlyWhitelisted
    {
        require (token.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        token.transferFrom(from, to, amount);
        emit TokenTransferred(from, to, token, amount);
    }

    /**
     * @dev Calculates how many tokens are actually transferable, up to a max of the input amount.  
     * Call is designed to not fail - no transfer occurs if no amount is possible to transfer.
     * @param from The address tokens will be transferred from.
     * @param to The address tokens will be transferred to.
     * @param token The address of the IERC20 token that will be transferred.
     * @param amount The maximum amount of tokens to transfer.
     */
    function transferMax(
        address from,
        address to,
        IERC20 token,
        uint amount
    )
        public
        onlyWhitelisted
        returns (uint amountPaid, uint remainingAmount) 
    {
        // check how much the transferer is authorized to send on behalf of the payor
        uint authorizedAmount = token.allowance(from, address(this));
        uint availableBalance = token.balanceOf(from);
        amountPaid = Math.min(amount, Math.min(authorizedAmount, availableBalance));

        if (amountPaid > 0) {
            remainingAmount = amount - amountPaid;
            token.transferFrom(from, to, amountPaid);
            emit TokenMaxTransferred(from, to, token, amountPaid, remainingAmount);
        } else {
            remainingAmount = amount;
        }

        return (amountPaid, remainingAmount);
    }

}