

# Build A Token Faucet on the Celo Blockchain

In this tutorial, you will learn how to build dapp wih Solidity language and deploy it on the Celo blockchain


## Prerequisites

You will need to have familiarity of the following:

- Prior knowledge of [javascript](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/JavaScript_basics#:~:text=JavaScript%20is%20a%20programming%20language,styling%3B%20with%20animation%2C%20etc.)
- Familiarity with the command line
- Prior knowledge of [blockchain](http://www.blockchain-basics.com/).
- Have some knowledge on [Solidity](https://soliditylang.org/).


## Requirements
- **[NodeJS](https://nodejs.org/en/download)** from V12.or higher
- A code editor or text editor. **[VSCode](https://code.visualstudio.com/download)** is recommended
- A terminal. **[Git Bash](https://git-scm.com/downloads)** is recommended
- An Internet Browser and good internet connection
- **[Remix IDE](https://remix.ethereum.org)**
- **[Celo Extension Wallet](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en)**.


# Smart Contract Development

In this chapter, you will learn how to write a smart contract in the popular smart contract language Solidity and deploy it to the Celo blockchain.


#### Learning Objective

- [x] Learn how to write smart contracts in Solidity with the Remix IDE.
- [xWrite a smart contract for a token faucet.
- [x] Deploy your smart contract to the Celo blockchain.

In this tutorial, you will build the following smart contract: [Faucet.sol](./contract/faucet.sol)


### 1.1  Remix IDE.

Remix IDE is an open-source integrated development environment designed for writing, testing, and deploying smart contracts on the Ethereum blockchain. It provides a web-based interface that allows developers to write and compile Solidity smart contracts in their web browser, complete with features such as syntax highlighting, auto-completion, and code debugging. It also includes a built-in compiler that can compile Solidity code and generate bytecode for deployment on the Ethereum network.

Remix IDE is notable for its integration with the Ethereum Virtual Machine (EVM), which allows developers to test their smart contracts locally without needing to deploy them to the Ethereum network. The IDE includes a local blockchain environment that can be used for testing and debugging. Remix IDE also includes several plugins and extensions that can be used to enhance its functionality,uch as the Remix Debugger which allows developers to step through their code and analyze the state of variables at each step.


### 1.2  Solidity File Setup

Open [Remix IDE](https://remix.ethereum.org/) in your browser and
create a solidity file and name it faucet.sol

Once the file is created, its time to start developing our smart contract.

```solidity
// SPDX-License-Identifier: MIT  

pragma solidity >=0.7.0 <0.9.0;
```

In the first line, you specify the license the contract uses. Here is a comprehensive list of the available [licenses](https://spdx.org/licenses/.)

Using the `pragma` keyword, you specify the solidity version that you want the compiler to use. In this case, it should be higher than or seven and lower than nine. It is important to specify the version of the compiler because solidity changes constantly. If you want to execute older code without breaking it, you can do that by using an older compiler version.


```solidity
contract Faucet {    
}
```

You define your contract with the keyword `contract` and give it a name.


### 1.3 ERC20 interface
In this tutorial, since you are going to be dealing with token transfers, you need an interface to interact with the tokens and perform actinos lke transferring tokens.

IERC20 is an interface for the standard implementation of a fungible token on the Ethereum blockchain. The acronym stands for "Ethereum Request for Comment 20", and it is a technical standard used to create and interact with tokens that have the same characteristics as the Ethereum cryptocurrency, Ether.

The IERC20 interface outlines a set of functions that a smart contract needs to implement to be considered an ERC20 compliant token. These functions include the ability to transfer tokens between addresses, check an account balance, and get the total supply of tokens. Other essential functions include the approval of an allowance for a delegated transfer and the triggering of an event to notify external applications of token transfers.


```solidity
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

```
Now we have a way on how to interact with our tokens.


```solidity
   address internal celoTokenAddress = 0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9;

   uint ERC20_DECIMALS = 18;
```

Create a variable `celoTokenAddress`. first, by specifying its type(address). Then you can specify its visibilty using the keyword  internal, because you want the variable to only be accessed inside the contract. [Learn more on visibility](https://docs.soliditylang.org/en/v0.8.18/contracts.html#visibility-and-getters)

Assign it the contract address of the token(Celo), that we will be using in this tutorial.

You declare a variable `ERC20_DECIMALS`, its of type uint. Assign it the number 18, which is the number of decimals the Celo token has. [learn more on token decimals](https://docs.openzeppelin.com/contracts/3.x/erc20)



### 1.4 Request Token Function

In this section, you will enable users to request for test tokens from the faucet.
Here is how the dapp will work.
When a user requests test tokens, they will recieve 1 Celo in their address.
Users will only be able to request tokens once per 24 hours.

```solidity

contract Faucet{

	mapping (address => uint) public lastRequest;

  uint requestAmount = 10 ** ERC_DECIMALS;

   function requestTokens(address _to) public{

    require((lastRequest[msg.sender] + 1 days) < block.timestamp,"You only claim once in 24 hours");

    require(IERC20Token(celoTokenAddress).balanceOf(address(this)) >= requestAmount,"Insufficient funds");

    require(IERC20Token(celoTokenAddress).transfer(payable(msg.sender),requestAmount),"token claim failed");

    lastRequest[msg.sender] = block.timestamp;
  }

}
```
To track the last time the user requested for tokens, create a variable `lastRequest`. It is of type mapping. Mapping allows you to store key: value pairs. the key will be the address of the user, and the value will be the last time they requested the tokens. [learn more on mapping](https://docs.soliditylang.org/en/v0.8.18/types.html#)

You also declare a variable `requestAmount`, of type uint. Assign it the amount of tokens the user will recieve, in our case 1 Celo.

Next, create a function to let a user request tokens from the faucet and name it `requestTokens`.

You have to specify the type of parameter the function takes. In this case, an address. Name it `_to`. This is the address of the user who will receive the tokens.

You also define the visibility of the function as `public`.

Inside the function, first check the last time the user requested for the tokens. It should be more than 24 hours from the current time. 

You make sure this condition is always met before sending th tokens, by using the keyword `require`. If the condition inside the require keyword fails, the whole function will stop executing. [Learn more about require](https://docs.soliditylang.org/en/v0.8.18/control-structures.html#error-handling-assert-require-revert-and-exceptions)


Next, you check to make sure the smart contract has enough Celo tokens to send to the user. 

Now that all the above conditions, you go ahead and transfer the amount of tokens requested from the contract to the user's address.

Lastly, you update the last time that the user requested the tokens. Assign it the `block.timestamp`, which references the time when the function was executed. block.timestamp is a global variable. [Learn more about global variables](https://docs.soliditylang.org/en/v0.8.17/units-and-global-variables.html)


### 1.5 Swap Token Function

What shuold happens if a user needs more tokens when the 24 hour gap has not elapsed?. In this section, you will enable the user to receive Celo tokens by completing a certain task. 

The task for our case is deposting another token(cUSD) in our smart contract and in return, a user will receieve an equivalent amount of Celo tokens in their wallet.

```solidity
contract Faucet{

address internal cUsdTokenAddress =0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

 function swapToken(uint _amount) public{

        require(
              IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
              ),
              "Transfer failed"
            );

            emit cUSDTransfer(msg.sender,address(this), _amount);

            uint celoAmount = _amount;

            require(IERC20Token(celoTokenAddress).transfer(
                payable(msg.sender),
                celoAmount
                ),
                "swap failed"
            );   
            emit cUSDTransfer(address(this), msg.sender, celoAmount);
    }
  }

```
Declare a variable `cUsdTokenAddress` of type `address` and assign it the address of the token(cUSD) that the user will be depositing. 

Next, create a function `swapToken` to let the user deposit cUSD tokens and receieve Celo tokens. The function is public because you want to access it from outside the contract.


>Notice:
For this tutorial, you have used two tokens which have the same number of decimals. An amount in one token when converted to another token does not change. In real world applications, you will interact with different tokens that have different decimals.

Inside the function, create a variable of type uint and assign it the amount of tokens that the user has deposited. You will send the exact amount the user deposits, but in a diferent token.

Next, check that the smart contract has the amount that user has requested to deposit. 

First, transfer the cUSd from the user's wallet to the smart contract. Then transfer an equivalent amount od Celo tokens from the smart contract to the user's wallet address.

If any of the transaction fails, the smart contract will display an error message.


### 1.6 Get balance Function

In this section, you will write a function to show the user the amount of tokens stored in the smart contract

```solidity
contract Faucet{

   function contractTokenBalance() public view returns(uint _celoBalance,uint _cUSDBalance){
        return (
          IERC20Token(celoTokenAddress).balanceOf(address(this)),
          IERC20Token(cUsdTokenAddress).balanceOf(address(this))
        );
    }
  }
```
Create a function `contractTokenBalance`. It doesnt take in any parameter because it will only return the balance of smart contract. It is of type view. This means that the function will access and read from the state and global variables. [Learn more on View and Pure functions](https://solidity-by-example.org/view-and-pure-functions/)

The function returns two values `_celoBalance` and ` _cUSDBalance`, of type uint. 


Inside the function, you will use the keyword `return` to return the Celo token balance and cUSD token balance of the smart contract. Using the ERC20 token interface and the address of the token, you call the balanceOf method. It takes in one parameter which is the address to use.

You access the address of the contract using the `address(this)` method because you want to return its balance.

You check for the balance of two tokens stored in the smart contract.



### 1.7 Deploy the Smart Contract on the Celo blockchain.

In this section, you will you will create a Celo wallet and deploy your contract to the Celo testnet alfajores.
  
  I have created a separate guide on how to delpoy the smart contract on Celo blockchain. Check it out here.


  If you follow all the steps in the above guide, you should be able to deploy your contract on the Celo blockchain. 



  # Front End Development

  In this chapter, you will create learn to build a user interface for your dapp, and connect it to your smart contract.


  ### Learning objective

- [x] Learn how to write the HTML and JS part of your DApp.
- [x] Connect your DApp to your smart contract on the Celo blockchain with the library ContractKit.
- [x] Learn how to request tokens from the smart contract
- [x] Learn how to swap a token for another.


(time)

At the end of this chapter, you should have something similar to this. (User Interface for the faucet dapp).
![User interface](./real.png)


### 2.1 Initializing your project.(time)

To speed up the development process, you are going to use a boilerplate. It comes with the necessary libraries and packages required for our dapp.

1 Open your terminal and clone the boilerplate from the repository

```js
git clone 
````

2. Navigate to the new repository

```js
cd 
````

3. Now, install all dependencies

```js
npm install
````

4. Start a local development server

```js
npm run dev
````
Your project should be up and running. Access it on htp://localhost:3000 in your browser


### 2.2 The HTML of the Dapp (time)

In this section, you will start with basics of your Dapp, the HTML

Using your favorite code editor, open the index.html file inside the public folder of the project

```html
<!DOCTYPE html>
<html>
<head>
  <!DOCTYPE html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
```
Start by declaring the document type, followed by the head element and meta tags.


```html
<link
      href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css"
      rel="stylesheet"
      integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl"
      crossorigin="anonymous"
    />
    <link
      rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.0/font/bootstrap-icons.css"
    />
     <link rel="preconnect" href="https://fonts.gstatic.com" />
  <link
    href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap"
    rel="stylesheet"
  />

  <title>Faucet</title>

</head>
```
Import external stylesheets, one of which is bootstrap, a popular front-end library that allows you to create resaponsive websites with ease.[Learn more on bootstrap](https://getbootstrap.com/)

And then, add a title.

```html
  <style type="text/css">
    .overall{
      background-color: rgb(183, 187, 188);
      margin-top: 70px;
      margin-left: 100px;
    }

    .first{
      border-radius: 12px;
      margin: .5rem;
      padding: 1rem;
      outline-offset: 0.5rem;
      background-color: #D8D8D8;
    }
    .second{
      border-radius: 12px;
      margin: .5rem;
      padding: 1rem;
      outline-offset: 0.5rem;
      background-color: #D8D8D8;

    }

    span{
      font-size: 12px;
    }

    h4{
      font-size: 20px;
      font-weight: bold;
    }
    h3{
      font-size: 15px;
    }
    .third{
      border-radius: 12px;
      margin: .5rem;
      padding: 1rem;
      outline-offset: 0.5rem;
      background-color: #D8D8D8;
    }

    body{
     background: rgb(183, 187, 188);
    }

    .navbar{
      border-radius: 12px;
      background-color: gold;
    }

    input{
      border-radius: 8px;
      border-color: burlywood;

    }
    .divSpace{
      margin-top: 15px;
    }

    .fir{
      border-radius: 10px;
      border-color: burlywood;
    }
    .btn{
      margin-top: 10px;
      border-color: brown;
      background-color: gold;
    }
  </style>

```
Add some CSS to add some design to the page.

```html 
<body>
<div class="container mt-2" style="max-width: 72em">
  <nav class="navbar bg-success navbar-light">
        <div class="container-fluid">
          <span class="navbar-brand m-0 h4 fw-bold">Faucet</span>
          <span class="nav-link border rounded-pill bg-light">
            <span id="balance">0</span>
            cUSD
          </span>
        </div>
      </nav>
```
Inside the body tag, create a naviagtion bar to display the name of the dapp and the cUSD balance.


```html
<div class="alert alert-warning sticky-top mt-2" role="alert">
    <span id="notification">⌛ Loading...</span>
</div>

```
Create a div for the notifications that you want to display to the user. This div has the class alert that you will later select in your JS code. The span element has the id notification, that you will use to insert the text that you want to display.


```html

<main id="faucet" class="row"></main>
```
Add the main tag with the id faucet. We will render our content inside this tag.

You will use flex box to display three div elements inside the main tag.

```html
 <div class="d-flex flex-row overall">
  <div class="d-flex flex-row first">
    <div class="p-2 fir">
      <h4>Get Test Tokens</h4>
      <div class="divSpace">
        <span>This faucet transfers test tokens on Alfajores testnet.</span><br>
        <span>Confirm details before submitting.</span>
      </div>
      <div class="divSpace">
        <h4>Network</h4>
        <span>Alfajores</span>
      </div>
      <div class="divSpace">
        <h4>Wallet Address</h4>
        <input type="text" name="test" id="toAddress">
      </div>
      <button class="btn" type="submit" id="requestTokenId">Submit</button>
    </div>
```

The first div displays an interface to enable the user to request tokens from the dapp.

```html
<div class="p-2 second">
    <h3>Token balance</h3>
    <table class="table table-fixed">
      <thead class="thead-dark">
        <tr>
          <th scope="col">Celo</th>
          <th scope="col">cUSD</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td id="celoBal">loading...</td>
          <td id="cUSDBal">loading...</td>
        </tr>
      </tbody>
    </table>

     Note: 
    <ol type="1" >
      <li class="list-group-item">After submitting, you will recieve 1 Celo token in your wallet.</li>
      <li class="list-group-item">You can only claim the test tokens once in 24 hours</li>
       <li class="list-group-item">Donate excess Celo tokens to this address.<br>0xc94f1eaB4B3E9427Fa9aaF602dF7ED07217Ce73b</li>
    </ol>
  </div>
</div>

```
Inside the second div element, create a table element to display the token balances from the smart contract.
Then, create an ordered lsit elemt to display some notice for the user.

The last list item displays the address of the smart contract because you want a user to send excess test tokens back to the smart contract.


```html
<div class="p-2 third">
            <h4>Swap Tokens</h4>
            <span>Deposit cUSD to receive Celo tokens</span><br>
            <div class="divSpace">
              <h5>cUSD <span>to</span> Celo</h5>
              <input type="number" name="swapAmount" id="swapAmount" placeholder="Enter amount of cUSD to deposit">
            </div>
            <button class="btn" type="submit" id="swapToken">Swap</button>
          </div>

        </div>
      </main>
    </div>
```
Create a div element to enable a user to swap cUSD tokens for Celo tokens.


Here is how the dapp should like with only the HTML now.
![Dapp front-end]()




### 2.3 The JS of your dapp(time)

In this section of the tutorial, you will add the basic functionality of your DApp. You will create a functioning dapp in vanilla Javascript with sample products that is not yet connected to the Celo blockchain.


#### 2.3.1 Interact with the smart contract.(time)

In this section of the tutorial, you are going to use the contractKit library to interact with the Celo Blockchain. ContractKit includes web3.js, a very popular collection of libraries also used for ethereum, that allows you to get access to a web3 object and interact with node's JSON RPC API (Learn more about contractKit).

In order to interact with your smart contract, you need its ABI(Application Binary Interface). When you compile the contract in Remix, you create an ABI in a Json format. copy it and poaste it in the `faucet.abi.json` file inside the contract folder.


```js
import Web3 from 'web3'
import { newKitFromWeb3 } from '@celo/contractkit'
import BigNumber from "bignumber.js"
import faucetAbi from '../contract/faucet.abi.json'
import erc20Abi from "../contract/erc20.abi.json"

const ERC20_DECIMALS = 18
let kit
let contract
let accounts
````

Import the newKitFromWeb3, Web3, and BigNumber objects from their respective libraries.

Many Celo operations operate on numbers that are outside the range of values used in Javascript. In this case we will use bignumber.js because it can handle these numbers.

Create the variable ERC20_DECIMALS and set it to 18. By default, the ERC20 interface uses a value of 18 for decimals. Since cUSD, the Celo currency that you are going to use here, is an ERC20 token, use ERC20_DECIMALS to convert values.

You should also declare global variables for contractKit, contract and accounts because you are going to need them for multiple functions.

```js
const faucetContractAddress = "0x3d750214E24A89C9a0A2259421AE361dA1753D67"

const celoCOntractAddress = "0xF194afDf50B03e69Bd7D057c1Aa9e10c9954E4C9"

````
When you delpoy the contract, you will need its address in order to interact with it. Declare three variable; `faicetContractAddress` to hold the address of the contract and `celoContractAddress` to hold the address of the celo token


#### 2.3.2 Connect to Celo Blockchain

In thi section, you will create a function to connect to the Celo extension wallet.

```js
const connectCeloWallet = async function () {
  if (window.celo) {
      notification("⚠️ Please approve this DApp to use it.")
    try {
      await window.celo.enable()
      notificationOff()

      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)

    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  } else {
    notification("⚠️ Please install the CeloExtensionWallet.")
  }
}
````

Create a new asynchronous function called `connectCeloWallet` that you will then use to connect to the Celo Blockchain and read the balance of the user.

First, check if the user has installed the CeloExtensionWallet. Do that by checking if the “window.celo” object exists. If it doesn’t exist, use a notification to let them know that they need to install the wallet.

If the object does exist, send them a notification that they need to approve this DApp and try the window.celo.enable() function. This will open a pop-up dialogue in the UI that asks for permission to connect the DApp to the CeloExtensionWallet. After Celo is enabled, you should disable the notification.

If you catch an error, let the user know that they must approve the dialogue to use the DApp.

Once the user approves the DApp, create a web3 object using the window.celo object as the provider. With this web3 object, you can create a new kit instance that you can save to the global kit variable. Now, the functionality of the connected kit can interact with the Celo Blockchain.


```js
 const accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]
````
Add this code beneath the kit instance in your connectCeloWallet function. This returns an array of addresses of the connected user. The first address in the array is set as the default account


#### 2.3.3 Read the user's cUSD token balance

In this section, you will create a function to read the token balance of the user on the Celo blockchain

```js
const getBalance = async function () {
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance
}
````
Create an asynchronous function `getBalance`. With kit’s method kit.getTotalBalance, you can get the total balance of an account. In this case, you want the balance from the account that interacts with the CeloExtensionWallet — the one you stored in kit.defaultAccount.

In the next line, you get a readable cUSD balance. Use totalBalance.cUSD.to get the cUSD balance. Since it’s a big number, convert it to be readable by shifting the comma 18 places to the left and use toFixed(2) to display only two decimal places after the decimal point.

Display the cUSDBalance in the corresponding HTML element.

#### 2.3.4 Approve Function

```js


async function celoApprove(_price) {
        const cUSDContract = new kit.web3.eth.Contract(erc20Abi, celoCOntractAddress)

        const result = await cUSDContract.methods
          .approve(faucetContractAddress, _price)
          .send({ from: kit.defaultAccount })
        return result
      }
```

### 2.4 Event handlers
In this section, you will learn to add event listeners and handle events.


#### 2.4.1  Window loading for the first time.

```js
window.addEventListener('load', async () => {
  notification("⌛ Loading...")
  await connectCeloWallet()
  await getBalance()
  await getContractBalance()
  notificationOff()
});
```

When the window loads for the first time, you want to show the user that the page is loading using the notification function.

Then you run a function to connect to the Celo wallet.

Next, Get the balance of the wallet connected to the Dapp and finally retreive the token balance of the smart contract.


#### 2.4.2 Request tokens from your contract(time)

In this section of the tutorial, you will connect to your smart contract, as well as request tokens from it when a certain event happens.

```js
  document
  .querySelector("#requestTokenId")
  .addEventListener("click", async (e) => {
   
    const addr = document.getElementById("toAddress").value

     notification("Requesting tokens, Please wait")
    try{

      const result = await contract.methods
        .requestTokens(addr)
         .send({from: kit.defaultAccount})

         notification("Request successful")

    }catch(error){
      console.log(error)
    }

  })
````
When the user clicks on a button with the id `requestToken`, you get the value of the element with the id `toAddress`. This will be the address that wants to receive the test tokens.

  Notify the user of what is happening.

Call the requestToken function.It takes in one parameter, the address of the wallet to receive the tokens.

If there is an error in the function execution, you will display a message to the user.


#### 2.4.3 Swap token function
In this section, you will learn how to create a swap token function to allow a user to exchange their cuSD tokens for Celo tokens.

```js
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"

async function cUSDApprove(_price) {
        const cUSDContract = new kit.web3.eth.Contract(erc20Abi, cUSDContractAddress)

        const result = await cUSDContract.methods
          .approve(faucetContractAddress, _price)
          .send({ from: kit.defaultAccount })
        return result
      }
```
 Create a variable `cUSDContractAddess` to hold the contract address of the cUSD token.

 Next, create a copy of the celoApprove function and modify it to cater for cUSD.

```js
  document
  .querySelector("#swapToken")
  .addEventListener("click", async (e) => {
    
    notification("Awaiting swap aproval of the token, Please wait")
    const tokenAmount = BigNumber(document.getElementById("swapAmount").value)
              .shiftedBy(ERC20_DECIMALS)
                        .toString()
    
    try{

      await cUSDApprove(tokenAmount)

      const result = await contract.methods
        .swapToken(tokenAmount)
         .send({from: kit.defaultAccount})

         notification("Swap successful")

    }catch(error){
      notification(error)
    }

```
When the user clicks on a button with the id swapToken, you get the value of the element with id `swapAmount`. This is the amount of cUSD the user wants to swap.
You convert the value to a Big Number with 18 decimals using the BigNumber method.

Next, call the cUSDApprove function to allow the smart contract spend funds on behalf of the user.
The function takes in one parameter, which is the amount the user wants to spend.

Then call the swap function on the contract. This will deduct the cUSD from the user's account and in exchange, deposit an equivalent number of Celo tokens to the user's address.


#### 2.4.4 Contract token balance function
In this section, you will learn how to write a function to get the balance of the tokens from the smart contract.

```js
 async function getContractBalance(){
    console.log("working")

    try{
      const balance = await  contract.methods
      .contractTokenBalance()
      .call()

      document.querySelector("#celoBal").textContent = `${BigNumber(balance._celoBalance).shiftedBy(-ERC20_DECIMALS)}`
      document.querySelector("#cUSDBal").textContent = `${BigNumber(balance._cUSDBalance).shiftedBy(-ERC20_DECIMALS)}`
      
      console.log("token balance",balance)

    }catch(error){
      console.log(error)
    }
  }
````

Declare an async function `getContractBalance`. Inside the function, call the contractTokenBalance method on the smart contract. It returns an object containing the Celo and cUSD token balance for the smart contract. 

Next, update the tect ccontext of the elements with ids `celoBal` and `cUSDBal` with their values respectively. 

In case of an error, display an error message to the user.

```js
function notification(_text) {
  document.querySelector(".alert").style.display = "block"
  document.querySelector("#notification").textContent = _text
}

function notificationOff() {
  document.querySelector(".alert").style.display = "none"
}

````
Create a `notification` function that displays the alert element with the text as the parameter and a `notificationOff` function that stops showing the alert element.


 ### 2.5 Host the dapp on github pages

 In this section, you will learn how to host your completed project on Github Pages.

After testing that your dapp works correctly,

it is time to build your dapp. Run this command in your terminal
```js
npm run build
```

Upon completion, you will now have a new folder `docs` containing an html and js file.

- Upload your project to a new GitHub repository.
- Once inside your repository, click on settings and scroll down to a section called GitHub Pages.
- Select the master branch and the docs folder as the source for your GitHub pages.


Congratulations, you have made it to the end. You now have a fully functional dapp running on the Celo blockchain.


code for the full dapp.

## Conclusion

In this tutorial, you have learnt how to build a full stack faucet dapp running on Celo blockchain, and deploying it to github pages. With the knowledge gained, you can now aply it to build more fully functional dapps.




