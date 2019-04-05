pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

/**
 * @title DisputeResolverRole
 * @dev DisputeResolver accounts are allowed to resolve disputes at Dispute.sol
 *
 * NOTE: code is an exact copy of the standard Open Zeppelin implementation of a Role contract.
 * See any of the contracts in the "openzeppelin-solidity/contracts/access/roles" folder as examples.
 */
contract DisputeResolverRole {

    using Roles for Roles.Role;

    event DisputeResolverAdded(address indexed account);
    event DisputeResolverRemoved(address indexed account);

    Roles.Role private _accounts;

    constructor () internal {
        _addAccount(msg.sender);
    }

    modifier onlyDisputeResolver() {
        require(isDisputeResolver(msg.sender));
        _;
    }

    function isDisputeResolver(address account) public view returns (bool) {
        return _accounts.has(account);
    }

    function addDisputeResolver(address account) public onlyDisputeResolver {
        _addAccount(account);
    }

    function renounceDisputeResolver() public {
        _removeAccount(msg.sender);
    }

    function _addAccount(address account) internal {
        _accounts.add(account);
        emit DisputeResolverAdded(account);
    }

    function _removeAccount(address account) internal {
        _accounts.remove(account);
        emit DisputeResolverRemoved(account);
    }

}