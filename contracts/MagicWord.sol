// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// MagicWord SmartContract that uses keccak256 :: github.com/mrozdolski
// Feel free to modify the contract according to your needs.
contract MagicWord is ReentrancyGuard, Pausable, Ownable {

    uint public enterTicket = 1 ether;
    uint public balance;
    bytes32 private magicWord = 0x9d2c6536cf2a19f4992beb1d77f371edb40d115f24ad4c1837a6e086767a7986;

    mapping(address => uint) public tickets;

    constructor() payable {
        balance = enterTicket;
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

    // Here you can buy a ticket to join the game and guess the word encrypted in keccak256.
    function buyTicket() public payable nonReentrant {
        require(msg.value == enterTicket, "Wrong value");
        require(balance > 0, "Game ended");
        balance += msg.value;
        tickets[msg.sender] += 1;
    }

    // Guess function. If you guess correctly, you get ether. If not, you lose the ticket.
    function guess(string memory _word) public onlyPlayers nonReentrant whenNotPaused {
        if (keccak256(abi.encodePacked(_word)) == magicWord) {

            (bool success,) = msg.sender.call{value: balance}("");
            require(success, "Failed to send ether");
             
            tickets[msg.sender] -= 1;
            balance = 0;
        } else {
            tickets[msg.sender] -= 1;
        }
    }

    // Here you can hash your word in keccak256
    function hashWord(string memory _word) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_word));
    }   

    function _onlyPlayers() internal view {
        require(tickets[msg.sender] >= 1, "Deposit to play");
    }
}