pragma solidity ^0.5.0;

import "./IAuthorizedTokenTransferer.sol";
import "./Payable.sol";
import "./Receivable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/ownership/Secondary.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title SubscriptionPaymentInfo
 * @dev Encapsulates a relationship between a paying party, recipient, which token 
 * is used as payment, and through what authorized transferer
 */
contract SubscriptionPaymentInfo is Payable, Receivable {

    IAuthorizedTokenTransferer private _authorizedTransferer;
    address private _token;

    constructor (
        address payor,
        address payee,
        IAuthorizedTokenTransferer authorizedTransferer,
        address token
    ) 
        Payable(payor)
        Receivable(payee)
        internal
    {
        _authorizedTransferer = authorizedTransferer;
        _token = token;
    }

    function authorizedTransferer() public view returns (IAuthorizedTokenTransferer) {
        return _authorizedTransferer;
    }

    function token() public view returns (address) {
        return _token;
    }

    function payFromAuthorizedTransferer(
        uint amount
    )
        internal
        returns (uint) 
    {
        if (amount == 0)
            return amount;

        IERC20 tokenContract = IERC20(_token);

        // check how much the transferer is authorized to send on behalf of the payor
        uint authorizedAmount = tokenContract.allowance(getPayor(), address(_authorizedTransferer));
        uint availableBalance = tokenContract.balanceOf(getPayor());
        uint amountToPay = Math.min(amount, Math.min(authorizedAmount, availableBalance));

        _authorizedTransferer.transfer(getPayor(), getPayee(), _token, amountToPay);

        uint remainder = amount - amountToPay;
        return remainder;
    }
}