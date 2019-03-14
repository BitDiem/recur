pragma solidity ^0.5.0;

import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title PayFromAddress
 * @dev TODO: Write
 */
library PaymentLibrary {

    function pay(
        address payor,
        address payee,
        IERC20 token,
        uint paymentAmount,
        uint credit,
        IAuthorizedTokenTransferer transferer
    ) 
        external 
        returns (
            uint totalPaid,
            uint paidFromCredit,
            uint newCreditAmount,
            uint paidFromSelf,
            uint paidFromAddress,
            uint remainder
        ) 
    {
        remainder = paymentAmount;

        (paidFromCredit, remainder, newCreditAmount) = 
            _payFromCredit(credit, remainder);

        (paidFromSelf, remainder) = 
            _payFromSelf(payee, token, remainder);

        (paidFromAddress, remainder) = 
            _payFromAddress(payor, payee, token, remainder, transferer);

        totalPaid = paymentAmount - remainder;
    }

    /**
     * @dev Pays an arbitrary non-zero amount against the available Credit
     */
    function _payFromCredit(
        uint credit,
        uint amount
    ) 
        private
        pure
        returns (uint amountPaid, uint remainder, uint newCreditAmount) 
    {
        if (amount == 0 || credit == 0)
            return (0, amount, credit);

        // the case where there is no remainder
        if (amount < credit) {
            amountPaid = amount;
            remainder = 0;
            newCreditAmount = credit - amount;
        }
        else if (amount > credit) {
            amountPaid = credit;
            remainder = amount - credit;
            newCreditAmount = 0;
        }
        else {
            amountPaid = credit;
            remainder = 0;
            newCreditAmount = 0;
        }
        
        return (amountPaid, remainder, newCreditAmount);
    }

    /**
     * @dev Anyone can transfer a token balance to this contract.  This function gives the payor 
     * a mechanism to pay their debit against their token balance.  The supported scenario is:
     * Payee transfers an amount of token as a refund, promotion, coupon, credit, etc.  This contract 
     * holds that token in escrow, only withdrawable by the payor.
     */
    function _payFromSelf(
        address to,
        IERC20 token,
        uint amount
    ) 
        private 
        returns (uint amountPaid, uint remainder) 
    {
        if (amount == 0)
            return (0, amount);

        uint balance = token.balanceOf(address(this));

        if (balance == 0)
            return (0, amount);

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

        //emit PaidFromContract(to, token, amountPaid, remainder);

        return (amountPaid, remainder);
    }

    /**
     * @dev Pays an arbitrary non-zero amount against the funding source address, utilized an approved transfer address
     */
    function _payFromAddress(
        address payor,
        address payee,
        IERC20 token,
        uint amount,
        IAuthorizedTokenTransferer authorizedTransferer
    )
        private
        returns (uint amountPaid, uint remainder) 
    {
        if (amount == 0) {
            return (0, 0);
        } else {
            (amountPaid, remainder) = authorizedTransferer.transferMax(payor, payee, token, amount);
            return (amountPaid, remainder);
        }
    }

}