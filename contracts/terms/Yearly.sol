pragma solidity ^0.5.0;

import "../terms/FixedDate.sol";

contract Yearly is FixedDate {

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay
    )
        FixedDate(amount, nextPaymentYear, nextPaymentMonth, nextPaymentDay)
        public
    {}

    function _advance() internal {
        _nextPaymentYear = _nextPaymentYear + 1;     
    }

}