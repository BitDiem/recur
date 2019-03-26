pragma solidity ^0.5.0;

import "../payment/PaymentObligation.sol";
import "../lib/date/MockableCurrentTime.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Seconds
 * @dev Specifies an initial payment due date and time, as well as an interval, 
 * measured in seconds, between due dates thereafter.
 */
contract Seconds is PaymentObligation, MockableCurrentTime {

    using SafeMath for uint;

    uint private _nextPaymentDueTimestamp;
    uint private _amount;
    uint private _secondsIncrement;

    event PaymentDue(
        uint paymentDueDate, 
        uint amountDue, 
        uint elapsedIntervals, 
        uint nextPaymentDueDate
    );

    constructor(
        uint amount,
        uint nextPaymentDueTimestamp,
        uint secondsIncrement
    )
        public
    {
        require(amount > 0);
        require(secondsIncrement > 0);

        _amount = amount;
        _nextPaymentDueTimestamp = nextPaymentDueTimestamp;
        _secondsIncrement = secondsIncrement;

        emit PaymentDue(0, 0, 0, _nextPaymentDueTimestamp);
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