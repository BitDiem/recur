pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title PayFromContract
 * @dev Transfers an ERC20 token from this contract to a provided address.
 * Emits an event on successful transfer.
 */
contract PayFromContract {

    event PaidFromContract(
        address indexed payee,
        IERC20 indexed token,
        uint amountPaid, 
        uint amountLeftUnpaid);

    /**
     * @dev Anyone can transfer a token balance to this contract.  This function gives the payor 
     * a mechanism to pay their debit against their token balance.  The supported scenario is:
     * Payee transfers an amount of token as a refund, promotion, coupon, credit, etc.  This contract 
     * holds that token in escrow, only withdrawable by the payor.
     */
    function _payFromTokenBalance(
        address to,
        IERC20 token,
        uint amount
    ) 
        internal 
        returns (uint) 
    {
        if (amount == 0)
            return amount;

        uint balance = token.balanceOf(address(this));

        if (balance == 0)
            return amount;

        uint amountPaid;
        uint remainder;

        // the case where there is no remainder
        if (amount <= balance) {
            amountPaid = amount;
            remainder = 0;
            token.transfer(to, amount);
        }
        else if (amount > balance) {
            amountPaid = balance;
            remainder = amount - balance;
            token.transfer(to, balance);
        }

        emit PaidFromContract(to, token, amountPaid, remainder);

        return remainder;
    }

}