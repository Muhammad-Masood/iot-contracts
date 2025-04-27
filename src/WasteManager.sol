// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/ownership/Ownable.sol";

/// @title Waste Management Smart Contract for Smart City IoT System
/// @notice Records bin fill data and emits events for high fill levels
contract WasteManagement {
    address public owner;
    uint256 public fillThreshold = 90; // Threshold in percent

    struct Bin {
        uint256 binId;
        uint256 fillLevel;
        uint256 timestamp;
    }

    mapping(uint256 => Bin) public bins;

    event BinCreated(
        uint256 indexed binId,
        uint256 fillLevel,
        uint256 timestamp
    );
    event BinDataRecorded(
        uint256 indexed binId,
        uint256 fillLevel,
        uint256 timestamp
    );
    event BinFullAlert(
        uint256 indexed binId,
        uint256 fillLevel,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
    @notice Creates a new Bin
    @param _binId Unique ID of the bin
     */
    function createNewBin(uint256 _binId, uint256 _fillLevel) internal {
        bins[_binId] = Bin({
            binId: _binId,
            fillLevel: _fillLevel,
            timestamp: block.timestamp
        });
        emit BinDataRecorded(_binId, _fillLevel, block.timestamp);
    }

    function getBinById(uint256 _binId) public view returns (Bin memory bin) {
        bin = bins[_binId];
        return bin;
    }

    /**
    @notice Updates the fill level of a waste bin
    @param _binId Unique ID of the bin
    @param _fillLevel Current fill level percentage (0-100)
    **/
    function updateBinData(
        uint256 _binId,
        uint256 _fillLevel
    ) external onlyOwner {
        require(_fillLevel <= 100, "Invalid fill level");
        Bin memory _bin = getBinById(_binId);
        if (_bin.binId == 0) {
            createBin(_binId, _fillLevel);
        } else {
            bins[_binId].fillLevel = _fillLevel;
        }
        emit BinDataRecorded(_binId, _fillLevel, block.timestamp);
        if (_fillLevel >= fillThreshold) {
            emit BinFullAlert(_binId, _fillLevel, block.timestamp);
        }
    }

    /**
    @notice Update the threshold for triggering full bin alerts
    @param _newThreshold New threshold value
    **/
    function updateFillThreshold(uint256 _newThreshold) external onlyOwner {
        require(_newThreshold <= 100, "Threshold must be <= 100");
        fillThreshold = _newThreshold;
    }
}
