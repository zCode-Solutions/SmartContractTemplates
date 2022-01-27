//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";


contract School {
    
    using Counters for Counters.Counter;
    Counters.Counter public _id;
    mapping (uint => Person) public people;
    struct Person {
        uint256 id;
        address 
        string _firstName;
        string _lastName;
    }

    

    function addPerson(string memory _firstName, string memory _lastName) public{
        uint256 personId = _id.current();

        people[personId] = Person(personId, _firstName, _lastName);
         _id.increment();
    }
}
