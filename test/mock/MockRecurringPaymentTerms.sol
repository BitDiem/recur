pragma solidity ^0.5.0;

import "../../contracts/terms/RecurringPaymentTerms.sol";

contract MockRecurringPaymentTerms is RecurringPaymentTerms {

    uint private currentTimeStamp;

    constructor(
        uint amount, 
        uint timeInterval,
        uint delay // use case: "first 30 days free"
    )
        RecurringPaymentTerms(amount, timeInterval, delay)
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