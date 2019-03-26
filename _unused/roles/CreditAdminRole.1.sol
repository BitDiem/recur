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

    mapping (address => Roles.Role) bearer;

    //Roles.Role private _creditAdmins;

    constructor () internal {
        _addCreditAdmin(msg.sender, msg.sender);  // this won't work in most cases.  problem
    }

    /*modifier onlyCreditAdmin() {
        require(isCreditAdmin(msg.sender));
        _;
    }*/

    function requireCreditAdmin(address key) view internal {
        require(isCreditAdmin(key, msg.sender));
    }

    function isCreditAdmin(address key, address account) public view returns (bool) {
        return bearer[key].has(account);
    }

    function addCreditAdmin(address key, address account) public {
        requireCreditAdmin(key);
        _addCreditAdmin(key, account);
    }

    function renounceCreditAdmin(address key) public {
        _removeCreditAdmin(key, msg.sender);
    }

    function _addCreditAdmin(address key, address account) internal {
        bearer[key].add(account);
        emit CreditAdminAdded(account);
    }

    function _removeCreditAdmin(address key, address account) internal {
        bearer[key].remove(account);
        emit CreditAdminRemoved(account);
    }

}