pragma solidity ^0.5.0;

import "./ISubscriptionPaymentTerms.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract SubscriptionRecurringPaymentTerms is ISubscriptionPaymentTerms {

    using SafeMath for uint;

    uint private _amount;
    uint private _timeInterval;             // interval as unix milliseconds

    uint private _lastIntervalTime;         // last interval timestamp
    uint private _outstandingIntervals;
    uint private _outstandingAmount;

    event RecurringPaymentsElapsed(
        uint totalOutstandingAmount, 
        uint totalOutstandingIntervals, 
        uint lastIntervalTime
    );

    constructor(
        uint amount, 
        uint timeInterval,
        uint delay // use case: "first 30 days free"
    )
        public
    {
        _amount = amount;
        _timeInterval = timeInterval;
        _lastIntervalTime = now + delay;
    }

    function currentAmountDue() public returns (uint) {
        _toCurrentTime();
        return _outstandingAmount;
    }

    function markAsPaid(uint amount) public {
        _outstandingAmount = _outstandingAmount.sub(amount);
    }

    function _toCurrentTime() private {
        uint currentTime = now;
        uint elapsedTime = currentTime - _lastIntervalTime;
        uint div = elapsedTime / _timeInterval;

        if (div == 0)
            return;

        uint mod = elapsedTime % _timeInterval;
        uint paymentAmount = _amount * div;

        _lastIntervalTime = currentTime - mod;
        _outstandingIntervals = _outstandingIntervals + div;
        _outstandingAmount = _outstandingAmount + paymentAmount;

        emit RecurringPaymentsElapsed(
            _outstandingAmount, 
            _outstandingIntervals, 
            _lastIntervalTime
        );
    }

/*
    /// Open question - since there is no user input - time will come from global environment variables - 
    /// is it necessary to use the SafeMath library?
    function _toCurrentTimeSafeMath() private {
        uint currentTime = now;
        uint elapsedTime = currentTime.sub(_lastIntervalTime);
        uint div = elapsedTime.div(_timeInterval);

        if (div == 0)
            return;

        uint mod = elapsedTime.mod(_timeInterval);
        uint paymentAmount = _amount.mul(div);

        _lastIntervalTime = currentTime.sub(mod);
        _outstandingIntervals = _outstandingIntervals.add(div);
        _outstandingAmount = _outstandingAmount.add(paymentAmount);

        emit RecurringPaymentsElapsed(
            _outstandingAmount, 
            _outstandingIntervals, 
            _lastIntervalTime
        );
    }
*/

}