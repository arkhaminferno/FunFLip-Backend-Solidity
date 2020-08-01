

pragma solidity 0.6.6;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/7a4e19a8ff07db1be0b397465d38d175bc0bb5b5/evm-contracts/src/v0.6/VRFConsumerBase.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/math";
contract RandomNumberConsumer is VRFConsumerBase {
    
    using SafeMath for uint256;
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
    
    event logResult (address user, uint betamount,string sideSelected,string result, uint winamount,string outcome);
    event balanceUpdated(address playeraddress , uint amount);
    event widthdrawMade(address user,uint amount);

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
    
    function flip(uint _headsOrTails,uint _seed) public payable {
        require(msg.value!=0 ether);
        require(_headsOrTails == 1 || _headsOrTails == 2, "Choice needs to be 1 or 2");
        requestRandomness(keyHash,fee,_seed);
        uint generatedRandomNumber =  (uint256(keccak256(abi.encodePacked(_result))) % 2) + 1;
        string memory result;
        string memory userselectedSide;
        if(_headsOrTails == 1){
            userselectedSide = "Heads!";
        }
        if(_headsOrTails ==2){
            userselectedSide = "Tails";
        }
        if(generatedRandomNumber == 1 ){
            result = "heads!";
        }
        if(generatedRandomNumber == 2){
            result = "Tails!";
        }
        if(_headsOrTails == generatedRandomNumber){
            uint winamount=  msg.value.mul(2);
            WinningAmount[msg.sender] = winamount;
            emit balanceUpdated(msg.sender,Fivepercent);
            emit logResult(msg.sender, msg.value, userselectedSide, result,winamount,"!WON");
        }
        if(_headsOrTails != generatedRandomNumber){
           uint Fivepercent =  msg.value.div(5);
           WinningAmount[msg.sender] = Fivepercent;
           emit balanceUpdated(msg.sender,Fivepercent);
           emit logResult(msg.sender, msg.value, userselectedSide, result,winamount,"!LOSS");
        }
        

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
