// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @custom:oz-upgrades-from VendingMachineV1
contract VendingMachineV2 is Initializable, OwnableUpgradeable {
    // these state variables and their values
    // will be preserved forever, regardless of upgrading
    uint256 public numSodas;

    //      Buyer      Qty
    mapping(address => uint256) public buyers;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _initialOwner, uint256 _numSodas) public initializer {
        numSodas = _numSodas;
        __Ownable_init(_initialOwner);
    }

    /// @custom:oz-upgrades-validate-as-initializer
    function reinitialize(uint256 _numSodas) public reinitializer(2) {
        require(_numSodas > numSodas);
        numSodas = _numSodas;
    }

    function purchaseSoda() public payable {
        require(msg.value >= 1000 wei, "You must pay 1000 wei for a soda!");
        buyers[msg.sender]++;
        numSodas--;
    }

    function withdrawProfits() public onlyOwner {
        require(address(this).balance > 0, "Profits must be greater than 0 in order to withdraw!");
        (bool sent,) = owner().call{value: address(this).balance}("");
        require(sent, "Failed to send ether");
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
