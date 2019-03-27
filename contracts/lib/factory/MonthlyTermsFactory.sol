pragma solidity ^0.5.0;

import "../../terms/datetime/Monthly.sol";

library MonthlyTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond
    )
        external
        returns (Monthly)
    {
        return new Monthly(
            amount, 
            nextPaymentYear, 
            nextPaymentMonth, 
            nextPaymentDay, 
            nextPaymentHour, 
            nextPaymentMinute, 
            nextPaymentSecond
        );
    }

}