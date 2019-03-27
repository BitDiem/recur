pragma solidity ^0.5.0;

import "../../terms/PaymentObligation.sol";
import "../../lib/date/MockableCurrentTime.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Seconds
 * @dev Specifies an initial payment due date and time, as well as an interval, 
 * measured in seconds, between due dates thereafter.  Payment amount is fixed 
 * (every payment is of the same amount).
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

    function _calculateOutstandingAmount() internal returns (uint amountDue) {
        uint currentTime = _getCurrentTimeInUnixSeconds();
        if (currentTime < _nextPaymentDueTimestamp)
            return 0;

        uint elapsedTime = currentTime - _nextPaymentDueTimestamp + _secondsIncrement;
        uint elapsedIntervals = elapsedTime / _secondsIncrement;
        amountDue = _amount * elapsedIntervals;
        uint offset = elapsedIntervals * _secondsIncrement;
        _nextPaymentDueTimestamp = _nextPaymentDueTimestamp.add(offset);   
        uint currentPaymentDueAt = _nextPaymentDueTimestamp - _secondsIncrement; // no over/underflow check here due to prev line

        emit PaymentDue(currentPaymentDueAt, amountDue, elapsedIntervals, _nextPaymentDueTimestamp);
    }

}