import Web3 from 'web3'
import { newKitFromWeb3 } from '@celo/contractkit'
import BigNumber from "bignumber.js"
import faucetAbi from '../contract/faucet.abi.json'
import erc20Abi from "../contract/erc20.abi.json"

const ERC20_DECIMALS = 18

const faucetContractAddress = "0xc11430db76Ad33455169fA1b27fA797D4F31Fa06"
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"
const celoCOntractAddress = "0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9"

let kit
let contract
let accounts



const connectCeloWallet = async function () {
  if (window.celo) {
    try {
     notification("⚠️ Please approve this DApp to use it.")
      await window.celo.enable()
      notificationOff()
      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)

      accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]

      contract = new kit.web3.eth.Contract(faucetAbi, faucetContractAddress)
      
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  } else {
    notification("⚠️ Please install the CeloExtensionWallet.")
  }
}



async function celoApprove(_price) {
        const cUSDContract = new kit.web3.eth.Contract(erc20Abi, celoCOntractAddress)

        const result = await cUSDContract.methods
          .approve(faucetContractAddress, _price)
          .send({ from: kit.defaultAccount })
        return result
      }


async function cUSDApprove(_price) {
        const cUSDContract = new kit.web3.eth.Contract(erc20Abi, cUSDContractAddress)

        const result = await cUSDContract.methods
          .approve(faucetContractAddress, _price)
          .send({ from: kit.defaultAccount })
        return result
      }




//get balance form the smart contract
const getBalance = async function () {
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance
}



window.addEventListener('load', async () => {
  notification("⌛ Loading...")
  await connectCeloWallet()
  await getBalance()
  await getContractBalance()
  notificationOff()
});



    document
  .querySelector("#requestTokenId")
  .addEventListener("click", async (e) => {
    
    console.log("Requesting the tokens, Please wait")
    const addr = document.getElementById("toAddress").value
    
    try{

    	const result = await contract.methods
    		.requestTokens(addr)
    		 .send({from: kit.defaultAccount})

    		 notification("Request successful")

    }catch(error){
    	notification("Request failed")
    }


  })


 
    document
  .querySelector("#swapToken")
  .addEventListener("click", async (e) => {
    
    console.log("Awaiting swap approval of the token, Please wait")
    const tokenAmount = BigNumber(document.getElementById("swapAmount").value)
    					.shiftedBy(ERC20_DECIMALS)
                        .toString()
    
    try{

    	await cUSDApprove(tokenAmount)

    	const result = await contract.methods
    		.swapToken(tokenAmount)
    		 .send({from: kit.defaultAccount})

    		 console.log("swap successful")

    }catch(error){
    	console.log(error)
    }

  })



  async function getContractBalance(){

  	try{
  		const balance = await  contract.methods
  		.contractTokenBalance()
  		.call()

      document.querySelector("#celoBal").textContent = `${BigNumber(balance._celoBalance).shiftedBy(-ERC20_DECIMALS)}`
      document.querySelector("#cUSDBal").textContent = `${BigNumber(balance._cUSDBalance).shiftedBy(-ERC20_DECIMALS)}`

  	}catch(error){
  		notification("fetching balance failed")
  	}
  }



function notification(_text) {
  document.querySelector(".alert").style.display = "block"
  document.querySelector("#notification").textContent = _text
}

function notificationOff() {
  document.querySelector(".alert").style.display = "none"
}














