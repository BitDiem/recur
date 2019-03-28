pragma solidity ^0.5.0;

import "../frontend/SubscriptionFrontEnd.sol";
import "../accounts/AuthorizedTokenTransferer.sol";

/**
 * @title PublisherFrontEnd
 * @dev Singleton contract for creating new instances of a SubscriptionFrontEnd, which represents a publisher 
 * or service provider (i.e. the party offering subscriptions).
 */
contract PublisherFrontEnd {

    event PublisherCreated(
        SubscriptionFrontEnd publisher, 
        AuthorizedTokenTransferer authorizedTokenTransferer
    );

    /**
     * @dev Creates a new publisher with a new AuthorizedTokenTransferer.  Wires the two together correctly by 
     * adding the SubscriptionFrontEnd to the AuthorizedTokenTransferer caller whitelist.
     * @return The newly created SubscriptionFrontEnd.
     */
    function createPublisher() public returns (SubscriptionFrontEnd) {
        AuthorizedTokenTransferer authorizedTokenTransferer = new AuthorizedTokenTransferer();
        SubscriptionFrontEnd subscriptionFrontEnd = createPublisher(authorizedTokenTransferer);
        authorizedTokenTransferer.addWhitelistAdmin(address(subscriptionFrontEnd));
        authorizedTokenTransferer.renounceWhitelistAdmin();
        return subscriptionFrontEnd;
    }

    /**
     * @dev Create a publisher using a previously created AuthorizedTokenTransferer.  Users will be able to 
     * use the new SubscriptionFrontEnd without having to re-authorize a new AuthorizedTokenTransferer.
     * @param authorizedTransferer The token transfer proxy used to transfer tokens from subscriber to service provider.
     * @return The newly created SubscriptionFrontEnd.  Make sure to call addWhitelistAdmin on the token transferer 
     * to ensure proper functionality of the SubscriptionFrontEnd.
     */
    function createPublisher(
        AuthorizedTokenTransferer authorizedTransferer
    )
        public
        returns (SubscriptionFrontEnd)
    {
        SubscriptionFrontEnd frontEnd = new SubscriptionFrontEnd(authorizedTransferer);
        emit PublisherCreated(frontEnd, authorizedTransferer);
        return frontEnd;
    }

}