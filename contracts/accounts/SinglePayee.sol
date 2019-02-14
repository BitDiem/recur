pragma solidity ^0.5.0;

import "../accounts/Receivable.sol";
import "../accounts/IAcceptsPayment.sol";
import "../accounts/IAuthorizedTokenTransferer.sol";

/**
 * @title SinglePayee
 * @dev TODO: write
 */
contract SinglePayee is Receivable, IAcceptsPayment {

    IAuthorizedTokenTransferer _authorizedTransferer;

    constructor (
        address payee, 
        IAuthorizedTokenTransferer authorizedTransferer
    ) 
        public
        Receivable(payee)
    {
        _authorizedTransferer = authorizedTransferer;
    }

    function receiveToken(address from, address token, uint amount) public {
        _authorizedTransferer.transfer(from, getPayee(), token, amount);
    }

}