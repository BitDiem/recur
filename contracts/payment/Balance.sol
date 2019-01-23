pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Secondary.sol";

contract Balance is Secondary {

    using SafeMath for uint;

    uint private _val;

    event BalanceUpdated(uint balance);

    function get() public view returns (uint) {
        return _val;
    }

    function set(uint val) public onlyPrimary {
        _setVal(val);
    }

    function add(uint amount) public onlyPrimary {
        require(amount > 0);
        _setVal(_val.add(amount));
    }

    function sub(uint amount) public onlyPrimary {
        require(amount > 0);
        _setVal(_val.sub(amount));
    }

    function _setVal(uint val) internal {
        if(_val == val) return;  
        _val = val;
        emit BalanceUpdated(_val);
    }
}