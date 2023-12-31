
# TicketSale - DApp
A Decentralized Ethereum Application Development for Distributed System Exam. This App can be used to sell Tickets for some events using blockchain technology!

**Authors**: Matteo Marco Montanari (323293), Giacomo Di Fabrizio.

**Documentation**: See **Relazione-SD.pdf** file.

## Dependencies
Install these prerequisites to use the app.
- NPM: https://nodejs.org
- Truffle: https://github.com/trufflesuite/truffle
- Ganache: http://truffleframework.com/ganache/
- Metamask: https://metamask.io/


## Step 1. Clone the project
`git clone https://github.com/GiacomoDiFa/ProgettoSD`

## Step 2. Install dependencies
```
$ cd progettoSD
$ npm install
```
## Step 3. Start Ganache
Open the Ganache GUI client that you downloaded and installed. This will start your local blockchain instance. 


## Step 4. Compile & Deploy Smart Contract
`$ truffle migrate`

You must migrate the smart contract each time your restart ganache.

## Step 5. Configure Metamask
- Unlock Metamask
- Connect metamask to your local Etherum blockchain provided by Ganache
- Import an account provided by ganache.
- Connect the account at the endpoint http://localhost:8080 (Sites Connected -> connect to the site manually)

## Step 6. Run the Front End Application
Try running this command in your terminal:

`$ npm start`

If it doesn't work you can alternatevely visit this URL in your browser: http://localhost:8080

If you get stuck, please use Google Chrome.
