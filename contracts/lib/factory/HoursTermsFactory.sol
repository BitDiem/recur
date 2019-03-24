pragma solidity ^0.5.0;

import "../../terms/Hours.sol";

library HoursTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint hoursIncrement
    )
        external
        returns (Hours)
    {
        return new Hours(
            amount, 
            nextPaymentYear, 
            nextPaymentMonth, 
            nextPaymentDay, 
            nextPaymentHour, 
            nextPaymentMinute, 
            nextPaymentSecond,
            hoursIncrement
        );
    }

}