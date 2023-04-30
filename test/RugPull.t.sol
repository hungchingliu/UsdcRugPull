//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "forge-std/Test.sol";
import "../src/FiatTokenV2_1.sol";
import "../src/FiatTokenV3.sol";

interface FiatTokenProxy {
    function upgradeTo(address newImplementation) external;
}
contract RugPullTest is Test {
    string constant RPC_URL = "https://eth-mainnet.g.alchemy.com/v2/Ea1NmKEyxzz-p3O_4WZFu5apdNXGtV0l";
    address constant FIAT_TOKEN_PROXY_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant OWNER = 0xFcb19e6a322b27c06842A71e8c725399f049AE3a; 
    address constant public ADMIN = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
    
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    FiatTokenProxy fiatTokenProxy;
    FiatTokenV3 fiatTokenV3;
    FiatTokenV3 proxyFiatTokenV3;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed minter, address indexed to, uint256 amount);
    
    function setUp() public {
        // 1. Create Fork from mainnet
        uint256 forkId = vm.createFork(RPC_URL);
        // 2. Switch to the fork we've just created
        vm.selectFork(forkId);
        // 3. Deploy FiatTokenV3
        fiatTokenV3 = new FiatTokenV3();
        // 4. Pretend we are ADMIN, upgrade FiatTokeProxy's logical contract to FiatTokenV3
        fiatTokenProxy = FiatTokenProxy(FIAT_TOKEN_PROXY_ADDRESS);
        vm.prank(ADMIN);
        fiatTokenProxy.upgradeTo(address(fiatTokenV3));
        proxyFiatTokenV3 = FiatTokenV3(address(fiatTokenProxy));
        // 5. Pretend we are OWNER, set bob as whitelister which able to add people to whitelist
        vm.prank(OWNER);
        proxyFiatTokenV3.updateWhitelister(bob);
        // 6. Pretend we are bob, add bob to whitelist
        vm.prank(bob);
        proxyFiatTokenV3.whitelist(bob); 
    }

    function testFork_transferWithWhitelistedAccount() public {
        uint256 depositValue = 1 ether;
        uint256 transferValue = 0.5 ether;
        deal(address(proxyFiatTokenV3), bob, depositValue);

        vm.expectEmit();
        emit Transfer(bob, alice, transferValue);

        vm.prank(bob);
        proxyFiatTokenV3.transfer(alice, transferValue);

        assertEq(proxyFiatTokenV3.balanceOf(bob), depositValue - transferValue);
        assertEq(proxyFiatTokenV3.balanceOf(alice), transferValue);
    }

    function testFork_RevertIf_transferWithUnWhitelistedAccount() public {
        uint256 depositValue = 1 ether;
        uint256 transferValue = 0.5 ether;
        deal(address(proxyFiatTokenV3), alice, depositValue);

        vm.expectRevert(bytes("Whitelistable: account is not in whitelist"));

        vm.prank(alice);
        proxyFiatTokenV3.transfer(bob, transferValue);
    }

    function testFork_transferFromWithWhitelistedAccount() public {
        uint256 depositValue = 1 ether;
        uint256 approveValue = 0.5 ether;
        uint256 transferValue = 0.5 ether;
        deal(address(proxyFiatTokenV3), bob, depositValue);

        vm.expectEmit();
        emit Transfer(bob, alice, transferValue); 
        vm.startPrank(bob);
        proxyFiatTokenV3.approve(bob, approveValue);   // usdc has to approve yourself for using your own balance
        proxyFiatTokenV3.transferFrom(bob, alice, transferValue);
        vm.stopPrank();
        assertEq(proxyFiatTokenV3.balanceOf(bob), depositValue - transferValue);
        assertEq(proxyFiatTokenV3.balanceOf(alice), transferValue);
    }
    
    function testFork_RevertIf_transferFromWithUnWhitelistedAccount() public {
        uint256 depositValue = 1 ether;
        uint256 approveValue = 0.5 ether;
        uint256 transferValue = 0.5 ether;
        deal(address(proxyFiatTokenV3), alice, depositValue);

        vm.startPrank(alice);
        proxyFiatTokenV3.approve(alice, approveValue);   // usdc has to approve yourself for using your own balance
        vm.expectRevert(bytes("Whitelistable: account is not in whitelist"));
        proxyFiatTokenV3.transferFrom(alice, bob, transferValue);
        vm.stopPrank();
    }

    function testFork_MintWithWhitelistedAccount() public {
        uint256 mintValue = 100 ether;
        vm.expectEmit();
        emit Mint(bob, bob, mintValue);
        
        vm.prank(bob);
        proxyFiatTokenV3.mint(bob, mintValue);
        assertEq(proxyFiatTokenV3.balanceOf(bob), mintValue);
    }

    function testFork_RevertIf_MintWithUnWhitelistedAccount() public {
        uint256 mintValue = 100 ether;
        vm.prank(alice);
        vm.expectRevert(bytes("Whitelistable: account is not in whitelist"));
        proxyFiatTokenV3.mint(bob, mintValue);
    }
}