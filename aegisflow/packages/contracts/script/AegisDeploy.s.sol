// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {AegisAccount} from "../src/AegisAccount.sol";
import {DemoTarget} from "../src/DemoTarget.sol";

contract AegisDeploy is Script {
    function run() external {
        uint256 pk = vm.envUint("DEPLOYER_KEY");
        vm.startBroadcast(pk);
        address owner = vm.envAddress("ACCOUNT_OWNER");
        AegisAccount account = new AegisAccount(owner);
        DemoTarget target = new DemoTarget();
        // fund account with some ETH for value-based calls later
        (bool ok, ) = address(account).call{value: 1 ether}("");
        require(ok, "fund fail");
        vm.stopBroadcast();

        console2.log("AegisAccount:", address(account));
        console2.log("DemoTarget:", address(target));
    }

    receive() external payable {}
}
