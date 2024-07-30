// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './interface/IERC20.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

contract MutualFund is IERC20 

{

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
address public immutable factory ; 

ISwapRouter public dexRouter ;

mapping (address => uint256 ) public userDeposit ; 
 address[] public holders;  


IERC20 public usdc ;

/// mapping of underling token address to their ratio 
    mapping(address => uint256) public underlyingTokens;
    mapping(address => uint8) public underlyingTokensDecimals;
    address[] public underlyingTokenList;
 
 event Deposited(address indexed user, uint256 amount); 
    event Redeemed (address indexed user, uint256 amount); 
 
 function initialize( 
    address _owner, 
    address _usdc , 
    address _dexRouterAddress ,
    address[] memory _underlyingTokens , 
    uint256[] memory _underlyingTokensAmount ,
    uint8[] memory _underlyingTokensDecimals ,
    string memory _tokenname , 
    string memory _tokensymbol ,
    string memory _tokenImage ,
    uint8 _tokenDecimals

 ) external  {
 

// only factory can 
require (msg.sender == factory  ,  "Unauthorized Access")  ; 
owner = _owner ;
tokenname = _tokenname ;
tokensymbol = _tokensymbol ;
tokenImage = _tokenImage ;
_decimals = _tokenDecimals ;

usdc = IERC20(_usdc) ;
dexRouter = ISwapRouter(_dexRouterAddress) ;


require (_underlyingTokens.length > 0 , "No asset under their Mutual Fund") ;
require ( _underlyingTokens.length == _underlyingTokensAmount.length , "Invalid input array") ;
require ( _underlyingTokens.length == _underlyingTokensDecimals.length , "Invalid input array") ;

for (uint i =0 ; i < _underlyingTokens.length ; i++ ) {
    underlyingTokens[_underlyingTokens[i]] = _underlyingTokensAmount[i] ;
    underlyingTokensDecimals[_underlyingTokens[i]] = _underlyingTokensDecimals[i] ;
    underlyingTokenList.push(_underlyingTokens[i]) ;
 }

}

constructor (address _factory ) {
    require(_factory != address(0), "Invalid Factory Address");
    factory = _factory ;  
}


modifier onlyOwner() {
    require(msg.sender == owner , "Only Owner can call this function") ;
    _;
}






}