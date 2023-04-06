pragma solidity ^0.8.0;
// 1. Write a Solidity function to transfer tokens from one address to another.

function transfer(address _to, uint256 _amount) public returns(bool) {
    require(_to != address(0), "Invalid Recepient Address"); // Ensure the recipient address is not zero address

    //Make sure the sender has enough tokens
    //require(balances[_to] + _amount > balances[_to]); // Ensure no overflow can occur
    require(_amount <= balances[msg.sender], "Insufficient Balance");

    //Update the balances
    balances[msg.sender] -= _amount;
    balances[_to] += _amount;

    emit transfer(msg.sender, _to, _value);

    return true;
}

/* This function takes two arguments: _to, which is the address of the recipient, and _amount, which is the amount of 
tokens to transfer. The function first checks that the recipient address is valid and the transfer amount is greater
than zero. It then checks that the sender has enough tokens to make the transfer.

If all checks pass, the function updates the balances of the sender and recipient accordingly and emits a 
Transfer event to signal that a transfer has occurred.

Note that this code assumes that the token balances are stored in a mapping called balances, and that the contract
emits a Transfer event whenever a transfer occurs.
*/


// 2. Write a Solidity function to withdraw funds from a smart contract.

function withdraw(_amount) public {
    require(_amount <= address(this).balance, "Insufficient contract balance to transfer");
    require(msg.sender == owner, "Only Owner can transfer the fund");

    payable(owner).transfer(_amount);
    emit withdrawal(owner, _amount);

}

/*
This function takes one parameter, _amount, which is the amount of ether to withdraw from the smart contract.

The function first checks if the contract has enough ether to withdraw the requested amount. If not, it 
throws an error and the withdrawal will not occur.

Next, the function checks if the caller is the owner of the contract (you can modify this to check for 
other roles if necessary). If the caller is not the owner, the function throws an error and the withdrawal will not occur.

If the conditions are met, the function transfers the requested amount of ether to the owner's address using 
the transfer function. It also emits a Withdrawal event to notify other nodes of the transaction.

Note that this function assumes that the contract has a balance of ether that can be withdrawn, and that the
owner address is defined elsewhere in the contract. Also, be careful when handling funds in a smart contract 
and ensure proper security measures are taken to prevent unauthorized access to the funds.
*/

// 3. Write a Solidity function to check the balance of a given address.

function getBalance(address _addr) public view returns (uint256) {
    return address(_addr).balance;
}

/*
This function takes one parameter: _addr, which is the address to check the balance of.

The function uses the balance property of the address type to retrieve the balance of the 
given address. This property returns the current balance of the address in wei, which is the
smallest unit of Ether.

The function then returns the balance as a uint256 value.

Note that this function is marked as view, which means that it does not modify the state of the
contract and can be called without sending a transaction. Also, remember that the balance of an address 
can only be checked on the blockchain that the address belongs to.
*/

//4. Write a Solidity function to implement a time-locked contract, which allows funds to be withdrawn only after a certain time has elapsed.

