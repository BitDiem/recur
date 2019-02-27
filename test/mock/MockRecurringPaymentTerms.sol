pragma solidity ^0.5.0;

import "../../contracts/terms/FixedInterval.sol";

contract MockRecurringPaymentTerms is FixedInterval {

    uint private currentTimeStamp;

    constructor(
        uint amount, 
        uint timeInterval,
        uint delay // use case: "first 30 days free"
    )
        FixedInterval(amount, timeInterval, delay)
        public
    {
    }

    function setCurrentTimeStamp(uint val) public {
        currentTimeStamp = val;
    }

    function _getCurrentTimeInUnixMilliseconds() internal view returns (uint) {
        return currentTimeStamp;
    }

}