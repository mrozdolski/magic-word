// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MagicWordGame is ReentrancyGuard, Pausable, Ownable {

    uint public enterTicket = 1 ether;
    uint public balance;
    bytes32 private magicWord = 0x9d2c6536cf2a19f4992beb1d77f371edb40d115f24ad4c1837a6e086767a7986;

    mapping(address => bool) public players;
    mapping(address => uint) public tickets;

    constructor() payable {
        balance = msg.value;
    }

    modifier onlyPlayers() {
        _onlyPlayers();
        _;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function buyTicket(uint _amount) public payable nonReentrant {
        require(msg.value >= _amount * enterTicket, "Wrong value");
        require(balance > 0, "Game ended");
        balance += msg.value;
        tickets[msg.sender] += _amount;
    }

    function guess(string memory _word) public onlyPlayers nonReentrant whenNotPaused {
        if (keccak256(abi.encodePacked(_word)) == magicWord) {
             
            tickets[msg.sender] -= 1;
            balance = 0;

            (bool success, ) = msg.sender.call{value: balance}("");
            require(success, "Failed to send ether");
        } else {
            tickets[msg.sender] -= 1;
        }
    }   

    function hashWord(string memory _word) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_word));
    }

    function _onlyPlayers() internal view {
        require(tickets[msg.sender] >= 1, "Deposit to play");
    }
}