Contract TimeLockedContract {
    address payable public beneficiary;
    uint public releaseTime;

    constructor (address payable _beneficiary, uint _releaseTime) payable {
        require(_releaseTime > block.timestamp, "Release time must be in the future");
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    function release () public {
        require(block.timestamp >= releaseTime);
        require(msg.sender == beneficiary, "Only the beneficiary can withdraw funds.");
        uint amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");
        beneficiary.transfer(amount);
    }
}

/*
The beneficiary variable is the address that will receive the funds when the contract is unlocked.

The releaseTime variable is the timestamp after which the funds can be withdrawn.

The constructor ensures that the releaseTime is in the future, to prevent the contract from being 
immediately unlocked.

The release function checks if the current time is past the releaseTime and if so, transfers the entire balance of 
the contract to the beneficiary address.

To use this contract, you would deploy it to the Ethereum network with the beneficiary's address and the 
release time as arguments to the constructor. After the release time has passed, the beneficiary can call 
the release function to withdraw the funds.

*/

// 5. Write a Solidity function to implement a voting system, where each address can vote only once.
Contract VotingSystem {
    mapping(address => bool) public hasVoted;
    mapping(uint256 => uint256) public voteCount;

    function vote (address candidateId) public {
        require(!hasVoted[msg.sender], "Address has already voted");

        voteCount[candidateId]++;
        hasVoted[msg.sender] = true;
    }

    function getVoteCount(address candidateId) public view returns (uint256) {
        return voteCount[candidateId];
    }
}

/*
The VotingSystem contract uses two mappings: hasVoted to keep track of whether an address has already voted, and 
voteCount to keep track of the number of votes for each candidate.

The vote function takes a candidateId parameter and first checks if the sender's address (msg.sender) has already 
voted using the hasVoted mapping. If the sender has already voted, the function reverts with an error message.

If the sender has not voted yet, the function increments the vote count for the specified candidate using the 
voteCount mapping and sets the hasVoted flag for the sender's address to true.

The getVoteCount() function can be used to retrieve the current vote count for a given candidate. This function 
is marked as view because it does not modify the state of the contract.
*/

// 6 Write a Solidity function to implement a basic ERC-20 token.
/* ERC20 is the protocol standard for creating Ethereum-based tokens, which can be utilized and deployed in the Ethereum network.

 A token is a digital asset that is created and managed on a blockchain platform. Tokens can represent various types of 
 assets, such as cryptocurrency, assets or utilities within a decentralized application (dApp), or even real-world assets 
 like property or art.
 */

 Contract MyToken () {
    string public name;
    string public symbol;
    string public decimal;
    uin256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value)

    /*
    The outer mapping mapping(address => mapping(address => uint256)) maps owner addresses to another mapping 
    which maps spender addresses to allowance values. This allows multiple owners to have their own list of approved 
    spenders and corresponding allowances. 
    */

    constructor(string memory _name, string memory _symbol, uint256 _decimal, uint256 _totalSupply){
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        totalSupply = _totalSupply
        balance[msg.sender] = _totalSupply;
    }

    function Transfer (address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient Balance");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function Approval (address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Transfer(msg.sender, _spender, _value);
        return true;
    }

    /*
    allowance[msg.sender][_spender] = _value; This line sets the allowance for the spender, by 
    updating the allowance mapping with the owner's address and the spender's address as keys, and the _value 
    parameter as the value.
    */

    function TransferFrom(address _from, address _to, address _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient Balance");
        require(allowance[_from][msg.sender] >= _value, "Not authorized to spend");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
 }



 /*
 This contract defines the basic functions required by the ERC-20 token standard, including transfer, approve, 
 and transferFrom. The constructor sets the initial supply of the token and assigns it to the contract owner's address.

The balanceOf mapping keeps track of the balance of each address, and the allowance mapping keeps track of the 
amount that each address is authorized to spend on behalf of another address.

The transfer function transfers tokens from the sender's account to another address. The approve function allows 
an address to spend tokens on behalf of the sender, up to a specified amount. The transferFrom function transfers 
tokens from one address to another, on behalf of the sender, if authorized.

Note that this is a basic implementation of an ERC-20 token and may need additional functions or modifications to meet 
specific project requirements.
*/

// 7.Write a Solidity function to implement a crowdsale, where tokens are sold in exchange for ether.

/*Crowdsale system is a fundraising mechanism used by blockchain-based projects to raise funds for their development. It 
involves the sale of tokens or cryptocurrencies to investors in exchange for funding
*/
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

Contract Crowdsale {
    address public rate; 
    address public cap;
    address public raised;
    address public token;

    constructor(uint256 _rate, uint256 _cap, IERC20 _token) {
        owner = msg.sender;
        rate = _rate;
        cap = _cap;
        token = _token;
    }

    function BuyToken () public payable {
        require(msg.value >= 0, "Unsufficient Balance");
        require(raised + msg.value <= cap, "Cap Exceeded");

        uint256 tokens = msg.value * rate;
        require(tokens <= token.balanceOf(address(this)), "Insufficient balance in the contract");

        raised += msg.value;
        token.transfer(msg.sender, tokens);
        emit BoughtTokens(msg.sender, Tokens);
    }

    function withdrawEther() public {
        require(msg.sender == owner, "only owner can withraw the funds");
        payable(owner).transfer(address(this).balance);
    }

    function withdrawTokens() {
        require(msg.sender == owner, "Only owner can transfer the money");
        uint ramainingokens = token.balanceOf(address(this));
        require(remainingTokens > 0, "No token left in the contract");
        token.transfer(owner ,remainingTokens);
    }

    function getBalance () public view returns (uint256) {
        return address(this).balance;
    }

    function get tokenBalance () public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}

/*
This contract has the following features:

owner: the address of the contract owner who can withdraw the ether and tokens after the crowdsale has ended
rate: the exchange rate of tokens to ether, expressed in tokens per ether
cap: the maximum amount of ether that can be raised during the crowdsale
raised: the current amount of ether that has been raised during the crowdsale
token: the ERC-20 token being sold during the crowdsale
BoughtTokens event: emitted when tokens are purchased during the crowdsale

The constructor function sets the initial values for the rate, cap, and token variables, and sets the owner to be the 
address of the contract deployer.

The buyTokens function is called by buyers to purchase tokens with ether. It requires that a non-zero amount of ether 
is sent, and that the cap has not been exceeded. The function calculates the number of tokens to be sold based on the 
rate, and checks that the contract has enough tokens to sell. If everything checks out, the function transfers the tokens 
to the buyer and emits the BoughtTokens event.

The withdrawEther function can be called by the owner to withdraw any ether that has been raised during the crowdsale. 
Only the owner can call this function.

The withdrawTokens function can be called by the owner to withdraw any unsold tokens that are still in the contract. Only 
the owner can call this function.

The getBalance and getTokenBalance functions return the current balance of ether and tokens in the contract, respectively.
*/

// 8 Write a Solidity function to implement a decentralized exchange, where users can trade ERC-20 tokens.

contract DecentralizedExchange {
    mapping(address => mapping (address => uint256)) public tokens;

    function trade (address token1, uint256 amount1, address token2, uint256 token2, unit256 amount2)  public {
        require(tokens[token1][msg.sender] >= amount1, "Insufficient balance of token1");
        require(IERC20(token2).balanceOf(address(this)) >= amount2, "Insufficient balance of token2");

        tokens[token1][msg.sender] -= amount1;
        tokens[token1][address(this)] += amount1;

        IERC20(token2).transferFrom(address(this), msg.sender, amount2);
        tokens[token2][msg.sender] += amount2;
    }
}
/*
In this example, the DecentralizedExchange contract keeps track of the balances of ERC-20 tokens that users have 
deposited. The tokens mapping stores the balance of each token for each user. When a user wants to trade token1 
for token2, they call the trade function with the addresses of the two tokens and the amounts they want to trade.

The function first checks that the user has sufficient balance of token1 to make the trade and that the contract 
has sufficient balance of token2. If these conditions are met, the function transfers the user's token1 to the 
contract, and then transfers token2 from the contract to the user. Finally, the function updates the balances 
of both tokens for the user.

Note that this is a very simple example and would need to be expanded to include more robust error handling, market 
pricing, and other features necessary for a functional decentralized exchange.
*/


//-----------------------------------OR--------------------------------------------
Interface IER20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function balanceOf(address account) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
}

