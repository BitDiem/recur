pragma solidity ^0.5.0;

/**
 * @title Receivable
 * @dev Stores an address representing a "payee" i.e. the party that will be receiving funds.
 * Contract allows payee to transfer payee status to another account at any time.
 */
contract Receivable {

    address private _payee;

    event PayeeTransferred(address indexed payee);

    constructor (address payee) internal {
        _setPayee(payee);
    }

    modifier onlyPayee() {
        require(isPayee());
        _;
    }

    function getPayee() public view returns (address) {
        return _payee;
    }

    /**
     * @return true if `msg.sender` is the the current payee.
     */
    function isPayee() public view returns (bool) {
        return msg.sender == _payee;
    }

    /**
     * @dev Transfer the payee address to a new address.  Can only be called by the current payee.
     * @param payee The new address that will receive funds thereafter.
     */
    function transferPayee(address payee) public onlyPayee {
        require(_payee != payee);
        _setPayee(payee);
    }

    function _setPayee(address payee) private {
        require(payee != address(0));
        _payee = payee;
        emit PayeeTransferred(_payee);  
    }

}