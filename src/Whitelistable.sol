//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import { Ownable } from "./FiatTokenV2_1.sol";

contract Whitelistable is Ownable {
    address public whitelister;
    mapping(address => bool) internal whitelisted;

    event Whitelisted(address indexed _account);
    event UnWhitelisted(address indexed _account);
    event WhitelisterChanged(address indexed newWhitelister);

    modifier onlyWhitelister() {
        require(
            msg.sender == whitelister,
            "Whitelistable: callser is not the whitelister"
        );
        _;
    }

    modifier onlyWhitelisted(address _account) {
        require(
            whitelisted[_account],
            "Whitelistable: account is not in whitelist"
        );
        _;
    }

    function whitelist(address _account) external onlyWhitelister {
        whitelisted[_account] = true;
        emit Whitelisted(_account);
    }

    function unWhitelist(address _account) external onlyWhitelister {
        whitelisted[_account] = false;
        emit UnWhitelisted(_account);
    }

    function updateWhitelister(address _newWhitelister) external onlyOwner {
        require(
            _newWhitelister != address(0),
            "Whitelistable: new whitelister is the zero address"
        );
        whitelister = _newWhitelister;
        emit WhitelisterChanged(whitelister);
    }
}