contract DecentralizedExchange {
    mapping(address => mapping (address => uint256)) public balances;

    function trade (address _fromToken, address _toToken, uint256 _fromAmount, uint256 _toAmount) external {
        require(balances[_fromToken][msg.sender] >= _fromAmount, "Insufficient balance");
        require(IERC(_toToken).balanceOf(address(this)) >= _toAmount, "Insufficient liquidity");

        balances[_fromToken][msg.sender] -= _fromAmount;
        balances[_toToken][msg.sender] += _toAmount;

        IERC20(_fromToken).transferFrom(msg.sender, address(this), _fromAmount);
        IERC20(_toToken).transfer(msg.sender, _toAmount);

        emit Trade (_fromToken, _toToken, _fromAmount, _toAmount);
    }

    function deposite(address _token, uint256 _amount) external {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        balances[_token][msg.sender] += _amount;
    }

    function withdraw(address _token, uint256 _amount) {
        require(balances[_token][msg.sender] >= _amount, "Insufficient Balance");
        balances[_token][msg.sender] -= _amount;
        IERC20(_token).transfer(msg.sender, _amount);
    }
}

/*
The above contract allows users to trade ERC20 tokens by calling the trade function, which takes the following parameters:

_fromToken: the address of the ERC20 token being sold.
_toToken: the address of the ERC20 token being bought.
_fromAmount: the amount of the _fromToken being sold.
_toAmount: the amount of the _toToken being bought.

The function checks that the seller has enough _fromToken to sell and that there is sufficient liquidity of _toToken in 
the contract. If the checks pass, the function deducts the _fromAmount from the seller's balance and adds the _toAmount to 
the buyer's balance. It then transfers the _fromAmount from the seller to the contract and transfers the _toAmount from the 
contract to the buyer. Finally, it emits a Trade event.

The deposit and withdraw functions allow users to deposit and withdraw tokens from the contract. The balances mapping keeps 
track of the balances of each token for each user.
*/

//8 Write a Solidity function to implement a multi-signature wallet, where funds can be released only with the approval of multiple addresses.

//A Multisignature Wallet (miltisig Wallet) is a type of cryptocurrency wallet that requires more than one person to authorize transaction

