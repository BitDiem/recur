pragma solidity ^0.5.0;

/**
 * @title Receivable
 * @dev Encapsulates a payee, and allows that payee to transfer payee status to 
 * another account
 */
contract Receivable {

    address private _payee;

    event PayeeTransferred(address indexed payee);

    constructor (address payee) internal {
        _setPayee(payee);
    }

    modifier onlyPayee() {
        require(_payee == msg.sender);
        _;
    }

    function getPayee() public view returns (address) {
        return _payee;
    }

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