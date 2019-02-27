pragma solidity ^0.5.0;

import "../frontend/SubscriptionFactory.sol";
import "../accounts/AuthorizedTokenTransferer.sol";

contract PublisherFactory {

    event PublisherCreated(SubscriptionFactory factory);

    function createPublisher(address defaultReceivingAddress) public returns (SubscriptionFactory) {
        return createPublisher(new AuthorizedTokenTransferer(), defaultReceivingAddress);
    }

    function createPublisher(
        AuthorizedTokenTransferer defaultAuthorizedTransferer,
        address defaultReceivingAddress
    )
        public
        returns (SubscriptionFactory)
    {
        require(defaultReceivingAddress != address(0));

        SubscriptionFactory factory = new SubscriptionFactory(
            defaultAuthorizedTransferer,
            defaultReceivingAddress
        );

        emit PublisherCreated(factory);
        return factory;
    }

}