pragma solidity ^0.5.0;

import "../accounts/AuthorizedTokenTransferer.sol";
import "../StandardSubscription.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract SubscriptionFactory {

    event SubscriptionCreated(
        StandardSubscription subscription,
        PaymentObligation paymentTerms,
        IERC20 paymentToken,
        address payor, 
        address payee
    );

    function createSubscription(
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        IERC20 paymentToken,
        PaymentObligation paymentTerms
    ) 
        public
        returns (StandardSubscription)
    {
        StandardSubscription subscription = new StandardSubscription(
            payor,
            payee,
            authorizedTransferer, 
            paymentToken, 
            paymentTerms);

        subscription.addCreditAdmin(msg.sender);
        subscription.renounceCreditAdmin();

        subscription.addTokenWithdrawer(msg.sender);
        subscription.renounceTokenWithdrawer();

        emit SubscriptionCreated(subscription, paymentTerms, paymentToken, payor, payee);

        return subscription;
    }

}