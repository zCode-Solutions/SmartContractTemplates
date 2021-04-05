pragma solidity ^0.8.3;


contract PayableExample {
    address payable public owner;
    
    struct Payment {
        string name;
        uint256 value;
    }
    
    //Payment[]  paymentHistory;
    //history of payments to owner
    mapping (address => Payment[]) public payments;

    
    
    constructor() {
        owner = payable(msg.sender);
    }
    function invest() external payable{
        //sends ether to smart contract
    }
    
    function balanceOf() external view returns(uint){
        return address(this).balance;
    }
    
    function purchase(string memory _name, Payment[] memory paymentHistory) external payable{
        owner.transfer(msg.value); //transfer ether from smart contract to address
        string[] memory name = new string[](paymentHistory.length);
        uint[] memory value = new uint[](paymentHistory.length);
        for (uint i = 0; i < paymentHistory.length; i++) {
            require(paymentHistory[i].value != 0, "Fee value should be positive");
            payments[msg.sender].push(paymentHistory[i]);
            name[i] = paymentHistory[i].name;
            value[i] = paymentHistory[i].value;
        }
    }
    function purchase2(string memory _name) external payable{
        owner.transfer(msg.value); //transfer ether from smart contract to address
        Payment memory paymentHistory = Payment(_name, msg.value);
        payments[msg.sender].push(paymentHistory);
    }
    
    function getPaymentHistory(address _address) external returns(Payment[] memory){
        return payments[_address];
    }
    
    function getPaymentHistory2(address _address) external returns(string[] memory, uint[] memory){
        string[] memory name = new string[](payments[msg.sender].length);
        uint[] memory value = new uint[](payments[msg.sender].length);
        for (uint i = 0; i < payments[msg.sender].length; i++) {
            name[i] = payments[msg.sender][i].name;
            value[i] = payments[msg.sender][i].value;
        }    
        return (name, value);
    }

}