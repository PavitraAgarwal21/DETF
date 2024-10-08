import { expect } from "chai";
import { ethers } from "hardhat";

it('DETF', async () => {
  // signer 
  const signers = await ethers.getSigners(); 
  const signer = signers[0];

  // uniswap contract to deploy
const SwapV2_add = "0xE592427A0AEce92De3Edee1F18E0157C05861564" ;

  const SwapExample = await ethers.getContractFactory("DETF");
  // give router address in contructor  
  const swaper = await SwapExample.deploy(SwapV2_add);
  await swaper.deployed();

  // weth contract 
  // check it out here: https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2#code
  const erc_abi = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"guy","type":"address"},{"name":"wad","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"src","type":"address"},{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"wad","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"deposit","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"guy","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Withdrawal","type":"event"}]
  const weth_addr = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
  const weth_contract = new ethers.Contract(weth_addr, erc_abi, signer)
  const onwer = signer.address ; 
  // DAI contract 
  const dai_addr = '0x6B175474E89094C44Da98b954EedeAC495271d0F'
  const dai_contract = new ethers.Contract(dai_addr, erc_abi, signer)
  


  // initial balance in ETH 
  let balance = ethers.utils.formatEther((await signer.getBalance()))
  let num_weth = ethers.utils.formatEther((await weth_contract.balanceOf(signer.address)))
  expect(num_weth).to.equal('0.0')
  
  console.log('ETH Balance: ', balance)
  console.log('WETH Balance: ', num_weth)
  console.log('---')

  // convert eth to weth 
  const overrides = {
    value: ethers.utils.parseEther('2'),
    gasLimit: ethers.utils.hexlify(50000), 
  }
  let tx = await weth_contract.deposit(overrides)
  await tx.wait() // wait for it to be confirmed in blockchain

const usdc_add  = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48" ;

  // usdc, dai 
  const underlyingtoken =[usdc_add ,dai_addr ] ; 
  const underlyingAmount = [4, 10] ; 
  const underlyingDecimals = [6,18] ; 
  const tokenDecimals = 18 ; 
  const quoteAddress = "0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6" ;


  tx = await swaper.initialize(
    signer.address , 
    weth_addr , 
    underlyingtoken , 
    underlyingAmount , 
    underlyingDecimals , 
    tokenDecimals , 
    quoteAddress 
  ) 
  await tx.wait() ; 
  console.log("initialize the contract" , tx ) ;


  tx = await swaper.connect(signer).callStatic.getunderlyingTokens(); 
  console.log("get the underlying tokens ",tx) ;
  // confirm WETH balance increased
  // balance = ethers.utils.formatEther((await signer.getBalance()))
  // num_weth = ethers.utils.formatEther((await weth_contract.balanceOf(signer.address)))
  // expect(num_weth).to.equal('2.0')

  // console.log('ETH Balance: ', balance)
  // console.log('WETH Balance: ', num_weth)
  // console.log('---')

  // we have to initialize the swaper contract with the token addresses

      tx = await swaper.connect(signer).callStatic.totalWethTokenToBuyIndexToken(1) ; 
      console.log("buy  ",tx) ;

      tx = await weth_contract.deposit(overrides)
      await tx.wait()
      tx = await swaper.connect(signer).callStatic.totalWethTokenToSellIndexToken(1) ; 
      console.log("sell  ",tx) ;

  
      // tx = await weth_contract.approve(swaper.address, ethers.utils.parseEther('10'))
      // await tx.wait()
      

      // tx = await swaper.connect(signer).callStatic.mint(1) ;
      // console.log("mint  ",tx) ;

  // approve swapper contract to spend for 1 WETH 
  tx = await weth_contract.approve(swaper.address, ethers.utils.parseEther('1'))
  await tx.wait()
  // 1 WETH -> DAI 
  tx = await swaper.connect(signer).callStatic.swapExactInputSinglee(ethers.utils.parseEther('1'))
  console.log("swapping vmount out value ",tx) ; // tx.wait()

  // confirm DAI token balance 
  // num_weth = ethers.utils.formatEther((await weth_contract.balanceOf(signer.address)))
  // let num_dai = ethers.utils.formatEther((await dai_contract.balanceOf(signer.address)))
  // // expect(num_weth).to.equal('1.0')

  // console.log('WETH Balance: ', num_weth)
  // console.log('DAI Balance: ', num_dai)
})
