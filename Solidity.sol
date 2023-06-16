// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Solidity {
    uint256 public sumOfNumbers;
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
        for (uint256 i; i < _data.length; ++i) {
            result += _data[i];
        }
    }

    function sum(uint256[] memory _data) public {
        uint256 result;
        uint256 len = _data.length;
        for (uint256 i; i < len; ++i) {
            result += _data[i];
        }
        sumOfNumbers = result;
    }

    function pause() external {
        paused = true;
        emit PlanPaused(true);
    }

    function addEmployees(
        address _employeeAddress,
        address _token,
        uint128 _employeeSalary,
        uint64 _firstPayTimestamp,
        uint64 _timePeriod
    ) external {
        Employee storage emp = employeeDetails[_employeeAddress];
        emp.salary = _employeeSalary;
        emp.token = _token;
        emp.nextPayTimestamp = _firstPayTimestamp;
        emp.timePeriod = _timePeriod;
    }

    function editEmployees(
        address _employeeAddress,
        address _token,
        uint128 _employeeSalary,
        uint64 _nextPayTimestamp,
        uint64 _timePeriod
    ) external {
        Employee storage emp = employeeDetails[_employeeAddress];
        emp.salary = _employeeSalary;
        emp.token = _token;
        emp.nextPayTimestamp = _nextPayTimestamp;
        emp.timePeriod = _timePeriod;
    }

    function withdrawToken(address _tokenAddress, uint256 _amount) external {
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }
}
