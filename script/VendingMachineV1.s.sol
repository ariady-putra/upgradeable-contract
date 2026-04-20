// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {VendingMachineV1} from "../src/VendingMachineV1.sol";

contract VendingMachineV1Script is Script {
    address public admin;
    uint256 public numSodas;

    function setUp() public {
        admin = vm.envAddress("ADMIN_ADDRESS");
        numSodas = vm.promptUint("Num sodas");
    }

    function run() public {
        vm.startBroadcast(admin);

        address proxy = Upgrades.deployTransparentProxy(
            "VendingMachineV1.sol", admin, abi.encodeCall(VendingMachineV1.initialize, (admin, numSodas))
        );

        vm.stopBroadcast();

        address impl = Upgrades.getImplementationAddress(proxy);
        address proxyAdmin = Upgrades.getAdminAddress(proxy);

        console.log("Proxy Address:", proxy);
        console.log("Impl. Address:", impl);

        console.log("Proxy Admin Address", proxyAdmin);
        console.log("Admin Address", admin);
    }
}
