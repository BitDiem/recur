pragma solidity ^0.5.0;

import "../payment/PaymentObligation.sol";
import "../lib/date/DateTime.sol";
import "../lib/date/MockableCurrentTime.sol";

/**
 * @title Seconds
 * @dev Specifies an initial payment due date and time, as well as an interval, 
 * measured in seconds, between due dates thereafter.
 */
contract Seconds is PaymentObligation, MockableCurrentTime {

    uint private _nextPaymentTimestamp;
    uint private _amount;
    uint private _secondsIncrement;

    event PaymentDue(uint paymentDueDate, uint amount);

    constructor(
        uint amount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint nextPaymentHour,
        uint nextPaymentMinute,
        uint nextPaymentSecond,
        uint secondsIncrement
    )
        public
    {
        require(amount > 0);
        require(secondsIncrement > 0);
        require(DateTime.isValidYearAndMonth(nextPaymentYear, nextPaymentMonth));
        require(nextPaymentDay > 0);
        require(DateTime.isValidTime(nextPaymentHour, nextPaymentMinute, nextPaymentSecond));

        _amount = amount;
        _secondsIncrement = secondsIncrement;

        uint date = DateTime.timestampFromDate(nextPaymentYear, nextPaymentMonth, nextPaymentDay);
        uint secondsOffset = DateTime.totalSeconds(nextPaymentHour, nextPaymentMinute, nextPaymentSecond);
        _nextPaymentTimestamp = DateTime.add(date, secondsOffset);
    }

    function _calculateOutstandingAmount() internal returns (uint) {
        if (_getCurrentTimeInUnixSeconds() < _nextPaymentTimestamp)
            return 0;

        uint currentPaymentDue = _nextPaymentTimestamp;
        _nextPaymentTimestamp = DateTime.add(_nextPaymentTimestamp, _secondsIncrement);   
        emit PaymentDue(currentPaymentDue, _amount);
        return _amount;
    }

}