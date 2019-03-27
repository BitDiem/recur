pragma solidity ^0.5.0;

import "../../terms/datetime/Yearly.sol";

library YearlyTermsFactory {

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
        returns (Yearly)
    {
        return new Yearly(
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