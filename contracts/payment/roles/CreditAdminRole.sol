pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

/**
 * @title CreditAdminRole
 * @dev TODO: write
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
        require(isCreditAdmin(msg.sender), "Only credit admins may call");
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