// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {WasteManagement} from "../src/WasteManager.sol";

contract WasteManagerDeploy is Script {
    WasteManagement public wasteManagement;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        wasteManagement = new WasteManagement();
        vm.stopBroadcast();
    }
}
