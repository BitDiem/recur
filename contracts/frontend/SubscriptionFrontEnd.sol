pragma solidity ^0.5.0;

import "../accounts/AuthorizedTokenTransferer.sol";
import "../terms/SubscriptionRecurringPaymentTerms.sol";
import "../StandardSubscription.sol";

contract SubscriptionFrontEnd is AuthorizedTokenTransferer {

    mapping (address => bool) activeSubs;

    function createFixedRateSubscription(
        address payee,
        address paymentToken, 
        uint paymentAmount,
        uint interval,
        uint delay
    )
        public
        returns (address)
    {
        address payor = msg.sender;
        IAuthorizedTokenTransferer authorizedTokenTransferer = this;

        SubscriptionRecurringPaymentTerms paymentTerms = new SubscriptionRecurringPaymentTerms(
            paymentAmount, 
            interval, 
            delay
        );

        StandardSubscription sub = new StandardSubscription(
            payor,
            payee,
            authorizedTokenTransferer, 
            paymentToken, 
            paymentTerms);

        _whitelistedCallers[address(sub)] = true;
        return address(sub);
    }

}