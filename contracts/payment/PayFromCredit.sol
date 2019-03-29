pragma solidity ^0.5.0;

import "../payment/balances/PaymentCredit.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title PayFromCredit
 * @dev Debits the payment amount against the current Credit balance.
 * Emits an event on successful debit.
 */
contract PayFromCredit is PaymentCredit {

    event PaidFromCredit(uint amountPaid, uint amountLeftUnpaid, uint remainingCredit);

    /**
     * @dev Pays an arbitrary non-zero amount against the available Credit
     */
    function _payFromCredit(
        uint amount
    ) 
        internal 
        returns (uint) 
    {
        uint credit = getCredit();

        if (amount == 0 || credit == 0)
            return amount;

        uint remainder;
        uint amountPaid;
        uint newCreditAmount;

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

        _setCredit(newCreditAmount);
        
        emit PaidFromCredit(amountPaid, remainder, newCreditAmount);

        return remainder;
    }

}