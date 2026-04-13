// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {VendingMachineV1} from "../src/VendingMachineV1.sol";

contract VendingMachineV1Script is Script {
    VendingMachineV1 public vendingMachine;
    uint256 public numSodas;

    address public initialOwnerAddressForProxyAdmin;

    function setUp() public {
        initialOwnerAddressForProxyAdmin = vm.envAddress("ADMIN_ADDRESS");
        numSodas = 100;
    }

    function run() public {
        vm.startBroadcast(initialOwnerAddressForProxyAdmin);

        address proxy = Upgrades.deployTransparentProxy(
            "VendingMachineV1.sol",
            initialOwnerAddressForProxyAdmin,
            abi.encodeCall(VendingMachineV1.initialize, (numSodas))
        );

        vm.stopBroadcast();

        address admin = Upgrades.getAdminAddress(proxy);
        address implementation = Upgrades.getImplementationAddress(proxy);

        console.log("Proxy Address", proxy);
        console.log("Implementation Address", implementation);

        console.log("Admin Address", initialOwnerAddressForProxyAdmin);
        console.log("Proxy Admin Address", admin);
    }
}
