//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "forge-std/Test.sol";
import "../src/FiatTokenV3.sol";

contract FiatTokenV3Test is Test {
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob   = makeAddr("bob");
    
    FiatTokenV3 fiatTokenV3;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed minter, address indexed to, uint256 amount);

    function setUp() public {
        vm.startPrank(owner);
        fiatTokenV3 = new FiatTokenV3();
        fiatTokenV3.updateWhitelister(owner);
        vm.stopPrank();
    }

    function test_callTransferWithWhitelistedAccount() public {
        uint256 depositValue = 1 ether;
        uint256 transferValue = 0.5 ether;
        deal(address(fiatTokenV3), alice, depositValue);

        vm.prank(owner);
        fiatTokenV3.whitelist(alice);

        vm.expectEmit();
        emit Transfer(alice, bob, transferValue); 
        vm.prank(alice);
        fiatTokenV3.transfer(bob, transferValue);
        assertEq(fiatTokenV3.balanceOf(alice), depositValue - transferValue);
        assertEq(fiatTokenV3.balanceOf(bob), transferValue);
    }

    function test_calltransferFromWithWhitelistedAccount() public {
        uint256 depositValue = 1 ether;
        uint256 approveValue = 0.5 ether;
        uint256 transferValue = 0.5 ether;
        deal(address(fiatTokenV3), alice, depositValue);

        vm.prank(owner);
        fiatTokenV3.whitelist(alice);

        vm.expectEmit();
        emit Transfer(alice, bob, transferValue); 
        vm.startPrank(alice);
        fiatTokenV3.approve(alice, approveValue);   // usdc has to approve yourself for using your own balance
        fiatTokenV3.transferFrom(alice, bob, transferValue);
        vm.stopPrank();
        assertEq(fiatTokenV3.balanceOf(alice), depositValue - transferValue);
        assertEq(fiatTokenV3.balanceOf(bob), transferValue);
    }

    function test_callMintWithWhitelistedAccount() public {
        uint256 mintValue = 1 ether;

        vm.prank(owner);
        fiatTokenV3.whitelist(alice);

        vm.expectEmit();
        emit Mint(alice, alice, mintValue);
        
        vm.prank(alice);
        fiatTokenV3.mint(alice, mintValue);
        assertEq(fiatTokenV3.balanceOf(alice), mintValue);
        assertEq(fiatTokenV3.totalSupply(), mintValue); 
    }

    function test_RevertIf_NotWhitelistedAccountCallTransfer() public {
        uint256 depositValue = 1 ether;
        uint256 transferValue = 0.5 ether;
        deal(address(fiatTokenV3), alice, depositValue);

        vm.expectRevert(bytes("Whitelistable: account is not in whitelist"));
        vm.prank(alice);
        fiatTokenV3.transfer(bob, transferValue);
    }

    function test_RevertIf_NotWhitelistedAccountCallTransferFrom() public {
        uint256 depositValue = 1 ether;
        uint256 approveValue = 0.5 ether;
        uint256 transferValue = 0.5 ether;
        deal(address(fiatTokenV3), alice, depositValue);

        vm.startPrank(alice);
        fiatTokenV3.approve(alice, approveValue);   // usdc has to approve yourself for using your own balance
        vm.expectRevert(bytes("Whitelistable: account is not in whitelist"));
        fiatTokenV3.transferFrom(alice, bob, transferValue);
        vm.stopPrank();
    }

    function test_RevertIf_NotWhitelistedAccountCallMint() public {
        uint256 mintValue = 1 ether;

        vm.expectRevert(bytes("Whitelistable: account is not in whitelist"));
        vm.prank(alice);
        fiatTokenV3.mint(alice, mintValue);
    }

}