// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract VendingMachineV1 is Initializable, OwnableUpgradeable {
    // these state variables and their values
    // will be preserved forever, regardless of upgrading
    uint256 public numSodas;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialOwner, uint256 _numSodas) public initializer {
        numSodas = _numSodas;
        __Ownable_init(_initialOwner);
    }

    function purchaseSoda() public payable {
        require(msg.value >= 1000 wei, "You must pay 1000 wei for a soda!");
        numSodas--;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(owner() != newOwner);
        super.transferOwnership(newOwner);
    }

    function renounceOwnership() public override onlyOwner {
        super.renounceOwnership(); // supress `Function state mutability can be restricted to view` warning
        revert("No");
    }
}
