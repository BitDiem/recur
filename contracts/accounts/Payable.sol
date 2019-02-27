pragma solidity ^0.5.4;

/**
 * @title Payable
 * @dev Encapsulates a payor, and allows them to transfer that obligation to 
 * another party pending that party's approval
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

    function transferPayor(address pendingPayor) public onlyPayor {
        _setPendingPayor(pendingPayor);
    }

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
        _pendingPayor = pendingPayor;
        emit PayorTransferRequested(pendingPayor);
    }

}