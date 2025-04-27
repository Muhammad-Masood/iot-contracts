// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import {WasteManagement} from "../src/WasteManager.sol";

/// @title WasteManagementContract Test
/// @notice Tests core functionalities of WasteManagementContract
contract WasteManagementTest is Test {
    WasteManagement public wasteManagement;

    function setUp() public {
        wasteManagement = new WasteManagement();
    }

    function testRecordBinData_LessThanThreshold() public {
        uint256 binId = 1;
        uint256 fillLevel = 50; // 50% fill

        vm.expectEmit(true, true, true, true);
        emit WasteManagement.BinDataRecorded(binId, fillLevel, block.timestamp);

        wasteManagement.recordBinData(binId, fillLevel);

        (uint256 storedBinId, uint256 storedFillLevel, ) = wasteManagement.bins(
            binId
        );
        assertEq(storedBinId, binId);
        assertEq(storedFillLevel, fillLevel);
    }

    function testRecordBinData_AboveThreshold() public {
        uint256 binId = 2;
        uint256 fillLevel = 95; // 95% fill

        vm.expectEmit(true, true, true, true);
        emit WasteManagement.BinDataRecorded(binId, fillLevel, block.timestamp);

        vm.expectEmit(true, true, true, true);
        emit WasteManagement.BinFullAlert(binId, fillLevel, block.timestamp);

        wasteManagement.recordBinData(binId, fillLevel);

        (, uint256 storedFillLevel, ) = wasteManagement.bins(binId);
        assertEq(storedFillLevel, fillLevel);
    }

    function testUpdateFillThreshold() public {
        uint256 newThreshold = 85;

        wasteManagement.updateFillThreshold(newThreshold);

        assertEq(wasteManagement.fillThreshold(), newThreshold);
    }

    function testUnauthorizedRecordBinData() public {
        address attacker = address(0xBEEF);
        vm.prank(attacker);

        vm.expectRevert("Not authorized");
        wasteManagement.recordBinData(3, 70);
    }
}
