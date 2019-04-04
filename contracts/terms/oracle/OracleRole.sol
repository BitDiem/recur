pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

/**
 * @title OracleRole
 * @dev Oracle accounts are allowed to push payment due data to OracleTerms.sol
 *
 * NOTE: code is an exact copy of the standard Open Zeppelin implementation of a Role contract.
 * See any of the contracts in the "openzeppelin-solidity/contracts/access/roles" folder as examples.
 */
contract OracleRole {

    using Roles for Roles.Role;

    event OracleAdded(address indexed account);
    event OracleRemoved(address indexed account);

    Roles.Role private _accounts;

    constructor () internal {
        _addAccount(msg.sender);
    }

    modifier onlyOracle() {
        require(isOracle(msg.sender));
        _;
    }

    function isOracle(address account) public view returns (bool) {
        return _accounts.has(account);
    }

    function addOracle(address account) public onlyOracle {
        _addAccount(account);
    }

    function renounceOracle() public {
        _removeAccount(msg.sender);
    }

    function _addAccount(address account) internal {
        _accounts.add(account);
        emit OracleAdded(account);
    }

    function _removeAccount(address account) internal {
        _accounts.remove(account);
        emit OracleRemoved(account);
    }

}