// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract DETF is ERC20 {
address public owner ; 
uint public tokenTotalSupply ; 
mapping (address => uint256 ) public balances  ;
// which user allow which token to allow 
mapping (address => mapping (address => uint256 ) ) public allowances  ; 

string public tokenname ;
string public tokensymbol ;
string public tokenImage ; 

uint8 public _decimals ; 
/// @notice factory address that deploy and intialize the mutual fund 
// address public immutable factory ; 
ISwapRouter public swapRouter ;
IQuoter public quote ; 
mapping (address => uint256 ) public userDeposit ; 
address[] public holders;  

/// mapping of underling token address to their ratio 
    mapping(address => uint256) public underlyingTokens;
    mapping(address => uint8) public underlyingTokensDecimals;
    address[] public underlyingTokenList;

event Deposited(address indexed user, uint256 amount); 
event Redeemed (address indexed user, uint256 amount); 

constructor(ISwapRouter _swapRouter ) ERC20("DETF", "DETF") {
    swapRouter     = _swapRouter;
    // require(_factory != address(0), "Invalid Factory Address");
    // factory = _factory ;  
    }

// struct QuoteExactInputSingleParams  {
//     address tokenIn;
//     address tokenOut;
//     uint256 amountIn;
//     uint24 fee;
//     uint160 sqrtPriceLimitX96;
// }

// function initialize( 
//     address _owner, 
//     address _usdc , 
//     address _dexRouterAddress ,
//     address[] memory _underlyingTokens , 
//     uint256[] memory _underlyingTokensAmount ,
//     uint8[] memory _underlyingTokensDecimals ,
//     string memory _tokenname , 
//     string memory _tokensymbol ,
//     string memory _tokenImage ,
//     uint8 _tokenDecimals , 
//     address _quoteAddress
//  ) external  {
// // only factory can 
// require (msg.sender == factory  ,  "Unauthorized Access")  ; 
// owner = _owner ;
// tokenname = _tokenname ;
// tokensymbol = _tokensymbol ;
// tokenImage = _tokenImage ;
// _decimals = _tokenDecimals ;
// usdc = IERC20(_usdc) ;
// swapRouter = ISwapRouter(_dexRouterAddress) ;
// quote = IQuoterV2(_quoteAddress) ;
// require (_underlyingTokens.length > 0 , "No asset under their Mutual Fund") ;
// require ( _underlyingTokens.length == _underlyingTokensAmount.length , "Invalid input array") ;
// require ( _underlyingTokens.length == _underlyingTokensDecimals.length , "Invalid input array") ;
// for (uint i =0 ; i < _underlyingTokens.length ; i++ ) {
//     underlyingTokens[_underlyingTokens[i]] = _underlyingTokensAmount[i] ;
//     underlyingTokensDecimals[_underlyingTokens[i]] = _underlyingTokensDecimals[i] ;
//     underlyingTokenList.push(_underlyingTokens[i]) ;
//  }
// }
modifier onlyOwner() {
    require(msg.sender == owner , "Only Owner can call this function") ;
    _;
}

// function calculateToBuyMutualFundTokens(uint256 _indexAmount) public view returns (uint256[] memory) {
//     // What are the underlying tokens?
//     // First, we have to calculate the total value of the underlying tokens   
//     uint256[] memory totalusdcamount = new uint256[](underlyingTokenList.length);
//     for (uint i = 0; i < underlyingTokenList.length; i++) {
//         address token = underlyingTokenList[i];
//         uint256 tokenAmount = underlyingTokens[token];
//         uint256 totalTokenAmount = (tokenAmount * _indexAmount) * (10 ** _decimals);
        
//         IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2.QuoteExactInputSingleParams({
//             tokenIn: address(usdc) ,
//             tokenOut: token ,
//             amountIn: totalTokenAmount,
//             fee: 3000,
//             sqrtPriceLimitX96: 0
//         });
//         ///@dev calling this in the static call so that it is not that cost efficient 
//         bytes memory data = abi.encodeWithSelector(
//             IQuoterV2.quoteExactInputSingle.selector,
//             params
//         );
        
//         (bool success, bytes memory returnData) = address(quote).staticcall(data);
//         require(success, "static call failed");

//         (uint256 amountOut, , , ) = abi.decode(returnData, (uint256, uint160, uint32, uint256));
//         totalusdcamount[i] = amountOut;
//     }
//     return totalusdcamount;
// }


// function calculateToSellMutualFundTokens(uint256 _indexAmount) public view returns (uint256[] memory) {
//     // What are the underlying tokens?
//     // First, we have to calculate the total value of the underlying tokens   
//     uint256[] memory totalusdcamount = new uint256[](underlyingTokenList.length);
//     for (uint i = 0; i < underlyingTokenList.length; i++) {
//         address token = underlyingTokenList[i];
//         uint256 tokenAmount = underlyingTokens[token];
//         uint256 totalTokenAmount = (tokenAmount * _indexAmount) * (10 ** _decimals);
        
//         IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2.QuoteExactInputSingleParams({
//             tokenIn: token,
//             tokenOut: address(usdc),
//             amountIn: totalTokenAmount,
//             fee: 3000,
//             sqrtPriceLimitX96: 0
//         });
//         // trying to chnage into the quoter not the quoter2 
//         ///@dev calling this in the static call so that it is not that cost efficient 
//         bytes memory data = abi.encodeWithSelector(
//             IQuoterV2.quoteExactOutputSingle.selector,
//             params
//         );
//         (bool success, bytes memory returnData) = address(quote).staticcall(data);
//         require(success, "static call failed");

//         (uint256 amountOut, , , ) = abi.decode(returnData, (uint256, uint160, uint32, uint256));
//         totalusdcamount[i] = amountOut;
//     }
//     return totalusdcamount;
// }




 function swapExactInputSinglee(uint256 amountIn) external returns (uint256 amountOut) {
        

    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address  WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address  USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // For this example, we will set the pool fee to 0.3%.
    uint24 poolFee = 3000;
        // msg.sender must approve this contract
        address tokenIn = WETH9; 
        address tokenOut = DAI;

        // Transfer the specified amount of _ to this contract.
        // note: this contract must first be approved by msg.sender 
        // token, from, to, value

        TransferHelper.safeTransferFrom(tokenIn, msg.sender, address(this), amountIn);

        // // similar code using barebones ERC20 token -- TransferHelper uses low-level call() 
        // uint balance = IERC20(tokenIn).balanceOf(msg.sender);
        // bool succ = IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        // console.log(succ);

        // Approve the router to spend 
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        // create params of swap 
        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap given the route.
        amountOut = swapRouter.exactInputSingle(params);
    }








}