Contract MultisignatureWallet {
    address [] publuc owners;
    mapping (address => bool) public isOwner; 
    uint public numConfirmationRequired;
    mapping (address => bool ) public isConformed;
    mapping(address => uint) public balances;

    struct Transaction {
        address to;
        uint amount;
        bool executed;
        uint numConfirmation;
    } 

    Transaction[] public transactions;

    constructor (address [] memory _owners, uint _numConfirmationRequired) {
        require(_owners.length > 0, "owners required");
        require(_numConfirmationRequired > 0 && _numConfirmationRequired <= _owners.length, "Invalid number of confirmation required");

        for(uint i=0; i<_owners.length; i++) {
            address owner = _owners[i];
            require(owners != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate Owner");
            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationRequired = _numConfirmationRequied;
    }

    /*
    The constructor function takes in an array of addresses _owners and a number of required confirmations 
    _numConfirmationsRequired and initializes the contract.

    The function first checks that there is at least one owner in the _owners array and that the number of 
    required confirmations is a valid number between 1 and the number of owners.

    Next, the function iterates through the _owners array, checks that each owner is a valid non-zero address and that 
    the address is not already an owner. If the owner address passes these checks, it is added to the owners array and 
    marked as an owner in the isOwner mapping.

    Finally, the function sets the number of confirmations required for each transaction in the numConfirmationsRequired 
    variable.
    */

    function submitTransaction (address _to, uint _amount) public {
        require(isOwner[msg.sender] , "Not an owner");
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Invalid amount");
        
        uint transactionId = transactions.length;
        transactions.push(Transaction ({
            to: _to;
            amount : _amount;
            executed : false;
            numConfirmation = 0;
        }));

        confirmTransaction(transactionId);
        return transactionId;
    }

    /*
    The submitTransaction function allows an owner to submit a new transaction for approval. The function takes in the recipient 
    address _to and the amount of funds to transfer _amount.

    The function first checks that the sender is an owner of the contract, the recipient address is valid and non-zero, and the 
    amount to transfer is greater than zero.

    Next, the function creates a new transaction by adding a new element to the transactions array with the given recipient 
    address, amount, and default values for executed and numConfirmations.

    The function then calls the confirmTransaction function with the ID of the newly created transaction to add the first confirmation.

    Finally, the function returns the ID of the newly created transaction.
    */

    function conformTransaction (address _trnsasctionId) public {
        require(_transactionId < transactions.length, "Invalid Transaction Id");
        Transaction storage transaction = transactions[_transactonId];
        require(!transacion.executed, "Transaction alresdy executed");
        require(isOwner[msg.sender], "Not an owner");
        require(!isConfirmed[msg.sender], "Transaction already confirmed");

        transaction.numConfirmation++;
        isConfirmed[msg.sender] = true;

        if(transaction.numConfirmation >= numConfirmantoinRequired) {
            transaction.executed = true;
            isConfimed = mapping(address => bool);
            balances[transactionId] += transaction.amount;
        }
    }

    /*
    The confirmTransaction function allows an owner to confirm a transaction. The function takes in the ID of the 
    transaction to confirm _transactionId.

    The function first checks that the transaction ID is valid and that the transaction has not already been executed. It 
    then checks that the sender is an owner, that they have not already confirmed this transaction, and increments the 
    number of confirmations for the transaction.

    The function also marks the sender's address as confirmed in the isConfirmed mapping.

    If the number of confirmations for the transaction equals or exceeds the required number of confirmations, the function 
    marks the transaction as executed, resets the isConfirmed mapping, and transfers the specified amount of funds to the recipient 
    address.

    Note: This implementation assumes that the contract holds the funds and that there is a balances mapping to keep track of the 
    balance of each address. If this is not the case, some modifications may be necessary.
    */
    function withdraw (address payable _to, uint _amount) {
        require(isOwner[msg.sender], "Not an owner");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(_to != address(0), "Invalid address of recipient");
        require(amount > 0, "Incvalid amount");

        balances[msg.sender] -= _amount;
        _to.transfer(_amount);
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getTransactionLength () public returns (uint256) {
        return transaction.length;
    }

    function getTransaction (uint _transactionId) public view returns (address, uint, bool, uint) {
        require(_transactionId < transactions.length, "Invalid Id");
        Transaction storage transaction = transactions[_transactionId];
        return(transaction.to, tranasaction.amount, tranasaction.executed, transaction.numConfirmations);
    } 

    /*
    The MultiSigWallet contract defines a list of owners, a mapping to check if an address is an owner, the number of confirmations 
    required to execute a transaction, a mapping to check if an address has confirmed a transaction, a mapping to store the balances 
    of the owners, and a list
    */
}








