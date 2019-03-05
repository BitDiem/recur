pragma solidity ^0.5.0;

import "../frontend/SubscriptionFactory.sol";
import "../accounts/AuthorizedTokenTransferer.sol";
import "../terms/FixedInterval.sol";
import "../terms/Monthly.sol";
import "../terms/MultiMonthly.sol";
import "../terms/Yearly.sol";
import "../StandardSubscription.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract SubscriptionFrontEnd {

    SubscriptionFactory private _subscriptionFactory;
    AuthorizedTokenTransferer private _tokenTransferer;

    constructor (SubscriptionFactory subscriptionFactory, AuthorizedTokenTransferer tokenTransferer) public {
        _subscriptionFactory = subscriptionFactory;
        _tokenTransferer = tokenTransferer;
    }

    event SubscriptionCreated(
        StandardSubscription subscriptionAddress,
        PaymentObligation paymentTerms,
        IERC20 paymentToken,
        address payor, 
        address payee
    );

    function getTokenTransferer() public view returns (AuthorizedTokenTransferer) {
        return _tokenTransferer;
    }

    function createMonthlySubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay
    )
        public
        returns (StandardSubscription)
    {
        Monthly paymentTerms = new Monthly(paymentAmount, nextPaymentYear, nextPaymentMonth, nextPaymentDay);
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createMultiMonthlySubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay,
        uint monthIncrement
    )
        public
        returns (StandardSubscription)
    {
        MultiMonthly paymentTerms = new MultiMonthly(paymentAmount, nextPaymentYear, nextPaymentMonth, nextPaymentDay, monthIncrement);
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createYearlySubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint nextPaymentYear,
        uint nextPaymentMonth,
        uint nextPaymentDay
    )
        public
        returns (StandardSubscription)
    {
        Yearly paymentTerms = new Yearly(paymentAmount, nextPaymentYear, nextPaymentMonth, nextPaymentDay);
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createFixedIntervalSubscription(
        address payee,
        IERC20 paymentToken, 
        uint paymentAmount,
        uint interval,
        uint delay
    )
        public
        returns (StandardSubscription)
    {
        FixedInterval paymentTerms = new FixedInterval(paymentAmount, interval, delay);
        return _createSubscription2(payee, paymentToken, paymentTerms);
    }

    function createSubscription(
        address payee,
        IERC20 paymentToken, 
        PaymentObligation paymentTerms
    )
        public
        returns (StandardSubscription)
    {
        address payor = msg.sender;

        StandardSubscription subscription = _subscriptionFactory.createSubscription(
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
        _tokenTransferer.addWhitelisted(subscriptionAddress);

        emit SubscriptionCreated(subscription, paymentTerms, paymentToken, payor, payee);

        return subscription;
    }

    function _createSubscription2(
        address payee,
        IERC20 paymentToken,
        PaymentObligation paymentTerms
    )
        private
        returns (StandardSubscription)
    {
        StandardSubscription subscription = createSubscription(payee, paymentToken, paymentTerms);
        paymentTerms.transferPrimary(address(subscription));
        return subscription;
    }

}