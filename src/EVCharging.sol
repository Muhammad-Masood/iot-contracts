// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title EVCharging
/// @notice Manages electric vehicle (EV) charging station availability and session records
contract EVCharging {
    address public owner;

    struct ChargingStation {
        uint256 stationId;
        bool isAvailable;
        address currentUser;
        uint256 sessionStartTime;
    }

    mapping(uint256 => ChargingStation) public stations;

    event ChargingSessionStarted(uint256 indexed stationId, address indexed user, uint256 startTime);
    event ChargingSessionEnded(uint256 indexed stationId, address indexed user, uint256 endTime);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier stationExists(uint256 _stationId) {
        require(stations[_stationId].stationId != 0, "Station does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Registers a new charging station
    /// @param _stationId Unique ID for the charging station
    function registerStation(uint256 _stationId) external onlyOwner {
        require(stations[_stationId].stationId == 0, "Station already registered");

        stations[_stationId] = ChargingStation({
            stationId: _stationId,
            isAvailable: true,
            currentUser: address(0),
            sessionStartTime: 0
        });
    }

    /// @notice Starts a charging session
    /// @param _stationId Station where the session starts
    function startChargingSession(uint256 _stationId) external stationExists(_stationId) {
        ChargingStation storage station = stations[_stationId];

        require(station.isAvailable, "Station is currently in use");

        station.isAvailable = false;
        station.currentUser = msg.sender;
        station.sessionStartTime = block.timestamp;

        emit ChargingSessionStarted(_stationId, msg.sender, block.timestamp);
    }

    /// @notice Ends an ongoing charging session
    /// @param _stationId Station where the session ends
    function endChargingSession(uint256 _stationId) external stationExists(_stationId) {
        ChargingStation storage station = stations[_stationId];

        require(station.currentUser == msg.sender, "You are not the current user");

        station.isAvailable = true;
        station.currentUser = address(0);
        station.sessionStartTime = 0;

        emit ChargingSessionEnded(_stationId, msg.sender, block.timestamp);
    }

    /// @notice Check station availability
    /// @param _stationId Station ID to check
    function isStationAvailable(uint256 _stationId) external view stationExists(_stationId) returns (bool) {
        return stations[_stationId].isAvailable;
    }
}
