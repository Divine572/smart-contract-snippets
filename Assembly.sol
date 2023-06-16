// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Assembly {
    uint256 public sumOfNumbers; // slot 0
    struct Employee {
        address token;
        uint128 salary;
        uint64 nextPayTimestamp;
        uint64 timePeriod;
    }
    mapping(address => Employee) public employeeDetails;
    bool public paused; // slot 1

    event PlanPaused(bool);

    function sumPure(
        uint256[] memory _data
    ) public pure returns (uint256 result) {
        assembly {
            // because array is in memory we use mload, for calldata CALLDATALOAD
            // yul interprents the _data array as a memory address / 32B word
            let len := mload(_data)
            // 0x20 refers to 32 bytes
            let data := add(_data, 0x20)
            for {
                let end := add(data, mul(len, 0x20))
            } lt(data, end) {
                data := add(data, 0x20)
            } {
                result := add(result, mload(data))
            }
        }
    }

    function sum(uint256[] memory _data) public {
        assembly {
            let len := mload(_data)
            let data := add(_data, 0x20)
            let result
            for {
                let end := add(data, mul(len, 0x20))
            } lt(data, end) {
                data := add(data, 0x20)
            } {
                result := add(result, mload(data))
            }
            sstore(0, result)
        }
    }

    function pause() external {
        assembly {
            sstore(paused.slot, true)
            // emitting event
            mstore(0x80, true)
            // the hash is just the event PlanPaused hashed
            log1(
                0x80,
                0x01,
                0x3b52531264dffb2eb5a1cb50b4adb7d62109b880fd7615400f7d32fc1bb315a2
            )
        }
    }

    // slot x - [token]
    // slot x+1 - [salary,nextPayTimestamp,timePeriod]
    function addEmployees(
        address _employeeAddress,
        address _token,
        uint128 _employeeSalary,
        uint64 _firstPayTimestamp,
        uint64 _timePeriod
    ) external {
        assembly {
            // Calculating which slot to be stored in
            mstore(0x00, _employeeAddress)
            mstore(0x20, employeeDetails.slot)
            // generate unique storage slot
            let slot := keccak256(0, 0x40)
            let w := sload(slot)
            // Clearing 20 bytes and loading token address
            w := and(w, not(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            w := or(w, and(_token, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            sstore(slot, w)

            // Clearing and loading the first 16 bytes
            let s := sload(add(slot, 1))
            s := and(s, not(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            s := or(s, and(_employeeSalary, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))

            // // clearing and loading middle 8 bytes
            // s := and(s,0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            s := and(s, not(shl(128, 0xFFFFFFFFFFFFFFFF)))
            s := or(s, shl(128, and(_firstPayTimestamp, 0xFFFFFFFFFFFFFFFF)))

            // // clearing and loading last 8 bytes
            s := and(s, not(shl(192, 0xFFFFFFFFFFFFFFFF)))
            s := or(s, shl(192, and(_timePeriod, 0xFFFFFFFFFFFFFFFF)))

            sstore(add(slot, 1), s)
        }
    }

    function editEmployees(
        address _employeeAddress,
        address _token,
        uint128 _employeeSalary,
        uint64 _nextPayTimestamp,
        uint64 _timePeriod
    ) external {
        assembly {
            // Calculating which slot to be stored in
            mstore(0x00, _employeeAddress)
            mstore(0x20, employeeDetails.slot)
            let slot := keccak256(0, 0x40)
            let w := sload(slot)
            // Clearing 20 bytes and loading token address
            w := and(w, not(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            w := or(w, and(_token, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            sstore(slot, w)

            // Clearing and loading the first 16 bytes
            let s := sload(add(slot, 1))
            s := and(s, not(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            s := or(s, and(_employeeSalary, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))

            // // clearing and loading middle 8 bytes
            // s := and(s,0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            s := and(s, not(shl(128, 0xFFFFFFFFFFFFFFFF)))
            s := or(s, shl(128, and(_nextPayTimestamp, 0xFFFFFFFFFFFFFFFF)))

            // // clearing and loading last 8 bytes
            s := and(s, not(shl(192, 0xFFFFFFFFFFFFFFFF)))
            s := or(s, shl(192, and(_timePeriod, 0xFFFFFFFFFFFFFFFF)))

            sstore(add(slot, 1), s)
        }
    }

    function withdrawToken(address _tokenAddress, uint256 _amount) external {
        bytes4 sig = 0xa9059cbb;
        assembly {
            let data := mload(0x40)
            mstore(data, sig)
            mstore(add(data, 0x04), caller())
            mstore(add(data, 0x24), _amount)
            let result := call(
                2000000,
                _tokenAddress,
                0,
                data,
                0x52,
                data,
                0x01
            )
            switch result
            case 0 {
                revert(0, 0)
            }
            default {

            }
        }
    }
}
