pragma solidity ^0.5.0;

import "./payment/PaymentProcessor.sol";
import "./payment/PaymentObligation.sol";
import "./payment/PaymentDebt.sol";
import "./payment/escrow/TokenEscrow.sol";
import "./accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract StandardSubscription is PaymentProcessor, PaymentDebt, TokenEscrow {
    
    PaymentObligation private _paymentObligation;

    event SubscriptionEnded(address endedBy);

    constructor (
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        IERC20 token,
        PaymentObligation paymentObligation
    ) 
        PaymentProcessor(payor, payee, authorizedTransferer, token)
        public 
    {
        _paymentObligation = paymentObligation;
    }

    function payFullAmountDue() public {
        uint amountDue = _paymentObligation.currentAmountDue() + getOutstandingAmount();
        uint remainder = pay(amountDue);
        _setOutstandingAmount(remainder);
    }

    function endSubscription() public {
        require(getPayor() == msg.sender || getPayee() == msg.sender);
        emit SubscriptionEnded(msg.sender);
    }

}