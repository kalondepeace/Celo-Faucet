//// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract tokenSwap {
    uint256 ERC_DECIMALS = 18;

    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address internal celoTokenAddress =
        0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9;

    event CELOTransfer(address indexed _from, address _to, uint256 _amount);
    event cUSDTransfer(address indexed _from, address _to, uint256 _amount);

    mapping(address => uint256) public lastClaim;

    uint256 requestAmount = 10**ERC_DECIMALS;

    /**
      * @notice Swaps cUSD for CELO
      * @param _amount the amount to swap
     */
    function swapToken(uint256 _amount) public {
        uint256 celoAmount = _amount;

        require(
            IERC20Token(celoTokenAddress).balanceOf(address(this)) >=
                celoAmount,
            "Insufficient funds"
        );

        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "Transfer failed"
        );

        emit cUSDTransfer(msg.sender, address(this), _amount);

        require(
            IERC20Token(celoTokenAddress).transfer(
                payable(msg.sender),
                celoAmount
            ),
            "swap failed"
        );
        emit CELOTransfer(address(this), msg.sender, celoAmount);
    }

    /**
      * @dev Requests for CELO tokens can only be performed once every 24 hrs for an address
      * @notice Requests CELO tokens from the faucet
     */
    function requestTokens(address _to) public {
        require(
            (lastClaim[_to] + 1 days) < block.timestamp,
            "You only claim once in 24 hours"
        );

        require(
            IERC20Token(celoTokenAddress).balanceOf(address(this)) >=
                requestAmount,
            "Insufficient funds"
        );

        lastClaim[_to] = block.timestamp;

        require(
            IERC20Token(celoTokenAddress).transfer(payable(_to), requestAmount),
            "token claim failed"
        );

        emit CELOTransfer(address(this), _to, requestAmount);
    }

    /**
      * @return _celoBalance the CELO balance of the smart contract
      * @return _cUSDBalance the cUSD balance of the smart contract
     */
    function contractTokenBalance()
        public
        view
        returns (uint256 _celoBalance, uint256 _cUSDBalance)
    {
        return (
            IERC20Token(celoTokenAddress).balanceOf(address(this)),
            IERC20Token(cUsdTokenAddress).balanceOf(address(this))
        );
    }
}
