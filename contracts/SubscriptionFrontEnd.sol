pragma solidity ^0.4.24;

import "./IAuthorizedTokenTransferer.sol";
import "./FixedRateSubscription.sol";
import "./VariableRateSubscription.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract SubscriptionFrontEnd is IAuthorizedTokenTransferer {

    mapping (address => bool) activeSubs;

    function createFixedRateSubscription(
        address payee,
        address token, 
        uint amount,
        uint interval
    )
        public
        returns (address)
    {
        address payor = msg.sender;
        FixedRateSubscription sub = new FixedRateSubscription(this, payor, payee, token, amount, interval);
        activeSubs[address(sub)] = true;
        return sub;
    }

    function transfer(
        address token, 
        address from, 
        address to, 
        uint amount
    ) 
        public
    {
        require(activeSubs[msg.sender]);
        ERC20 tokenContract = ERC20(token);
        require (tokenContract.allowance(from, address(this)) >= amount, "Token transfer not authorized");
        tokenContract.transferFrom(from, to, amount);
    }

}
