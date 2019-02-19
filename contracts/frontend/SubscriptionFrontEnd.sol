pragma solidity ^0.5.0;

import "../accounts/AuthorizedTokenTransferer.sol";
import "../terms/RecurringPaymentTerms.sol";
import "../StandardSubscription.sol";

contract SubscriptionFrontEnd {

    AuthorizedTokenTransferer _tokenTransferer;

    constructor (AuthorizedTokenTransferer tokenTransferer) public {
        if (address(tokenTransferer) == address(0)) {
            _tokenTransferer = new AuthorizedTokenTransferer();
        } else {
            _tokenTransferer = tokenTransferer;
        }
    }

    event SubscriptionCreated(address subscriptionAddress, address payor, address payee);

    function createFixedPeriodSubscription(
        address payee,
        address paymentToken, 
        uint paymentAmount,
        uint interval,
        uint delay
    )
        public
        returns (address)
    {
        RecurringPaymentTerms paymentTerms = new RecurringPaymentTerms(
            paymentAmount, 
            interval, 
            delay
        );

        address subscriptionAddress = createSubscription(payee, paymentToken, paymentTerms);
        paymentTerms.transferPrimary(subscriptionAddress);

        return subscriptionAddress;
    }

    function createSubscription(
        address payee,
        address paymentToken, 
        PaymentObligation paymentTerms
    )
        public
        returns (address)
    {
        address payor = msg.sender;

        StandardSubscription subscription = new StandardSubscription(
            payor,
            payee,
            _tokenTransferer, 
            paymentToken, 
            paymentTerms);

        subscription.addCreditAdmin(payee);
        subscription.renounceCreditAdmin();

        subscription.addTokenWithdrawer(payor);
        subscription.renounceTokenWithdrawer();

        address subscriptionAddress = address(subscription);
        _tokenTransferer.addToWhitelist(subscriptionAddress);

        emit SubscriptionCreated(subscriptionAddress, payor, payee);

        return subscriptionAddress;
    }

}