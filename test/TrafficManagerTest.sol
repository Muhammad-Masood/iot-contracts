// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import {TrafficManagement} from "../src/TrafficManager.sol";

/// @title TrafficManagementContract Test
/// @notice Tests for TrafficManagementContract
contract TrafficManagementTest is Test {
    TrafficManagement public trafficContract;

    function setUp() public {
        trafficContract = new TrafficManagement();
    }

    function testRecordTrafficData_LessThanThreshold() public {
        uint256 sensorId = 1;
        uint256 congestionLevel = 50; // Below threshold

        vm.expectEmit(true, true, true, true);
        emit TrafficManagement.TrafficDataRecorded(
            sensorId,
            congestionLevel,
            block.timestamp
        );

        trafficContract.recordTrafficData(sensorId, congestionLevel);

        (
            uint256 storedSensorId,
            uint256 storedCongestionLevel,

        ) = trafficContract.sensors(sensorId);
        assertEq(storedSensorId, sensorId);
        assertEq(storedCongestionLevel, congestionLevel);
    }

    function testRecordTrafficData_AboveThreshold() public {
        uint256 sensorId = 2;
        uint256 congestionLevel = 80; // Above threshold

        vm.expectEmit(true, true, true, true);
        emit TrafficManagement.TrafficDataRecorded(
            sensorId,
            congestionLevel,
            block.timestamp
        );

        vm.expectEmit(true, true, true, true);
        emit TrafficManagement.CongestionAlert(
            sensorId,
            congestionLevel,
            block.timestamp
        );

        trafficContract.recordTrafficData(sensorId, congestionLevel);

        (, uint256 storedCongestionLevel, ) = trafficContract.sensors(sensorId);
        assertEq(storedCongestionLevel, congestionLevel);
    }

    function testUpdateCongestionThreshold() public {
        uint256 newThreshold = 60;

        trafficContract.updateCongestionThreshold(newThreshold);

        assertEq(trafficContract.congestionThreshold(), newThreshold);
    }

    function testUnauthorizedRecordTrafficData() public {
        address attacker = address(0xDEAD);
        vm.prank(attacker);

        vm.expectRevert("Not authorized");
        trafficContract.recordTrafficData(3, 75);
    }
}
