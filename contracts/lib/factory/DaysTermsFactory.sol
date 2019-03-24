pragma solidity ^0.5.0;

import "../../terms/Days.sol";

library DaysTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint daysIncrement
    )
        external
        returns (Days)
    {
        return new Days(
            amount, 
            nextPaymentYear, 
            nextPaymentMonth, 
            nextPaymentDay, 
            nextPaymentHour, 
            nextPaymentMinute, 
            nextPaymentSecond,
            daysIncrement
        );
    }

}