// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {UnsafeUpgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {VendingMachineV1} from "../src/VendingMachineV1.sol";
import {VendingMachineV2} from "../src/VendingMachineV2.sol";

contract VendingMachineV2Test is Test {
    VendingMachineV2 public vendingMachine;
    address admin = address(this);
    bool acceptPay = true;

    receive() external payable {
        require(acceptPay);
    }

    function setUp() public {
        VendingMachineV1 implV1 = new VendingMachineV1();
        bytes memory initV1 = abi.encodeCall(implV1.initialize, (admin, 100)); // numSodas
        address proxy = UnsafeUpgrades.deployTransparentProxy(address(implV1), admin, initV1);

        VendingMachineV2 implV2 = new VendingMachineV2();
        bytes memory initV2 = abi.encodeCall(implV2.reinitialize, (VendingMachineV1(proxy).numSodas() + 1));
        UnsafeUpgrades.upgradeProxy(proxy, address(implV2), initV2);

        vendingMachine = VendingMachineV2(proxy);
    }

    function testFuzz_PurchaseSoda(address buyer, uint16 pay) public {
        vm.assume(buyer != admin);

        uint256 initialBalance = address(vendingMachine).balance;
        uint256 numSodas = vendingMachine.numSodas();

        hoax(buyer, pay);

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

    function testFuzz_WithdrawProfits(address buyer, uint16 pay) public {
        vm.assume(address(vendingMachine) != buyer && buyer != admin);

        uint256 adminInitialBalance = address(admin).balance;

        testFuzz_PurchaseSoda(buyer, pay);

        uint256 vendingMachineBalance = address(vendingMachine).balance;

        if (vendingMachineBalance <= 0) vm.expectRevert("Profits must be greater than 0 in order to withdraw!");

        vendingMachine.withdrawProfits();

        assertEq(address(vendingMachine).balance, 0);
        assertEq(address(admin).balance, adminInitialBalance + vendingMachineBalance);
    }

    function testFuzz_RejectWhen_FailedToSendEther(address buyer, uint16 pay) public {
        vm.assume(address(vendingMachine) != buyer && buyer != admin && pay > 1000 wei);

        uint256 adminInitialBalance = address(admin).balance;

        testFuzz_PurchaseSoda(buyer, pay);

        uint256 vendingMachineBalance = address(vendingMachine).balance;

        acceptPay = false;
        vm.expectRevert("Failed to send ether");
        vendingMachine.withdrawProfits();
        acceptPay = true;

        assertEq(address(vendingMachine).balance, vendingMachineBalance);
        assertEq(address(admin).balance, adminInitialBalance);
    }
}
