pragma solidity ^0.5.0;

import "../terms/PaymentObligation.sol";
import "../accounts/IAuthorizedTokenTransferer.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title TokenVestingData
 * @dev Readonly data fields required for TokenVesting logic.
 */
contract TokenVestingData {

    PaymentObligation private _paymentObligation;
    IERC20 private _token;

    constructor (
        PaymentObligation paymentObligation,
        IERC20 token
    ) 
        internal
    {
        _paymentObligation = paymentObligation;
        _token = token;
    }

    function getPaymentObligation() public view returns (PaymentObligation) {
        return _paymentObligation;
    }

    function getToken() public view returns (IERC20) {
        return _token;
    }

}