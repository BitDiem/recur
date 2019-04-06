pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Secondary.sol";

contract TokenEscrow is Secondary {

    IERC20 private _token;

    event Deposited(address indexed from, uint256 weiAmount);
    event Withdrawn(address indexed to, uint256 weiAmount);

    constructor (IERC20 token) public {
        _token = token;
    }

    function token() public view returns(IERC20) {
        return _token;
    }

    function deposit(address from, uint amount) public onlyPrimary {
        _token.transferFrom(from, address(this), amount);
        emit Deposited(from, amount);
    }

    function withdrawTo(address to, uint amount) public onlyPrimary {
        _token.transfer(to, amount);
        emit Withdrawn(to, amount);
    }

}