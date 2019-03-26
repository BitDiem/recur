pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

/**
 * @title AuthorizedCallerRole
 * @dev TODO: write
 */
contract AuthorizedCallerRole {

    using Roles for Roles.Role;

    event AuthorizedCallerAdded(address indexed account);
    event AuthorizedCallerRemoved(address indexed account);

    Roles.Role private _authorizedCallers;

    constructor () internal {
        _addAuthorizedCaller(msg.sender);
    }

    modifier onlyAuthorizedCaller() {
        require(isAuthorizedCaller(msg.sender), "Only authorized addresses can call function");
        _;
    }

    function isAuthorizedCaller(address account) public view returns (bool) {
        return _authorizedCallers.has(account);
    }

    function addAuthorizedCaller(address account) public onlyAuthorizedCaller {
        _addAuthorizedCaller(account);
    }

    function renounceAuthorizedCaller() public {
        _removeAuthorizedCaller(msg.sender);
    }

    function _addAuthorizedCaller(address account) internal {
        _authorizedCallers.add(account);
        emit AuthorizedCallerAdded(account);
    }

    function _removeAuthorizedCaller(address account) internal {
        _authorizedCallers.remove(account);
        emit AuthorizedCallerRemoved(account);
    }

}