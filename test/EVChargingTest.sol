// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {EVCharging} from "../src/EVCharging.sol";

/// @title EVCharging Test
/// @notice Tests for EVChargingContract
contract EVChargingTest is Test {
    EVCharging public evContract;
    address user1 = address(0xBEEF);
    address user2 = address(0xCAFE);

    function setUp() public {
        evContract = new EVCharging();
        evContract.registerStation(1);
    }

    function testRegisterStation() public {
        vm.expectRevert("Station already registered");
        evContract.registerStation(1);
    }

    function testStartChargingSession() public {
        vm.prank(user1);
        evContract.startChargingSession(1);

        (uint256 id, bool available, address currentUser, ) = evContract
            .stations(1);
        assertEq(id, 1);
        assertFalse(available);
        assertEq(currentUser, user1);
    }

    function testEndChargingSession() public {
        vm.prank(user1);
        evContract.startChargingSession(1);

        vm.prank(user1);
        evContract.endChargingSession(1);

        (, bool available, address currentUser, ) = evContract.stations(1);
        assertTrue(available);
        assertEq(currentUser, address(0));
    }

    function testUnauthorizedEndSession() public {
        vm.prank(user1);
        evContract.startChargingSession(1);

        vm.prank(user2);
        vm.expectRevert("You are not the current user");
        evContract.endChargingSession(1);
    }

    function testStationAvailability() public {
        bool availableBefore = evContract.isStationAvailable(1);
        assertTrue(availableBefore);

        vm.prank(user1);
        evContract.startChargingSession(1);

        bool availableAfter = evContract.isStationAvailable(1);
        assertFalse(availableAfter);
    }
}
