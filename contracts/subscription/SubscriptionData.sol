pragma solidity ^0.5.0;

import "../terms/PaymentObligation.sol";
import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title SubscriptionData
 * @dev Readonly data fields required for Subscription logic
 */
contract SubscriptionData {

    PaymentObligation private _paymentObligation;
    IERC20 private _token;
    IAuthorizedTokenTransferer private _authorizedTransferer;

    constructor (
        PaymentObligation paymentObligation,
        IERC20 token,
        IAuthorizedTokenTransferer authorizedTransferer
    ) 
        internal
    {
        _paymentObligation = paymentObligation;
        _token = token;
        _authorizedTransferer = authorizedTransferer;
    }

    function getPaymentObligation() public view returns (PaymentObligation) {
        return _paymentObligation;
    }

    function getToken() public view returns (IERC20) {
        return _token;
    }

    function getAuthorizedTransferer() public view returns (IAuthorizedTokenTransferer) {
        return _authorizedTransferer;
    }

}