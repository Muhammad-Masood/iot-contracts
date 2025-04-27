// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title TrafficManagement
/// @notice Manages traffic congestion data and issues alerts when congestion levels exceed a defined threshold
contract TrafficManagement {
    address public owner;
    uint256 public congestionThreshold; // e.g., congestion index out of 100

    struct TrafficSensor {
        uint256 sensorId;
        uint256 congestionLevel;
        uint256 timestamp;
    }

    mapping(uint256 => TrafficSensor) public sensors;

    event TrafficDataRecorded(
        uint256 indexed sensorId,
        uint256 congestionLevel,
        uint256 timestamp
    );
    event CongestionAlert(
        uint256 indexed sensorId,
        uint256 congestionLevel,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        congestionThreshold = 70; // Default threshold
    }

    /// @notice Records the congestion level of a particular traffic sensor
    /// @param _sensorId Unique ID of the sensor
    /// @param _congestionLevel Congestion level reported (0-100 scale)
    function recordTrafficData(
        uint256 _sensorId,
        uint256 _congestionLevel
    ) external onlyOwner {
        sensors[_sensorId] = TrafficSensor(
            _sensorId,
            _congestionLevel,
            block.timestamp
        );

        emit TrafficDataRecorded(_sensorId, _congestionLevel, block.timestamp);

        if (_congestionLevel >= congestionThreshold) {
            emit CongestionAlert(_sensorId, _congestionLevel, block.timestamp);
        }
    }

    /// @notice Updates the threshold at which congestion alerts are triggered
    /// @param _newThreshold New congestion threshold value
    function updateCongestionThreshold(
        uint256 _newThreshold
    ) external onlyOwner {
        congestionThreshold = _newThreshold;
    }
}
