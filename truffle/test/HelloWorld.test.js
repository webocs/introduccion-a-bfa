const HelloWorld = artifacts.require('HelloWorld');

contract("HelloWorld", ()=>{
  let helloWorld;
  before(async ()=>{
    helloWorld = await HelloWorld.deployed();
    // Stores the string Hola Mundo
    let res = await helloWorld.storeMessage("Hola mundo");
    console.log(res);
  });

  describe("Testing hello world app", async()=>{
    it("Should get not get the Message Hell World from the function getMsg", async ()=>{
       // Retrieves the string
       const message = await helloWorld.getMsg.call();
       assert.equal(message,'Hola mundo');
    })

    it("Should get not get the Message Hell World from the function getMsg", async ()=>{
      // Retrieves the string
      const message = await helloWorld.getMsg.call();
      assert.notEqual(message,'Hello World');
    })


  });

});
