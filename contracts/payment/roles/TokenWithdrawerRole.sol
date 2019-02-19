pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

/**
 * @title TokenWithdrawerRole
 * @dev TODO: write
 */
contract TokenWithdrawerRole {

    using Roles for Roles.Role;

    event TokenWithdrawerAdded(address indexed account);
    event TokenWithdrawerRemoved(address indexed account);

    Roles.Role private _tokenWithdrawers;

    constructor () internal {
        _addTokenWithdrawer(msg.sender);
    }

    modifier onlyTokenWithdrawer() {
        require(isTokenWithdrawer(msg.sender), "Only token withdrawers can call function");
        _;
    }

    function isTokenWithdrawer(address account) public view returns (bool) {
        return _tokenWithdrawers.has(account);
    }

    function addTokenWithdrawer(address account) public onlyTokenWithdrawer {
        _addTokenWithdrawer(account);
    }

    function renounceTokenWithdrawer() public {
        _removeTokenWithdrawer(msg.sender);
    }

    function _addTokenWithdrawer(address account) internal {
        _tokenWithdrawers.add(account);
        emit TokenWithdrawerAdded(account);
    }

    function _removeTokenWithdrawer(address account) internal {
        _tokenWithdrawers.remove(account);
        emit TokenWithdrawerRemoved(account);
    }

}