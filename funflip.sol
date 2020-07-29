

pragma solidity 0.6.6;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/7a4e19a8ff07db1be0b397465d38d175bc0bb5b5/evm-contracts/src/v0.6/VRFConsumerBase.sol";

contract RandomNumberConsumer is VRFConsumerBase {
    
 // State Variables & Mappings Declaration

//=============================================================================

   //chainlink oracle state variables
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    
    // user address and its corresponding win amount 
    mapping(address=>uint) public WinningAmount;
    
    // no of referrals of a given user
    mapping(address=>uint) public referrals;


//=============================================================================
    
  

    
    // Events Declaration

//=============================================================================
    
    event betMade(address indexed ,uint amount,uint sideSelected,uint coinflipResult,uint amountWon);
    event widthdrawMade(address indexed,uint amount);

//=============================================================================

    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Ropsten
     * Chainlink VRF Coordinator address: 0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb
     * LINK token address:                0x20fE562d797A42Dcb3399062AE9546cd06f63280
     * Key Hash: 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205
     */
    constructor() 
        VRFConsumerBase(
            0xf720CF1B963e0e7bE9F58fd471EFa67e7bF00cfb, // VRF Coordinator
            0x20fE562d797A42Dcb3399062AE9546cd06f63280  // LINK Token
        ) public
    {
        keyHash = 0xced103054e349b8dfb51352f0f8fa9b5d20dde3d06f9f43cb2b85bc64b238205;
        fee = 0.1 * 10 ** 18; // 0.1 LINK //1000000000000000000 LINK 
    }
    
    /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) external override {
        require(msg.sender == vrfCoordinator, "Fulillment only permitted by Coordinator");
        randomResult = randomness;
    }
    
    /** @dev Flip Coin function  
    */ 
    
    function flip(uint _side,uint _seed){
        require(msg.value!=0 ether);
        // number between 0-4= heads 
        //number between 5-9 = tails
        require(side>=0 && side <=9,"please choose numbers between 0 to 9 ");
        requestRandomness(keyHash,fee,_seed);
        uint generatedRandomNumber = uint(keccak256(abi.encodePacked(randomResult)))%10;
        
        //todo check random
        
        //todo update balance
        
    }
    
     /** @dev Withdraw Win Amount 
    */ 
   
   function withdraw() public returns (bool success){
       require(WinningAmount[msg.sender] > 0 , "Whoops! You are trying to withdraw zero ETH");
       require(WinningAmount[msg.sender]<address(this).balance,"Please try again, Bankroll is out of Balance");
       uint amount = WinningAmount[msg.sender];
       WinningAmount[msg.sender] = 0;
       msg.sender.transfer(amount);
       emit widthdrawMade(msg.sender ,amount);
       return true;
   }
}