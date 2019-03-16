pragma solidity ^0.5.0;

import "../../terms/Yearly.sol";

library YearlyTermsFactory {

    function create(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay
    )
        external
        returns (Yearly)
    {
        return new Yearly(amount, nextPaymentYear, nextPaymentMonth, nextPaymentDay);
    }

}