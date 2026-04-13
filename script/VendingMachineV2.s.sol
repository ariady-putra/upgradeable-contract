// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {VendingMachineV2} from "../src/VendingMachineV2.sol";

contract VendingMachineV2Script is Script {
    VendingMachineV2 public vendingMachine;
    uint256 public numSodas;

    address public proxy;
    address public admin;

    function setUp() public {
        admin = vm.envAddress("ADMIN_ADDRESS");
        proxy = vm.promptAddress("Proxy Address");
        numSodas = VendingMachineV2(proxy).numSodas();
    }

    function run() public {
        vm.startBroadcast(admin);

        Upgrades.upgradeProxy(
            proxy, "VendingMachineV2.sol", abi.encodeCall(VendingMachineV2.reinitialize, (numSodas + 1))
        );

        vm.stopBroadcast();

        address implementation = Upgrades.getImplementationAddress(proxy);
        console.log("Implementation Address", implementation);
    }
}
