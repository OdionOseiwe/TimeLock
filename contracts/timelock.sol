// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 { 
    function transferFrom(
        address from,
        address to,
        uint256 amountoftoken
    ) external returns(bool);

    function transfer(address to, uint256 amount) external returns (bool) ;
    function balanceOf(address account) external returns (uint256);
}    

contract Timelock{

    /// @dev the contract is to lock an amount of token in this contract for an amount of time
    /// @dev first function is to lock the token and the manager is deployer and the amount of time was intialized in the contructor

    uint public amountofTime;
    address manager;
    IERC20 tokenAddress;
    bool locked;
    uint Locktokens;
    uint balbeforetransfer;
    uint balaftertransfer;

    /// custom errors

    /// not manger
    error notManger();

    /// zero tokens
    error Zerotokens();

    // /// zero tokens
    // error Zerotokens();

    /// time has not passed
    error Timenot_Reached();

    /// you never locked a token
    error Notokens();

    /// cant withdraw now
    error notThistoken();

    /// events 
    event lockedToken(uint amount);
    event withdrawedTokens(address  _manger,uint amount);
  
    constructor(uint _amountoftime , IERC20 _tokenAddress) {
        amountofTime  = _amountoftime ;
        manager = msg.sender;
        tokenAddress = _tokenAddress;
    }

    function lockToken(uint amountofTokentoLock) external {
        if(msg.sender != manager){
            revert notManger();
        }
        uint _time = 1 minutes * amountofTime;
        Locktokens =  amountofTokentoLock;
        amountofTime = block.timestamp + _time;
        if(amountofTokentoLock == 0){
            revert Zerotokens();
        }

        balbeforetransfer = IERC20(tokenAddress).balanceOf(address(this));

        bool sent = IERC20(tokenAddress).transferFrom(manager, address(this), amountofTokentoLock);
        require(sent, "failed");
        locked = true;

        emit lockedToken(amountofTokentoLock);
    }

    function withdraw() external   {
        if(msg.sender != manager){
            revert notManger();
        }
        if(locked != true){
            revert Notokens();
        }
        if(block.timestamp < amountofTime){
            revert Timenot_Reached();
        }
    
        balaftertransfer = IERC20(tokenAddress).balanceOf(address(this));

        bool sent = IERC20(tokenAddress).transfer(manager, balaftertransfer);
        require(sent, "failed");  
        emit withdrawedTokens(manager, Locktokens); 
    }

    function withdrawotherTokens(IERC20 otherAddress) external  {
        if(msg.sender != manager){
            revert notManger();
        }
        if(otherAddress == tokenAddress){
           revert notThistoken();
        }
        uint256 otherTokenAmount  = IERC20(otherAddress).balanceOf(address(this));

        bool sent = IERC20(otherAddress).transfer(manager,otherTokenAmount);
        require(sent, "failed");
    }  
     
}          
    

//// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 manger