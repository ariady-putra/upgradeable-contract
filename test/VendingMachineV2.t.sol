// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {VendingMachineV2} from "../src/VendingMachineV2.sol";

contract VendingMachineV2Test is Test {
    VendingMachineV2 public vendingMachine;
    address public owner = makeAddr("owner");

    function setUp() public {
        vm.prank(owner);
        vendingMachine = new VendingMachineV2();

        vm.prank(owner);
        vendingMachine.initialize(2000);
    }

    function testFuzz_purchaseSoda(address buyer, uint256 pay) public {
        vm.assume(buyer != owner);

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

    function testFuzz_withdrawProfits(address buyer, uint256 pay) public {
        vm.assume(address(vendingMachine) != buyer && buyer != owner);

        uint256 ownerInitialBalance = address(owner).balance;

        testFuzz_purchaseSoda(buyer, pay);

        uint256 vendingMachineBalance = address(vendingMachine).balance;

        vm.prank(owner);

        if (vendingMachineBalance <= 0) vm.expectRevert("Profits must be greater than 0 in order to withdraw!");

        vendingMachine.withdrawProfits();

        assertEq(address(vendingMachine).balance, 0);
        assertEq(address(owner).balance, ownerInitialBalance + vendingMachineBalance);
    }

    function testReject_withdrawProfits() public {
        vendingMachine = new VendingMachineV2();
        vendingMachine.initialize(2000);

        address _owner = address(this);
        uint256 ownerInitialBalance = address(_owner).balance;

        address buyer = makeAddr("buyer");
        uint256 pay = 1000 wei;
        testFuzz_purchaseSoda(buyer, pay);

        uint256 vendingMachineBalance = address(vendingMachine).balance;

        vm.expectRevert("Failed to send ether");
        vendingMachine.withdrawProfits();

        assertEq(address(vendingMachine).balance, vendingMachineBalance);
        assertEq(address(_owner).balance, ownerInitialBalance);
    }

    function test_reinitialize() public {
        vendingMachine = new VendingMachineV2();
        vendingMachine.initialize(2000);

        vendingMachine.reinitialize(2001);
        assertEq(vendingMachine.numSodas(), 2001);
    }

    function testReject_reinitialize() public {
        vendingMachine = new VendingMachineV2();
        vendingMachine.initialize(2000);

        vm.expectRevert();
        vendingMachine.reinitialize(2000);
    }
}
