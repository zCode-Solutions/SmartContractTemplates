pragma solidity >=0.4.22 <0.6.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

contract smartPiggyBank{

//contract variables

  //objects
    //Bank object
      struct Bank {
          uint goalID;
          uint currentBalance;
          uint goal;
          address payable goalOwner;
          address payable goalDestination;
      }
    //contributors object
      struct contributor {
          uint goalId;
          uint contributionTowardsGoal;
          address contributorAddress;
          bool agreesToAddress;
          bool etherNotUsedAddressChange;
      }

  //arrays of objects
    Bank[] public Ids;
    contributor[] public contributors;

  //mappings (ids -> id's states)
    mapping (uint => bool) idExist;
    mapping (uint => bool) public goalMet;
    mapping (uint => address) public goalOwner;

  //events for DOM manipulation
    event bankCreated(uint id);
    event contributionMade(uint contribution);
    event moneyWithdrawn(uint withdrawnMoney);
    event moneySpent(uint id, uint moneyspent);
    event addresschanged(address payable newAddress);

  //Functions to manaipulate DOM
    //Know the array's length
      function getIds() public view returns(uint) {
       return Ids.length;
      }
      function getcontributors() public view returns(uint) {
       return contributors.length;
      }

  //features
    //function creates a piggybank with a goal and payable address
      function createbank(uint _goal, address payable _goalAddress) public {
          //create a random ID for the piggybank
          uint _piggyBankID = rand();

          //create the ID for piggyBank  and push it in an array of IDs of structs
          Ids.push(piggyBankID(_piggyBankID, 0, _goal, msg.sender,_goalAddress));

          //add to goal ID mapping
          idExist[_piggyBankID] = true;

          //goal goalOwner
          goalOwner[_piggyBankID] = msg.sender;

          emit bankCreated(_piggyBankID);
      }

    //contribute to piggyBank
      function contribute(uint _goalID) public payable {
          //must contrubute an amount of money
          require(msg.value > 0, "You must add money to contribute");

          //ID must exist, cycle through array
          require(idExist[_goalID] == true,  "Your goal ID is invalid");

          //require that the goal has not already been goalMet
          require(goalMet[_goalID] != true, "The goal has already been met");

          //modify bool and totalsent if the requirements are met
          bool contributorAlreadyExist = false;
          uint totalSent = 0;


         //when the goal is reached - take the difference and send it back to the sender
         //and make the goal mapping true;
          for(uint i = 0; i < Ids.length; i++) {
              if(_goalID == Ids[i].goalID) {

                  if (Ids[i].currentBalance + msg.value >= Ids[i].goal) {
                      uint overAmount = (Ids[i].currentBalance + msg.value) - Ids[i].goal;
                      msg.sender.transfer(overAmount);
                      goalMet[_goalID] = true;
                      Ids[i].currentBalance = Ids[i].goal;
                      totalSent = msg.value - overAmount;
                  }else {

                      Ids[i].currentBalance = Ids[i].currentBalance + msg.value;
                      totalSent = Ids[i].currentBalance;
                  }

              }
          }

          //if this is the first contributor, add them to the array
          if(contributors.length == 0) {
              contributors.push(contributor(_goalID, totalSent, msg.sender, true, false));
          } else {


              //if a person has already contributed, update their current balance, and let the system know by modifying varible
              for(uint i = 0; i < contributors.length; i++) {
                  if(_goalID == contributors[i].goalId && msg.sender == contributors[i].contributorAddress ) {
                      //reqiure a person aggree to address change first
                      require(contributors[i].agreesToAddress == true, "please agree to address change before you contribute again");

                      //when true - add msg.value to currentBalance
                      contributors[i].contributionTowardsGoal = totalSent + contributors[i].contributionTowardsGoal;
                      contributorAlreadyExist = true;
                  }
              }



              //if there is no contributer for this piggybank, then add the contributor
              if (contributorAlreadyExist == false) {
                  //create an array of contrinutors for this goalId
                  contributors.push(contributor(_goalID, totalSent, msg.sender, true, false));
              }

          }

          emit contributionMade(msg.value);

      }



    //allow people to withdraw their funds if the goal has not been met
      function withdraw(uint _goalID) public {
          //ID must exist, cycle through array
          require(idExist[_goalID] == true,  "Your goal ID is invalid");

          //goal owners cannot take money out
          require(goalOwner[_goalID] != msg.sender, "You cannot break your piggybank");

          //local variable
          uint contributionAmount = 0;

          //look for their contribution
          for(uint i = 0; i < contributors.length; i++) {
              if(_goalID == contributors[i].goalId && msg.sender == contributors[i].contributorAddress ) {
                  //need the ether not used due to address change to be true to withdraw
                  if(contributors[i].etherNotUsedAddressChange == true) {
                      contributionAmount = contributors[i].contributionTowardsGoal;
                      contributors[i].contributionTowardsGoal = 0;
                      require(contributionAmount > 0, "You have not contributed to this Goal");
                      msg.sender.transfer(contributionAmount);
                      emit moneyWithdrawn(contributionAmount);
                  }else {
                          //goal cannot be reached
                          require(goalMet[_goalID] != true , "The goal has already been met");
                          contributionAmount = contributors[i].contributionTowardsGoal;
                          contributors[i].contributionTowardsGoal = 0;
                          require(contributionAmount > 0, "You have not contributed to this Goal");
                          msg.sender.transfer(contributionAmount);
                          emit moneyWithdrawn(contributionAmount);
                  }
              }
          }
      }

    //goal has been met / owner can use funds
    function usePiggyBank(uint _goalID) public {

        require(idExist[_goalID] == true,  "Your goal ID is invalid");
        //only owner can use funds
        require(goalOwner[_goalID] == msg.sender, "You are not the owner of this bank");
        //must have met goal
        require(goalMet[_goalID] == true, "Goal must be met");
        //make sure they have enough money
        //then transfer it to the correct address
        for(uint i = 0; i < Ids.length; i++) {
            if(_goalID == Ids[i].goalID) {
                if (Ids[i].currentBalance > 0) {
                    uint _balance = Ids[i].currentBalance;
                    Ids[i].currentBalance = 0;
                    Ids[i].goalDestination.transfer(_balance);
                    emit moneySpent(_goalID, _balance);
                }else {
                    revert("You do not have enough money");
                }
            }
        }
    }

    //allow the owner to change the address where the money is sent
    //must alert the contributers and ask them to agree to the change
      function changeAddress(uint _goalID, address payable _address) public {

          //must be a valid goal and must be goal owner
          require(idExist[_goalID] == true,  "Your goal ID is invalid");
          require(goalOwner[_goalID] == msg.sender, "You are not the owner of this bank");

          //find address and change it
          for(uint i = 0; i < Ids.length; i++) {
              if(_goalID == Ids[i].goalID) {
                  //require that the address isnt the same to stop mistakes
                  require(_address != Ids[i].goalDestination, "Please input a novel address for this goal");
                  //set the new address in struct
                  Ids[i].goalDestination = _address;
                  emit addresschanged(_address);
                  //everyone that is a contributor must say this is okay unless it is the goal owner
                  for(uint x = 0; x < contributors.length; x++) {
                      if(_goalID == contributors[x].goalId) {
                          //set okay to give to false
                          contributors[x].agreesToAddress = false;
                          //set either not used to true
                          contributors[x].etherNotUsedAddressChange = true;
                          //take the contributors money out of Ids
                          Ids[i].currentBalance = Ids[i].currentBalance - contributors[x].contributionTowardsGoal;
                          if(Ids[i].currentBalance < Ids[i].goal) {
                              goalMet[_goalID] = false;
                          }
                      }
                  }
              }
          }
      }


    //allow for someone to recontibute their funds after address change
      function contributorAgreesToAddressChange(uint _goalID) public {
          //the item must exist
          require(idExist[_goalID] == true,  "Your goal ID is invalid");
          //require that the goal has not already been goalMet
          require(goalMet[_goalID] != true, "The goal has already been met, please withdraw your contributions");
          //must be a contributer
          address payable contributerAddress;
          for(uint i = 0; i < Ids.length; i++) {
              if(_goalID == Ids[i].goalID) {

                 //go into each contributor
                  for( uint x = 0; x < contributors.length; x++) {
                      if(_goalID == contributors[x].goalId && contributors[x].contributorAddress == msg.sender) {
                          //require the contribtor has money
                          require(contributors[x].contributionTowardsGoal > 0, "You do not have any contributions to this goal");
                          //aggress to address must be false
                          require(contributors[x].agreesToAddress == false, "You have already agreed to the address change");
                          //set contrubuteraddress to stop non contributers
                          contributerAddress = msg.sender;
                          uint totalSent = 0;
                          //create an if statement to reset contributors amount of money
                          if (Ids[i].currentBalance + contributors[x].contributionTowardsGoal >= Ids[i].goal) {
                              uint overAmount = (Ids[i].currentBalance + contributors[x].contributionTowardsGoal) - Ids[i].goal;
                              msg.sender.transfer(overAmount);
                              goalMet[_goalID] = true;
                              Ids[i].currentBalance = Ids[i].goal;
                              totalSent = contributors[x].contributionTowardsGoal - overAmount;
                              contributors[x].contributionTowardsGoal = totalSent;
                          }else {
                              Ids[i].currentBalance = Ids[i].currentBalance + contributors[x].contributionTowardsGoal;
                          }
                      }
                      if(msg.sender == contributerAddress) {
                          //set okay to give to true
                          contributors[x].agreesToAddress = true;
                          contributors[x].etherNotUsedAddressChange = false;
                      }else {
                          revert('You have not contributed');
                      }
                  }
              }
          }
      }


  //helper function
    //random number function to create unique Id (helper function)
      function rand() internal view returns(uint) {
          uint nonce;
          nonce ++;
          uint randNum = uint(keccak256(abi.encodePacked(msg.sender, now, nonce))) % 10000000;
          return randNum;
      }

}
