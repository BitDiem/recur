pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract SubscriptionRecurringPaymentTerms {

    using SafeMath for uint;

    uint private _amount;
    uint private _timeInterval;         // interval as unix milliseconds

    uint private _lastPaymentTime;      // last payment timestamp
    uint private _outstandingIntervals;
    uint private _outstandingAmount;

    constructor(
        uint amount, 
        uint timeInterval,
        uint delay // use case: "first 30 days free"
    )
        public
    {
        _amount = amount;
        _timeInterval = timeInterval;
        _lastPaymentTime = now + delay;
    }

    function outstandingAmount() public view returns (uint) {
        return _outstandingAmount;
    }

    function process(uint amount) internal {
        _outstandingAmount = _outstandingAmount.sub(amount);
    }

    function toCurrentTimeSafe() public {
        uint currentTime = now;
        uint elapsedTime = currentTime.sub(_lastPaymentTime);
        uint div = elapsedTime.div(_timeInterval);

        if (div == 0)
            return;

        uint mod = elapsedTime.mod(_timeInterval);
        uint paymentAmount = _amount.mul(div);

        _lastPaymentTime = currentTime.sub(mod);
        _outstandingIntervals = _outstandingIntervals.add(div);
        _outstandingAmount = _outstandingAmount.add(paymentAmount);
    }

    function toCurrentTime() public {
        uint currentTime = now;
        uint elapsedTime = currentTime - _lastPaymentTime;
        uint div = elapsedTime / _timeInterval;

        if (div == 0)
            return;

        uint mod = elapsedTime % _timeInterval;
        uint paymentAmount = _amount * div;

        _lastPaymentTime = currentTime - mod;
        _outstandingIntervals = _outstandingIntervals + div;
        _outstandingAmount = _outstandingAmount + paymentAmount;

        //uint currentBlock = block.number;
        //uint elapsedBlocks = currentBlock - _lastPaymentBlock;
        //uint div = elapsedBlocks / _interval;
        //uint mod = elapsedBlocks % _interval;
        //uint paymentAmount = _amount * div;
    }

}