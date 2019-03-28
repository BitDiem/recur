pragma solidity ^0.5.0;

/**
 * @title Payable
 * @dev Stores a an address representing a "payor" i.e. an account payments will be made from.  
 * Contract allows the payor to transfer that obligation to another address pending an approval 
 * function call from that address.
 * Payor mutability is implemented using a request -> accept model.
 */
contract Payable {

    address private _payor;
    address private _pendingPayor;

    event PayorTransferRequested(address indexed requestedPayor);
    event PayorTransferred(address indexed approvedPayor);

    constructor (address payor) internal {
        _setPayor(payor);
    }

    modifier onlyPayor() {
        require(_payor == msg.sender);
        _;
    }

    modifier onlyPendingPayor() {
        require(_pendingPayor == msg.sender);
        _;
    }

    function getPayor() public view returns (address) {
        return _payor;
    }

    /**
     * @dev Begin the process of transferring the paying address to another address.  Can only be called by the current payor.
     * @param pendingPayor The new address that will take over the responsibility of paying.
     */
    function transferPayor(address pendingPayor) public onlyPayor {
        _setPendingPayor(pendingPayor);
    }

    /**
     * @dev Accepts the responsibility of being the new paying address.  Can only be called by 
     * the current pendingPayor, which must have been set in a prior call to transferPayor.
     */
    function approveTransferPayor() public onlyPendingPayor {
        _setPayor(_pendingPayor);
        delete _pendingPayor;
    }

    function _setPayor(address payor) private {
        require(payor != address(0));
        _payor = payor;
        emit PayorTransferred(_payor);
    }

    function _setPendingPayor(address pendingPayor) private {
        require(pendingPayor != address(0));
        require(pendingPayor != _pendingPayor);
        require(pendingPayor != _payor);
        _pendingPayor = pendingPayor;
        emit PayorTransferRequested(pendingPayor);
    }

}