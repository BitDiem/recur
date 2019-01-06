pragma solidity ^0.5.0;

import "./IAuthorizedTokenTransferer.sol";
import "./Payable.sol";
import "./Receivable.sol";
import "./SubscriptionPaymentInfo.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/ownership/Secondary.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title Balanceable
 * @dev Anyone can transfer a token balance to this contract.  This contract gives the payor 
 * a mechanism to pay their debit against their token balance.  The supported scenario is:
 * Payee transfers an amount of token as a refund, promotion, coupon, credit, etc.  This contract 
 * holds that token in escrow, only withdrawable by the payor.
 */
contract Balanceable is SubscriptionPaymentInfo {

    /*constructor (
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        address token
    ) 
        SubscriptionPaymentInfo(payor, payee, authorizedTransferer, token)
        internal
    {}*/

    // no credit or add function - simply transfer any erc20 token (and/or ether?) to this contract address

    /**
     * @dev Allows the payor to withdraw any erc20 token sent to the contract.
     * @param token The address of the ERC20 token to withdraw
     * @param amount The balance amount to withdraw
     */
    function withdrawBalance(address token, uint amount) public onlyPayor {
        require(amount > 0);
        require(token != address(0));
        IERC20 tokenContract = IERC20(token);
        tokenContract.transferFrom(address(this), msg.sender, amount);
    }

    function payFromBalance(uint amount) internal returns (uint) {
        return payFromBalance(token(), amount, getPayee());
    }

    function payFromBalance(
        address token,
        uint amount,
        address to
    ) 
        private 
        returns (uint) 
    {
        if (amount == 0)
            return amount;

        IERC20 tokenContract = IERC20(token);
        uint balance = tokenContract.balanceOf(address(this));

        if (balance == 0)
            return amount;

        uint remainder;

        // the case where there is no remainder
        if (amount <= balance) {
            remainder = 0;
            tokenContract.transfer(to, amount);
        }
        else if (amount > balance) {
            remainder = amount - balance;
            tokenContract.transfer(to, balance);
        }

        return remainder;
    }

}