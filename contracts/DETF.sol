// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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
address weth_add ; 
IERC20 weth ; 
uint8 public _decimals ; 
/// @notice factory address that deploy and intialize the mutual fund 
// address public immutable factory ; 
ISwapRouter public swapRouter ; 
IQuoter quote ; 
mapping (address => uint256 ) public userDeposit ; 
address[] public holders;  

/// mapping of underling token address to their ratio 
    mapping(address => uint256) public underlyingTokens;
    mapping(address => uint8) public underlyingTokensDecimals;
    address[] public underlyingTokenList;
event Deposited(address indexed user, uint256 amount); 
event Redeemed (address indexed user, uint256 amount); 


constructor(ISwapRouter _swapRouter   ) ERC20("DETF", "DETF") {
    swapRouter     =  ISwapRouter(_swapRouter);
    }

function initialize( 
    address _owner, 
    address _weth , 
    // address _swapRouter ,
    address[] memory _underlyingTokens , 
    uint256[] memory _underlyingTokensAmount ,
    uint8[] memory _underlyingTokensDecimals ,
    uint8 _tokenDecimals , 
    address _quoteAddress
 ) external  {
_decimals = _tokenDecimals ;
weth_add = _weth ; 


quote = IQuoter(_quoteAddress) ;
require (_underlyingTokens.length > 0 , "No asset under their Mutual Fund") ;
require ( _underlyingTokens.length == _underlyingTokensAmount.length , "Invalid input array") ;
require ( _underlyingTokens.length == _underlyingTokensDecimals.length , "Invalid input array") ;
for (uint i =0 ; i < _underlyingTokens.length ; i++ ) {
    underlyingTokens[_underlyingTokens[i]] = _underlyingTokensAmount[i] ;
    underlyingTokensDecimals[_underlyingTokens[i]] = _underlyingTokensDecimals[i] ;
    underlyingTokenList.push(_underlyingTokens[i]) ;
 }
}



function getunderlyingTokens ()  public view returns (address [] memory ) {  
    return  underlyingTokenList; 
}

function getunderlyingTokensAmount (address _token )  public view returns (uint256 ) {  
    return  underlyingTokens[_token]; 
}

function getunderlyingTokensDecimals (address _token )  public view returns (uint8 ) {  
    return  underlyingTokensDecimals[_token]; 
}


modifier onlyOwner() {
    require(msg.sender == owner , "Only Owner can call this function") ;
    _;
}



function calculateToBuyMutualFundTokens(uint256 _indexAmount ) public   returns (uint256[] memory) {
    uint256[] memory totalwethamount = new uint256[](underlyingTokenList.length);
    for (uint i = 0; i < underlyingTokenList.length; i++) {
        address token = underlyingTokenList[i];
        uint256 amount = getunderlyingTokensAmount(token);
        if (amount > 0 ) {
         uint256 totalTokenAmount = (amount * _indexAmount) * (10 ** _decimals);
         uint256 amountOut = quote.quoteExactInputSingle( weth_add , token , 3000, totalTokenAmount, 0 );
         totalwethamount[i] = amountOut;
        }
    }
    return totalwethamount ; 
}



function calculateToSellMutualFundTokens(uint256 _indexAmount ) public  returns (uint256[] memory) {
    uint256[] memory totalwethamount = new uint256[](underlyingTokenList.length);
    for (uint i = 0; i < underlyingTokenList.length; i++) {
        address token = underlyingTokenList[i];
        uint256 amount = getunderlyingTokensAmount(token);

        if (amount > 0 ) {
         uint256 totalTokenAmount = (amount * _indexAmount) * (10 ** _decimals);
         uint256 amountOut = quote.quoteExactOutputSingle( token ,weth_add, 3000, totalTokenAmount, 0 );
         totalwethamount[i] = amountOut;
        }
    }
    return totalwethamount ; 
}

function totalWethTokenToBuyIndexToken(uint256 _indexToken ) public  returns (uint256) {
    uint256[] memory totalwethtobuy = calculateToBuyMutualFundTokens(_indexToken) ; 
    return sum(totalwethtobuy) ; 
}

function totalWethTokenToSellIndexToken(uint256 _indexToken ) public  returns (uint256) {
    uint256[] memory totalwethtosell = calculateToSellMutualFundTokens(_indexToken) ; 
    return sum(totalwethtosell) ; 

}
 function sum(uint256[] memory numbers) internal pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < numbers.length; i++) {
            total += numbers[i];
        }
        return total;
    }



// now want i want is to mint the indextoken when this equal amount is transacfered
function mint(uint256 _indexToken )  external returns (uint256) {


uint256[] memory wethrequired = calculateToBuyMutualFundTokens(_indexToken) ; 
// require(msg.value >= sum(wethrequired) , "Invalid amount of WETH") ;  
uint256 [] memory amounts = new uint256[](underlyingTokenList.length); 


// this is the main part comes here want it do is very great 

address token = underlyingTokenList[0] ; 
uint256 amount = underlyingTokens[token]; 
uint256 totalTokenAmount = (amount * _indexToken) * (10 ** _decimals); 
uint256 requireweth = wethrequired[0] ; 

        TransferHelper.safeTransferFrom(weth_add , msg.sender, address(this), requireweth);
        TransferHelper.safeApprove(weth_add , address(swapRouter), requireweth );

// covert from weth to the token  ; 
ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: weth_add,
                tokenOut: token,
                fee: 30000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: requireweth,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap given the route.
        uint256 amountOut = swapRouter.exactInputSingle(params);
        return amountOut ; 
} 

// same with the sell part ok the main part is to make the swap ok  


 function swapExactInputSinglee(uint256 amountIn) external returns (uint256 amountOut) {
    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address  WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address  USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        // For this example, we will set the pool fee to 0.3%.
        uint24 poolFee = 3000;
        // msg.sender must approve this contract
    uint256 _indexToken = 1 ; 
        address tokenIn = WETH9; 
        address tokenOut = underlyingTokenList[0];
        uint256 amount = underlyingTokens[tokenOut];  
        uint256 totalTokenAmount = (amount * _indexToken) * (10 ** _decimals); // amount of token


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