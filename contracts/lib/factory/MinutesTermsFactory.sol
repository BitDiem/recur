pragma solidity ^0.5.0;

import "../../terms/Minutes.sol";

library MinutesTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint minutesIncrement
    )
        external
        returns (Minutes)
    {
        return new Minutes(
            amount, 
            nextPaymentYear, 
            nextPaymentMonth, 
            nextPaymentDay, 
            nextPaymentHour, 
            nextPaymentMinute, 
            nextPaymentSecond,
            minutesIncrement
        );
    }

}