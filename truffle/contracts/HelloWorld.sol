// Define a version of solidity
pragma solidity ^0.7.0;
// Declare a contract with a given name
contract HelloWorld {
    // Member variables (Persistent storage)
    string public privateMsg;
    // Constructor function
    function storeMessage(string memory msg)public{
        // Poor string management
        // requires converting to bytes and store in memory to check size
        bytes memory tempEmptyStringTest = bytes(msg);
        // If msg is not null, store it in the privateMsg var
        // Otherwise  assign Hello World
        if(tempEmptyStringTest.length>0){
            privateMsg= msg;
        }
        else{
            privateMsg="Hello World!";
        }
    }

    function getMsg() public view returns(string memory){
        return privateMsg;
    }
}
