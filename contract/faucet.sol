//// SPDX-License-Identifier: MIT  

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract tokenSwap{

    uint ERC_DECIMALS = 18;

    address internal cUsdTokenAddress =0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address internal celoTokenAddress = 0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9;


    event celoTransfer(address indexed _from, address _to, uint256 _amount);
    event cUSDTransfer(address indexed _from, address _to, uint256 _amount);
    

    mapping (address => uint) public lastClaim;

    uint requestAmount = 10** ERC_DECIMALS;



    //swap cUsd for celo
    function swapToken(uint _amount) public{

      uint celoAmount = _amount;

      require(IERC20Token(celoTokenAddress).balanceOf(address(this)) >= celoAmount,"Insufficient funds");

        require(
              IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
              ),
              "Transfer failed"
            );

            emit cUSDTransfer(msg.sender,address(this), _amount);

            require(IERC20Token(celoTokenAddress).transfer(
                payable(msg.sender),
                celoAmount
                ),
                "swap failed"
            );   
            emit cUSDTransfer(address(this), msg.sender, celoAmount);
    }


    //claim tokens to use. 
    function requestTokens(address _to) public{

        require((lastClaim[_to] + 1 days) < block.timestamp,"You only claim once in 24 hours");

        require(IERC20Token(celoTokenAddress).balanceOf(address(this)) >= requestAmount,"Insufficient funds");

        require(IERC20Token(celoTokenAddress).transfer(payable(_to),requestAmount),"token claim failed");

        lastClaim[_to] =block.timestamp;
    }

   

    //return token balance for the contract
    function contractTokenBalance() public view returns(uint _celoBalance,uint _cUSDBalance){
        return (
          IERC20Token(celoTokenAddress).balanceOf(address(this)),
          IERC20Token(cUsdTokenAddress).balanceOf(address(this))
        );
    }



}