pragma solidity ^0.5.0;

import "../../terms/MultiMonthly.sol";

library MultiMonthlyTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint monthIncrement
    )
        external
        returns (MultiMonthly)
    {
        return new MultiMonthly(
            amount, 
            nextPaymentYear, 
            nextPaymentMonth, 
            nextPaymentDay, 
            nextPaymentHour, 
            nextPaymentMinute, 
            nextPaymentSecond,
            monthIncrement
        );
    }

}