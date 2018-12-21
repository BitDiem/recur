pragma solidity ^0.4.24;

import "./FixedRateSubscription.sol";

contract VariableRateSubscription is FixedRateSubscription {

    address _authorizedRateAdjustor;

    event RateAdjusted(uint amount);

    constructor (
        IAuthorizedTokenTransferer authorizedTransferer,
        address payor, 
        address payee, 
        address token, 
        uint amount, 
        uint interval,
        address authorizedRateAdjustor
    ) 
        FixedRateSubscription(authorizedTransferer, payor, payee, token, amount, interval)
        public 
    {
        _authorizedRateAdjustor = authorizedRateAdjustor;
    }

    function setAmount(uint amount) public {
        require(_authorizedRateAdjustor == msg.sender);
        _amount = amount;
        emit RateAdjusted(amount);
    }
}