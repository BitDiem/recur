pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

/**
 * @title CreditAdminRole
 * @dev CreditAdmin accounts are allowed to modify the stored credit value in PaymentCredit.sol
 *
 * NOTE: code is an exact copy of the standard Open Zeppelin implementation of a Role contract.
 * See any of the contracts in the "openzeppelin-solidity/contracts/access/roles" folder as examples.
 */
contract CreditAdminRole {

    using Roles for Roles.Role;

    event CreditAdminAdded(address indexed account);
    event CreditAdminRemoved(address indexed account);

    Roles.Role private _creditAdmins;

    constructor () internal {
        _addCreditAdmin(msg.sender);
    }

    modifier onlyCreditAdmin() {
        require(isCreditAdmin(msg.sender));
        _;
    }

    function isCreditAdmin(address account) public view returns (bool) {
        return _creditAdmins.has(account);
    }

    function addCreditAdmin(address account) public onlyCreditAdmin {
        _addCreditAdmin(account);
    }

    function renounceCreditAdmin() public {
        _removeCreditAdmin(msg.sender);
    }

    function _addCreditAdmin(address account) internal {
        _creditAdmins.add(account);
        emit CreditAdminAdded(account);
    }

    function _removeCreditAdmin(address account) internal {
        _creditAdmins.remove(account);
        emit CreditAdminRemoved(account);
    }

}