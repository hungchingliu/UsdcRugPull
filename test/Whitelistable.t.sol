//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "forge-std/Test.sol";
import "../src/Whitelistable.sol";

contract WhitelistableTest is Test{
    event Whitelisted(address indexed _account);
    event UnWhitelisted(address indexed _account);
    event WhitelisterChanged(address indexed newWhitelister);

    address public owner = makeAddr("owner");
    Whitelistable public whitelistable;

    function setUp() public {
        vm.startPrank(owner);
        whitelistable = new Whitelistable();
        whitelistable.updateWhitelister(owner);
        vm.stopPrank();
    }

    function test_ownerIsWhitelister() public {
        assertEq(whitelistable.whitelister(), owner);
    }

    function test_whitelist() public {
        address bob = makeAddr("bob");

        vm.expectEmit();
        emit Whitelisted(bob);

        vm.prank(owner);
        whitelistable.whitelist(bob);

    }

    function test_unWhitelist() public {
        address bob = makeAddr("bob");

        vm.expectEmit();
        emit Whitelisted(bob);
        emit UnWhitelisted(bob);

        vm.prank(owner);
        whitelistable.whitelist(bob);

        vm.prank(owner);
        whitelistable.unWhitelist(bob);
    }

    function test_updateWhitelister() public {
        address bob = makeAddr("bob");

        vm.expectEmit();
        emit WhitelisterChanged(bob);

        vm.prank(owner);
        whitelistable.updateWhitelister(bob);

        assertEq(whitelistable.whitelister(), bob);
    }
}