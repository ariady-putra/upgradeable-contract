// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {UnsafeUpgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {VendingMachineV1} from "../src/VendingMachineV1.sol";

contract VendingMachineV1Test is Test {
    VendingMachineV1 public vendingMachine;
    address admin = address(this);

    function setUp() public {
        VendingMachineV1 impl = new VendingMachineV1();
        bytes memory init = abi.encodeCall(impl.initialize, (admin, 100)); // numSodas
        address proxy = UnsafeUpgrades.deployTransparentProxy(address(impl), admin, init);

        vendingMachine = VendingMachineV1(proxy);
    }

    function testFuzz_PurchaseSoda(address buyer, uint256 pay) public {
        vm.assume(address(this) != buyer && address(vendingMachine) != buyer);

        uint256 initialBalance = address(vendingMachine).balance;
        uint256 numSodas = vendingMachine.numSodas();

        vm.deal(buyer, pay);
        vm.prank(buyer);

        if (pay < 1000 wei) {
            vm.expectRevert("You must pay 1000 wei for a soda!");

            vendingMachine.purchaseSoda{value: pay}();

            assertEq(address(vendingMachine).balance, initialBalance);
            assertEq(vendingMachine.numSodas(), numSodas);
        } else {
            vendingMachine.purchaseSoda{value: pay}();

            assertEq(address(vendingMachine).balance, initialBalance + pay);
            assertEq(vendingMachine.numSodas(), numSodas - 1);
        }
    }
}
