//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./FiatTokenV2_1.sol";

import { Whitelistable } from "./Whitelistable.sol";


contract FiatTokenV3 is FiatTokenV2_1, Whitelistable {
    using SafeMath for uint256;

    function transfer(address to, uint256 value)
        external
        override(FiatTokenV1, IERC20)
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        onlyWhitelisted(msg.sender)
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        override(FiatTokenV1, IERC20)
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(from)
        notBlacklisted(to)
        onlyWhitelisted(from)
        returns (bool)
    {
        require(
            value <= allowed[from][msg.sender],
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(from, to, value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        return true;
    }

    function mint(address _to, uint256 _amount)
        external
        override(FiatTokenV1)
        whenNotPaused
        notBlacklisted(msg.sender)
        notBlacklisted(_to)
        onlyWhitelisted(msg.sender)
        returns (bool)
    {
        require(_to != address(0), "FiatToken: mint to the zero address");
        require(_amount > 0, "FiatToken: mint amount not greater than 0");

        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(msg.sender, _to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
    
}


