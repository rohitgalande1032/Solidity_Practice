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
        balanceOf[msg.sender] = _totalSupply;
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
    address [] public owners;
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
            require(owner != address(0), "Invalid owner");
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

// 9. Write a Solidity function to implement a staking system, where users can earn rewards for holding tokens.

Interrface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
contract Staking {
    IERC20 public token;
    mapping(address => uint256) public stakedBalance;
    uint256 public totalStakedBalance;
    uint256 public rewardPerToken;
    mapping(address => uint256) public rewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    function stake (uint256 amount) external {
        require(amount > 0, "Amount mast be greater than 0");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient Balance");
        updateReward(msg.sender);
        token.transferFrom(msg.sender, address(this), amount);
        stakeBalance[msg.sender] += amount;
        totalStakedBalance += amount; 
        emitStaked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        updateReward(msg.sender);
        stakedBalance[msg.sender] -= amount;
        totalStakedBalance -= amount;
        token.transfer(msg.sender, amount);
        emit withdrawn(msg.sender, amount);
    }

    function claimReward() external {
        updateReward(msg.sender);
        uint256 reward = rewards[msg.sender];
        require(reward > 0, "No reward to claim");
        rewards[msg.sender] = 0;
        token.transfer(msg.sender, reward);
        emit rewardPaid(msg.sender, amount);
    }

    function updateReward(address account) internal {
        rewardPerToken += (block.timestamp - lastUpdateTime) * totalStakedBalance / 1e18;
        rewards[account] += (stakedBalance[account] * (rewardPerToken - userRewardPerTokenPaid[account])) / 1e18;        
        userRewardPerTokenPaid[account] = rewardPerToken;
        lastUpdateTime = block.timestamp;
    }
}

/*
This contract allows users to stake their tokens and earn rewards based on the amount they have staked. Here is a breakdown of how it works:

The IERC20 interface is used to interact with the token contract.
The token variable is the address of the token contract.
The stakedBalance mapping keeps track of the amount of tokens each user has staked.
The totalStakedBalance variable keeps track of the total amount of tokens staked by all users.
The rewardPerToken variable keeps track of the amount of reward tokens earned per staked token.
The rewards mapping keeps track of the amount of rewards earned by each user.
The Staked, Withdrawn, and RewardPaid events are emitted when a user stakes, withdraws, or claims rewards, respectively.
The stake function allows users to stake their tokens. It checks that the amount is greater than 0 and that the user has sufficient balance. It then updates the user's staked balance and the total staked balance, transfers the tokens from the user to the contract, and emits the Staked event.
The withdraw function allows users to withdraw their tokens. It checks that the amount is greater than 0, updates the user's staked balance and the total staked balance, transfers the tokens from the contract to the user
*/

// 11. Write a Solidity function to implement a lottery, where users can buy tickets for a chance to win a prize.

contract Lottery {
    address public manager; //address of contract manager
    uint public ticketPrice; //price of each lottery ticket
    address[] public players; //array of players in the lottery
    uint public endTime; //timestamp when lottery ends
    address public winner; // address of the winner

    constructor(uint _ticketPrice) {
        manager = msg.sender;
        ticketPrice = _ticketPrice;
        endTime = block.timestamp + 1 weeks //lottery runs for one week
    }

    function buyTicket () public payable {
        require(msg.value == ticketPrice, "Ticket price must be in full");
        players.push(msg.sender);
    }

    function endLottery() public {
        require(msg.sender == manager, "Only manager can end the lottery");
        require(block.timestamp >= endTime, "Lottery is still ongoing");
        require(!ended, "Lottery has already ended");

        uit winnerIndex = uit(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players.length))) % players.length;
        winner = players[winnerIndex];
        ended = true;
    }

    function withdraw() public {
        require(msg.sender == winner, "Only the winner can withdraw the prize");
        require(ended, "Lottery has not ended yet");

        uint prize = address(this).balance;
        payable(winner).transfer(prize);
    }
}
 /*
 In this implementation, the contract manager sets the ticket price and the end time for the lottery. Players can buy tickets by calling
  the buyTicket() function and sending the correct amount of Ether. Once the end time is reached, the contract manager can call endLottery() 
  to select a winner randomly from the array of players. The winner can then withdraw the prize by calling the withdraw() function. Note that the 
  contract allows only the winner to withdraw the prize, and only after the lottery has ended.
 */

 contract Lottery {
    address public manager;
    address[] public players;
    uint public ticketPrice;
    uint public minimumPlayers;
    uint public prizePool;
    bool public isOpen;

    constructor(uint _ticketPrice, uint _minimumPlayers) {
        manager = msg.sender;
        ticketPrice = _ticketPrice;
        minimumPlayers = _minimumPlayers;
        isOpen = true;
    }

    function enter() public payable {
        require(isOpen, "Lottery is closed");
        require(msg.value == ticketPrice, "Invalid ticket price");
        players.push(msg.sender);
        prizePool += msg.value;
    }

    function getPlayersCount() public view returns (uint) {
        return players.length;
    }

    function pickWinner() public restricted {
        require(isOpen == false, "Lottery is still open");
        require(players.length >= minimumPlayers, "Not enough players");
        uint index = random() % players.length;
        address winner = players[index];
        payable(winner).transfer(prizePool);
        isOpen = true;
        players = new address[](0);
        prizePool = 0;
    }

    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    modifier restricted() {
        require(msg.sender == manager, "Restricted to manager only");
        _;
    }
}

//12 Write a Solidity function to implement a rentable storage system, where users can rent storage space in exchange for tokens.

contract StorageRent {
    address payable public owner;
    uint public pricePerByte;
    uint public totalSize;
    uint public availableSize;
    mapping(address => uint) public balances;
    mapping(address => mapping(bytes32 => uint)) public files;

    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);
    event FileStored(address indexed user, byte32 indexed files, uint size);
    event FilrRemoved(address indexed user, bytes32 indexed files);

    constructor (uint _pricePerByte, uint _totalSize) {
        owner = payable(msg.sender);
        pricePerByte = _pricePerByte;
        totalSize = _totalSize;
        availableSize = _totalSize;
    }

    function deposite () public payable {
        require(msg.value > 0, "Deposite amount must be greater");
        balances[msg.sender] += msg.value;
        emit Deposite(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(amount <= balances[msg.sender]);
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function store(bytes32 fileId, uint size) public {
        require(size > 0, "File size must be greater than zero");
        require(size <= availableSize, "Insufficient storage space");
        require(balances[msg.sender] >= paicePerByte * size, "Insufficient balance");
        balances[msg.sender] -= pricePerByte * size;
        files[msg.sender][filezId] = size;
        availableSize -= size;
        emit FileStored(msg.sender, fileId, size);
    }

    function remove(bytes32 fileId) public {
        uint size = files[msg.sender][fileId];
        require(size > 0, "File not found");
        balances[msg.sender] += priceByte * size;
        files[msg.sender][fileId] = 0;
        availableSize += size;
        emit FileRemoved(msg.sender, fileId);
    }

    function getPrice(uint size) public view returns (uint) {
        return pricePerByte * size;
    }

    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function getFileSize(bytes32 fileId) public view returns (uint) {
        return files[msg.sender][fileId];
    }
}

/*
The StorageRent contract is initialized with a price per byte and a total storage size.
Users can deposit Ether by calling the deposit() function, which updates their balance.
Users can store a file by calling the store() function with a unique file ID and the file size in bytes. The function checks that the user has enough balance to pay for the storage space, updates their balance, and updates the available storage space.
Users can remove a file by calling the remove() function with the file ID. The function returns the balance to the user, updates the available storage space, and removes the file from the user's files mapping.
The getPrice() function returns the cost of storing a file of a given size in bytes.
The getBalance() function returns the balance of the calling user.
The getFileSize() function returns the size of a file with a given file ID for the calling user.
*/

/* 13 Write a Solidity function to implement a trustless escrow system, where funds are held in escrow until certain conditions are met.

 Escrow is a financial process used when two parties take part in a transaction and there is uncertainty about the fulfillment of their obligations. 
 Situations that may use escrow can involve internet transactions, banking, intellectual property, real estate, mergers and acquisitions, law, and more.

KEY TAKEAWAYS
Escrow refers to a neutral third party holding assets or funds before they are transferred from one party in a transaction to another.
The third party holds the funds until both buyer and seller have fulfilled their contractual requirements.
Escrow is associated with real estate transactions but it can apply to any situation where funds will pass from one party to another.
Escrow can be used when purchasing a home and for the life of a mortgage.
Online escrow has been on the rise as a way to offer secure online transactions for expensive items, such as art or jewelry.
*/

contract Escrow {
    address payable public seller;
    address payable public buyer;
    address public arbiter;
    uint256 public amount;
    bool public releaseApproved;
    bool public refundApproved;

    constructor(address payable _seller, address payable _buyer, address _arbiter) {
        seller = _seller;
        buyer = _buyer;
        arbiter = _arbiter;
    }

    function deposit() public payable {
        require(msg.sender == buyer, "Only the buyer can deposit funds.");
        require(msg.value > 0, "Funds must be greater than 0.");
        amount += msg.value;
    }

    function approveRelease() public {
        require(msg.sender == buyer || msg.sender == seller, "Only the buyer or seller can approve the release of funds.");
        require(!refundApproved, "Refund has already been approved.");
        releaseApproved = true;
    }

    function approveRefund() public {
        require(msg.sender == buyer || msg.sender == seller, "Only the buyer or seller can approve the refund of funds.");
        require(!releaseApproved, "Release has already been approved.");
        refundApproved = true;
    }

    function release() public {
        require(releaseApproved, "Release has not been approved.");
        require(address(this).balance > 0, "No funds to release.");
        seller.transfer(amount);
        amount = 0;
    }

    function refund() public {
        require(refundApproved, "Refund has not been approved.");
        require(address(this).balance > 0, "No funds to refund.");
        buyer.transfer(amount);
        amount = 0;
    }

    function escrowDetails() public view returns (address, address, address, uint256, bool, bool) {
        return (seller, buyer, arbiter, amount, releaseApproved, refundApproved);
    }
}


/* In this example, the Escrow contract has three parties: the seller, the buyer, and an arbiter. The buyer deposits funds into the contract, and 
the funds are held in escrow until certain conditions are met. The releaseApproved and refundApproved variables keep track of whether the buyer 
and seller have approved the release of funds or the refund of funds, respectively.

To use the escrow system, the buyer first calls the deposit function to deposit funds into the contract. Then, either the buyer or seller can call 
the approveRelease function to approve the release of funds to the seller, or the approveRefund function to approve the refund of funds to the 
buyer. Once one of these functions has been called, the other cannot be called.

If the release of funds is approved, the seller can call the release function to transfer the funds to their account. If the refund of funds is 
approved, the buyer can call the refund function to transfer the funds to their account.

The escrowDetails function can be called by any party to view the current state of the escrow, including the addresses of the seller, buyer, and 
arbiter, the amount of funds held in escrow, and whether the release or refund of funds has been approved.
*/


// 14. Write a Solidity function to implement a decentralized identity system, where users can prove their identity without relying on a centralized authority.
Contract Identity {
    struct userInfo {
        bool exists;
        uint idNumber;
        string name;
        string email;
        string phoneNumber;
    }

    mapping (address = userInfo) public users;
    mapping (uint => address) public userAddresses;
    uint public userCount;

    function registerUser (uint _idNumber, string memory _name, string memory _email, string memory _phoneNumber) {
        require(users[msg.sender].exists, "User alresdy registerd");
        users[msg.sender] = userInfo(true, _idNumber, _name, _email, _phoneNumber);
        userAddresses[userCount] = msg.sender;
        userCount++;
    }

    function proveIdentity (uint _idNumber) public view returns (string memory) {
        address userAddress = usersAddresses[_idNumber];
        require(users[userAddress].exist, "User does not exist");
        require(users[userAddress == _idNumber, "Id No does not match"]);
        return users[userAddress].name;
    }
}

/*Explanation of the code:

The UserInfo struct is defined to store the user's information, such as ID number, name, email, and phone number.

Two mapping variables, users and userAddresses, are defined to map the user's Ethereum address to their UserInfo and to map their ID number to 
their Ethereum address.

The registerUser function allows users to register by passing in their ID number, name, email, and phone number. It checks that the user has not 
already been registered by checking the exists field in their UserInfo. If they have not been registered, their information is stored in the 
users mapping and their Ethereum address is stored in the userAddresses mapping.

The proveIdentity function allows users to prove their identity by passing in their ID number. It checks that the user with that ID number exists 
in the userAddresses mapping and that their ID number matches the one passed in. If both conditions are true, the function returns the user's name.

This example is just a basic implementation and can be improved by adding additional features such as verification of the user's identity through a 
trusted third party or through other forms of verification.
*/

// 2.

contract IdentitySystem {
    
    mapping(address => uint256) public identityRegistry;
    
    function proveIdentity(uint256 _identity) public {
        identityRegistry[msg.sender] = _identity;
    }
    
    function verifyIdentity(address _user, uint256 _identity) public view returns(bool) {
        return identityRegistry[_user] == _identity;
    }
    
}

// 15. Write a Solidity function to implement a supply chain management system, where products can be tracked from creation to delivery.

contract supplyChain {
    enum ProductStatus {Created, Shipped, Delivered}

    struct Product {
        string name;
        uint256 price;
        uint256 quantity;
        address seller;
        address buyer;
        ProductStatus status;
    }

    uint256 public productCount = 0;
    mapping(uint256 => Product) public products;

    event ProductCreated(uint256 productId);
    event ProductShipped(uint256 productId);
    event ProductDelivered(uint256 productId);

    function createProduct(string memory _name, uint256 _price, uint256 _quantity) public {
        require(_price > 0, "Price must be greater than zero");
        require(_quantity > 0, "Quantity must be greater than zero");

        uint256 productId = ++productCount;
        products[productId] = Product({
            name: _name,
            price: _price,
            quantity: _quantity,
            seller: msg.sender,
            buyer: address(0),
            status: ProductStatus.Created
        });
        emit ProductCreated(productId);
    }

    function shipProduct(uint256 _productId) public {
        Product storage product = products[_productId];
        require(product.status == ProductStatus.Created, "Product must be in Created status");
        require(msg.sender == product.seller, "Only seller can ship the product");

        product.status = ProductStatus.Shipped;
        emit ProductShipped(_productId);
    }

    function deliverProduct(uint256 _productId) public {
        Product storage product = products[_productId];
        require(product.status == ProductStatus.shipped, "Product must be in Shipped status");

        product.status = ProductStatus.Delivered;
        emit ProductDelivered(_productId);
    }

    function buyProduct(uint256 _productId, uint256 _quantity) public payable {
        Product storage product = products[_productId];
        require(product.status == ProductStatus.Created, "Product must be in Created status");
        require(msg.value == product.price * _quantity, "Insufficient fund");
        require(_quantity <= product.quantity, "Insufficient quantity");

        product.quantity -= _quantity;
        product.buyer = msg.sender;
        product.status = ProductStatus.Shipped;
        emit ProductShipped(_productId);
    }
}

/* In this implementation, the SupplyChain contract has a Product struct that stores information about each product, including the name, price, 
quantity, seller, buyer, and status. Products can be created by calling the createProduct function and passing in the name, price, and quantity 
as arguments.

The seller can then ship the product by calling the shipProduct function and passing in the product ID. The buyer can confirm delivery by 
calling the deliverProduct function and passing in the product ID.

Alternatively, a buyer can purchase a product by calling the buyProduct function and passing in the product ID and quantity as arguments, along 
with the Ether required to pay for the product. If the purchase is successful, the quantity of the product is reduced and the buyer is recorded 
in the buyer field of the Product struct.

The contract emits events when a product is created, shipped, and delivered, which can be used to track the product's status. The contract 
also has a productCount variable and a products mapping, which allow products to be indexed and looked up by their ID.
*/


//16. Write a Solidity function to implement a decentralized autonomous organization (DAO), where users can vote on governance decisions.

contract MyDAO {

    struct Proposal {
        uint id;
        string description;
        uint256 voteCount;
        mapping(address => bool) voted;
    }

    mapping(uint => Proposal) public proposals;
    uint public proposalCount;
    address public owner;

    mapping(address => bool) public members;
    uint public memberCount;

    constructor() {
        owner = msg.sender;
        members[owner] = true;
        memberCount = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this activity");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Only member can perform this action");
        _;
    }

    function addMember(address _member) public onlyOwner {
        require(!members[_member], "This address id alresdy a member");
        members[_member] = true;
        memberCount++;
    }

    function removeMember(address _member) public onlyOwner {
        require(members[_member], "This address is not member");
        require(_member != owner, "Owner can not be removed as a member");
        members[_member] = false;
        memberCount--;
    }

    function createProposal(string memory _description) public onlyMember {
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, _description, 0);
    }

    function vote(uint _proposalId) public onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.voted[msg.sender], "This address has already voted for this proposal");
        proposal.voted[msg.sender] = true;
        proposal.votecount++;
    }

    function executeProposal(uint _proposalId) public onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.voteCount > memberCount / 2, "This proposal does not have enough votes to pass");
    }
}

/* The MyDAO contract has a Proposal struct that contains the proposal's ID, description, vote count, and a mapping of addresses to whether they 
have voted on the proposal.

The contract also has a proposals mapping that maps proposal IDs to their respective Proposal struct, a proposalCount variable to keep track of the 
number of proposals, an owner variable to store the address of the contract owner, and a members mapping to store the addresses of the DAO's members.

The contract has several modifiers to restrict access to certain functions. The onlyOwner modifier restricts access to the contract owner, while the 
onlyMember modifier restricts access to members of the DAO.

The addMember function allows the contract owner to add a new member to the DAO, while the removeMember function allows the owner to remove a member.

The createProposal function allows a member to create a new proposal, which is stored in the proposals mapping.

The vote function allows a member to vote on a proposal. The function checks whether the member has already voted and increments the vote count for 
the proposal.

The executeProposal function allows the contract owner to execute a proposal that has received enough votes to pass. The function checks whether the 
proposal has received more than half of the total number of votes and then executes the proposal's code. Note that the actual code for the proposal 
would need to be added to the function.
*/

// 17. Write a Solidity function to implement a smart contract insurance policy, where users can be compensated for losses that meet certain conditions.

//An insurance policy is a contract between an insurance company and an individual or entity (the policyholder) that provides financial 
//protection against specified risks or losses in exchange for the payment of a premium.

contract InsurencePolicy {

    address payable policyholder;
    uint256 premium;
    uint256 payoutAmount;
    bool policyActive;

    constructor(uint256 _premium, uint256 _payoutAmount) payable {
        policyholder = payable(msg.sender);
        premium = _premium;
        payoutAmount = _payoutAmount;
        policyActive = true;
        require(msg.value == premium, "Premium payment required");
    }

    //Policyholder make claim if certain conditions are met
    function makeClaim(bool conditionMet) public {
        require(policyActive, "Policy is no longer active");
        require(conditionMet, "Condition for claim not met");
        policyholder.transfer(payoutAmount);
        policyActive=false;
    }

    //Allow policyholder to cancel the policy and receive refund
    function cancelPolicy() public {
        require(policyActive, "Policy is no longer active");
        policyholder.transfer(premium);
        policyActive = false;
    }
}
/* This contract has a few key features:
The constructor function sets the initial parameters of the policy, including the premium and payout amount. The policyholder must pay the premium 
as part of deploying the contract.

The makeClaim function allows the policyholder to make a claim if certain conditions are met. If the conditions are met, the contract transfers 
the payout amount to the policyholder and deactivates the policy. If the conditions are not met, the function reverts.

The cancelPolicy function allows the policyholder to cancel the policy and receive a refund of the premium. The function deactivates the policy 
and transfers the premium back to the policyholder.
*/

// 2
contract InsurancePolicy {
    
    // Structure to store policy details
    struct Policy {
        address policyHolder;
        uint256 policyAmount;
        uint256 policyExpiration;
        bool isPolicyActive;
    }
    
    // Mapping to store policies
    mapping (address => Policy) public policies;
    
    // Function to buy policy
    function buyPolicy(uint256 expiration) public payable {
        require(msg.value > 0, "Policy amount should be greater than zero");
        require(expiration > block.timestamp, "Policy expiration date should be in future");
        require(!policies[msg.sender].isPolicyActive, "Policy already exists for this user");
        Policy memory policy = Policy({
            policyHolder: msg.sender,
            policyAmount: msg.value,
            policyExpiration: expiration,
            isPolicyActive: true
        });
        policies[msg.sender] = policy;
    }
    
    // Function to claim insurance
    function claimInsurance(uint256 lossAmount) public {
        require(policies[msg.sender].isPolicyActive, "No policy found for the user");
        require(policies[msg.sender].policyExpiration > block.timestamp, "Policy expired");
        require(lossAmount > 0 && lossAmount <= policies[msg.sender].policyAmount, "Loss amount should be between 0 and policy amount");
        payable(msg.sender).transfer(lossAmount);
        policies[msg.sender].isPolicyActive = false;
    }  
}

/*In this contract, the Policy struct is used to store policy details, such as the policy holder's address, policy amount, policy expiration 
date, and whether the policy is active. The policies mapping is used to store policies for each user.

The buyPolicy function is used to buy a policy. It takes the policy expiration date as a parameter and requires that the policy amount be 
greater than zero, the policy expiration date be in the future, and no policy already exists for the user. The function creates a new policy 
and stores it in the policies mapping.

The claimInsurance function is used to claim insurance. It requires that a policy exists for the user, the policy is active, the policy 
expiration date is in the future, and the loss amount is between 0 and the policy amount. If these conditions are met, the function 
transfers the loss amount to the user's address and sets the policy to inactive.
*/

// 18. Write a Solidity function to implement a token swap, where one ERC-20 token can be exchanged for another.

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSwap {
    IERC20 public tokenA;
    IERC20 public tokenB;
    address public owner;
    uint256 public exchangeRate;

    constructor(address _tokenA, address tokenB, uint256 _exchangeRate) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
        exchangeRate = _exchangeRate;
    }

    function swapTokens(uint256 _amount) public {
        require(tokenA.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        uint256 amountToReceive = _amount * exchangeRate;
        require(tokenB.balanceOf(address(this)) >= amountToReceive, "Swap contract does not have enough tokens");

        tokenA.transferFrom(msg.sender, address(this), _amount);
        tokenB.transfer(msg.sender, amountToReceive);
    }

    function updateExchangeRate(uint256 _newExchangeRate) public {
        require(msg.sender == owner, "only owner can update exchange rate");
        exchangeRate = _newExchangeRate;
    }
}

/* In this example, the smart contract represents a token swap where users can exchange one ERC-20 token (represented by tokenA) for another 
ERC-20 token (represented by tokenB) at a specified exchange rate. The swapTokens() function allows users to initiate a swap by sending 
tokenA to the contract and receiving tokenB in return. The updateExchangeRate() function allows the owner of the contract to update the exchange rate.

Note that this is just an example and would need to be customized to meet the specific requirements of the token swap being implemented. 
Also, this example assumes that both tokenA and tokenB follow the ERC-20 standard, so they have transferFrom() and transfer() functions 
that can be used to transfer tokens.*/


//19. Write a Solidity function to implement a token vesting contract, where tokens are gradually released over a period of time.

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenVesting {
    address private token; // the address of the ERC-20 token being vested the address of the ERC-20 token being vested
    address private beneficiary; //the address of the beneficiary who will receive the vested tokens
    uint256 private start; //the timestamp at which vesting begins
    uint256 private cliff; //the timestamp at which the initial portion of the tokens become vested
    uint256 private duration; //the duration of the vesting schedule
    uint256 private released;

    constructor(address _token, address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration) {
        token = _token;
        beneficiary = _beneficiary;
        start = _start;
        cliff = _cliff;
        duration = _duration;
    }

    function release() public {
        require(block.timestamp >= cliff, "Tokens are not yet vested");
        
        uint256 amountVested = vestedAmount();
        uint256 amountToRelease = amountVested - released;

        require(amountToRelease > 0, "No tokens available for release");
        require(IERC20(token).balanceOf(address(this)) >= amountToRelease, "Insufficient balance");

        IERC20(token).transfer(beneficiary, amountToRelease);
        released += amountToRelease;
    }

    function vestedAmount() public view returns (uint256) {
        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        uint256 totalBalance = currentBalance + released;

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start + duration) {
            return totalBalance;
        } else {
            return totalBalance * (block.timestamp - start) / duration;
        }
    }
}

/* The vestedAmount() function calculates the amount of tokens that have vested at the current time, based on the start time, cliff time, and 
duration. The function returns the total number of tokens vested, taking into account tokens already released.

The release() function transfers the vested tokens to the beneficiary. The function checks that the cliff time has passed and that there are 
tokens available for release. If the conditions are met, the function transfers the appropriate amount of tokens to the beneficiary and 
updates the amount of tokens released. */


//20. Write a Solidity function to implement a cross-chain bridge, where tokens can be transferred between different blockchains.
/* Implementing a cross-chain bridge in Solidity requires a bit of knowledge about both the source and destination blockchain, as well 
as any intermediary networks that may be involved. Here is a basic example of a cross-chain bridge function that transfers tokens 
from Ethereum to Binance Smart Chain: */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainBridge {
    address public token;
    address public destinationBridge;

    constructor(address _token, address _destinationBridge) {
        token = _token;
        destinationBridge = _destinationBridge;
    }

    function transferToBSC(uint256 amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(destinationBridge, amount);
        IBridge(destinationBridge).depositTokens(amount);
    }
}

interface IBridge {
    function depositTokens(uint256 amount) external;
}

/*In this example, we assume that the cross-chain bridge is being used to transfer tokens from the Ethereum blockchain to the Binance Smart Chain.

The constructor function sets the addresses of the token contract and the destination bridge on the Binance Smart Chain.

The transferToBSC function takes an amount parameter, which specifies the amount of tokens to be transferred. First, the function calls the 
transferFrom function of the ERC20 token contract to transfer the specified amount of tokens from the sender's address to the address of 
the cross-chain bridge contract.

Then, the function approves the destination bridge contract to spend the transferred tokens using the approve function of the ERC20 token contract. 
Finally, the function calls the depositTokens function of the IBridge interface, which is implemented by the destination bridge contract on the 
Binance Smart Chain.

The destination bridge contract on the Binance Smart Chain should implement a corresponding depositTokens function that will receive the 
transferred tokens and credit them to the sender's account on the Binance Smart Chain.

Note that this is a simplified example, and more complex cross-chain bridges may require additional functions and logic to handle different token 
standards, fee structures, and other variables. Additionally, it is important to thoroughly test any cross-chain bridge implementation before 
deploying it in a production environment.
*/

//21. Write a Solidity function to implement a decentralized file storage system, where users can store and retrieve files without relying on a 
centralized server.
//Here is an example Solidity contract that implements a decentralized file storage system using IPFS (InterPlanetary File System) for file storage and retrieval.

contract DecentralizedFileStorage {
    //IPFS node information
    string private ipfsHost = "ipfs.infura.io";
    uint private ipfsPort = 5001;
    string private ipfsProtocol = "https";

    //Event for when a file is added to the system
    event FileAdded(string ipfsHash, string fileNmae, uint fileSize);

    //Structure for storing file metadata
    struct File {
        string fileName;
        uint fileSize;
        string ipfsSize;
    }

    // Mapping of file ID to file metadata
    mapping(uint => File) private files;

    //Counter for generating file IDs
    uint private fileCounter = 0;

    //Function to addd a file to the system
    function addFile(string memory fileName, uint fileSize, string memory ipfsHash) public {
        fileIdCounter++;
        files[fileIdCounter] = File(fileName, fileSize, ipfsHash);
        emit FileAdded(ipfsHash, fileName, fileSize);
    }

    //Function to retrieve file metadata by ID
    function getFile(uint fileId) public view returns (string memory, uint, string memory) {
        File memory file = files[fileId];
        return (file.fileName, file.fileSize, file.ipfshash);
    }

    // Function to retrieve a file from IPFS by hash
    function getFileFromIpfs(string memory ipfsHash) public view returns (bytes memory) {
        IpfsHttpClient ipfs = IpfsHttpClient(ipfsHost, ipfsPort, ipfsProtocol);
        return ipfs.cat(ipfsHash);
    }

}

/* The contract declares a few variables that hold the IPFS node information, as well as an event to emit when a file is added to the system.

The File struct holds the metadata for a file, including the filename, file size, and IPFS hash.

The files mapping maps a file ID to its metadata.

The fileIdCounter variable keeps track of the next file ID to assign.

The addFile function takes in the filename, file size, and IPFS hash of a file, assigns a new ID to the file, and adds its metadata to the files
 mapping. It also emits the FileAdded event with the file's IPFS hash, filename, and size.

The getFile function takes in a file ID and returns the file's metadata from the files mapping.

The getFileFromIpfs function takes in an IPFS hash and uses the IpfsHttpClient library to retrieve the file data from IPFS and return it as bytes.

Note that this contract only handles file metadata storage and retrieval, and assumes that the actual file data is already stored on IPFS. You 
would need to add additional functionality to handle uploading and pinning files to IPFS, as well as managing access control to the files. */

// 22. Write a Solidity function to implement a non-fungible token (NFT) contract, where each token is unique and can represent a digital asset such as artwork or collectibles.

contract MyNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MyNFT", "NFT) {}

    struct NFT {
        string name; 
        string description;
        string imageUri;
    }

    mapping (uint256 => NFT) private _nfts;

    function mintNFT(address recipient, string memory name, string memory description, string memory imageUri) {
        _tokenIds.increment();

        uint256 newNftId = _tokenIds.current();
        _mint(recipient, newNftId);

        NFT memory newNft = NFT(name, description, imageUri);
        _nfts[newNftId] = newNft;

        return newNftId
    }

    function getNFT(uint256 nftId) public view returns (string memory name, string memory description, string memory imageUri) {
        require(_exist(nftId), "NFT does not exist");
        NFT storage nft = _nfts[nftId];
        return(nft.name, nft.description, nft.imageUri);
    }
}
/* In this example, we use the OpenZeppelin implementation of the ERC721 standard, which provides functionality for creating and managing NFTs.

The MyNFT contract inherits from the ERC721 contract and initializes the token name and symbol in the constructor.

We define a struct NFT to represent the metadata associated with each NFT. The mintNFT function takes in the metadata as parameters, creates 
a new NFT with a unique ID using the _tokenIds counter, and assigns the metadata to the _nfts mapping.

The getNFT function takes in an NFT ID and returns the metadata associated with that NFT.

Note that this is just an example and there are many different ways to implement an NFT contract depending on your requirements.*/

//23. Real Estate Example

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract RealEstate {

    struct Property {
        uint256 price;
        address owner;
        bool foreSale;
        string name;
        string description;
        string location;
    }

    mapping(uint256 => Property) public properties;
    uint256 [] public propertyIds;

    event propertySold(uint256 propertyId);

    function listPropertyForSale(uint256 _propertyId, uint256 _price, string memory _name, string memory _description, string memory _location) public {
        Property memory newProperty = Property({
            price:_price,
            owner:msg.sender,
            foreSale:true,
            name:_name,
            description:_description,
            location:_location
        });
        properties[_propertyId] = newProperty;
        propertyIds.push(_propertyId);
    }

    function buyProperty(uint256 _propertyId) public payable {
        Property storage property = properties[_propertyId];
        require(property.foreSale, "property is not for sale");
        require(property.price <= msg.value, "Insufficient funds");
        property.owner = msg.sender;
        property.foreSale = false;
        payable(property.owner).transfer(property.price);
        emit propertySold(_propertyId);
    }
}

//24 . Write a Solidity function to implement a decentralized identity verification system, where users can prove their identity using a network of trusted validators.

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract IdentityVerification {
    struct Validator {
        bool isValidator;
        bool isValid;
    }

    mapping(address => Validator) public validators;
    mapping(address => bool) public verifiedUsers;

    function addValidator(address _validator) public {
        require(!validators[_validator].isValid, "Validator already exists");
        validators[_validator].isValidator = true;
    }

    function removeValidator(address _validator) public {
        require(validators[_validator].isValid,"Validator does not exist"); //to remove validator first he present
        validators[_validator].isValidator = false;
    }

    function validateUser(address _user) public {
        require(validators[msg.sender].isValidator, "Only validator can validate the user");
        verifiedUsers[_user] = true;
        validators[msg.sender].isValidator = true;
    }

    function revokeValidation(address _user) public {
        require(validators[msg.sender].isValidator, "Only validator can remove the user");
        verifiedUsers[_user] = false;
        validators[msg.sender].isValid = false;
    }

    function isVerified(address _user) public view returns(bool){
        require(verifiedUsers[_user], "User is nor verified");
        return verifiedUsers[_user];
    }
}

/*This contract allows validators to register themselves by calling the addValidator function, and remove themselves by calling removeValidator. Validators can then use the validateUser function to validate a user's identity, and the revokeValidation function to revoke validation if necessary.

The isVerified function can be used by anyone to check if a user's identity has been verified by at least one validator.

Note that this implementation assumes that validators are trusted and are correctly validating users' identities. In a real-world implementation, additional measures should be taken to ensure the security and integrity of the validation process.*/

//25 . Write a Solidity function to implement a decentralized marketplace, where users can buy and sell goods and services without relying on a centralized platform.

contract MarketPlace {
    struct Item {
        address seller;
        uint256 price;
        bool available;
    }

    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    event ItemAdded(uint256 itemId, address seller, uint256 price);
    event ItemSold(uint256 itemId, address buyer, address seller, uint256 price);

    function addItem(uint256 price) public {
        require(price > 0, "Price must be greater than zero");
        items[itemCount] = Item(msg.sender, price, true);
        emit ItemAdded(itemCount, msg.sender, price);

        itemCount++;
    }

    function buyItem(uint256 itemId) public payable {
    Item storage item = items[itemId];
    require(item.available, "Item is not available");
    require(msg.value >= item.price, "Insufficeint balance");

    address payable seller = payable(item.seller);
    seller.transfer(msg.value);
    item.available = false;

    emit ItemSold(itemId, msg.sender, seller, item.price);
    }
}

/* In this implementation, sellers can add items to the marketplace by calling the addItem function with the price of the item as an argument. Each item is assigned a unique itemId, and the seller's address, price, and availability are stored in the items mapping. The ItemAdded event is emitted to notify users that a new item has been added.

Buyers can purchase an item by calling the buyItem function with the itemId of the item they wish to purchase. They must provide enough ether to cover the price of the item. Once the payment is confirmed, the seller's address receives the ether and the item becomes unavailable. The ItemSold event is emitted to notify users that an item has been sold.

Note that this is just a basic implementation and can be modified and improved based on specific requirements and use cases. */

// 26. Write a Solidity function to implement a stablecoin contract, where the value of the token is pegged to a stable asset such as the US dollar.

pragma solidity ^0.8.0;

contract StableCoin {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    uint256 public price;
    address public reserve;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Buy(address indexed buyer, uint256 amount);
    event Sell(address indexed seller, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        uint256 _price,
        address _reserve
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        price = _price;
        reserve = _reserve;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function buy(uint256 _amount) public payable {
        uint256 cost = _amount * price;
        require(msg.value == cost, "Incorrect amount sent");
        require(address(this).balance >= cost, "Insufficient reserve");
        balanceOf[msg.sender] += _amount;
        balanceOf[reserve] -= _amount;
        emit Buy(msg.sender, _amount);
    }

    function sell(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        uint256 value = _amount * price;
        balanceOf[msg.sender] -= _amount;
        balanceOf[reserve] += _amount;
        payable(msg.sender).transfer(value);
        emit Sell(msg.sender, _amount);
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == owner, "Not authorized");
        price = _price;
    }
}

/* The StableCoin contract takes several parameters in the constructor:

_name: The name of the stablecoin.
_symbol: The symbol used to represent the stablecoin.
_decimals: The number of decimal places used to represent the stablecoin.
_initialSupply: The initial supply of the stablecoin.
_price: The price of the stablecoin in US dollars.
_reserve: The address of the reserve where US dollars */

// 27 Write a Solidity function to implement a prediction market for sports events, where users can bet on the outcome of games and matches.

contract PredictionMarket {
    struct Bet {
        address payable user; 
        uint256 amount;
        uint256 team;
        bool paidOut;
    }

    enum MatchOutcome {
        NotStarted,
        Team1Won,
        Team2Won,
        Draw
    }

    address public owner;
    MatchOutcome public outcome;
    uint256 public betCount;
    mapping(uint256 => Bet) public bets;
    mapping(address => uint256) public pendingWithdrawals;

    event BetPlaced(address indexed user, uint256 amount, uint256 team);
    event OutcomeSet(MatchOutcome outcome);
    event BetPaidOut(uint256 indexed betId, address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
        outcome = MatchOutcome.NotStarted;
    }

    function placeBet(uint256 _team) public payable {
        require(outcome == MatchOutcome.NotStarted, "Match alresdy started");
        require(_team == 1 || _team == 2, "Invalid team");
        reauire(msg.value > 0, "Bet amount must be greater than 0");

        Bet storage bet = bets[betCount];
        bet.user = payable(msg.sender);
        bet.amount = msg.value;
        bet.team = _team;
        betCount++;

        emit BetPlaced(msg.sender, msg.value, _team);
    }

    function setOutcome(MatchOutcome _ouncome) public {
        require(msg.sender == owner, "Not authorized");
        require(outcome == MatchOutcome.NotStarted, "Outcome already set");
        outcome = _outcome;

        emit OutcomeSet(_outcome);
    }

    function payout(uint256 _betId) public {
        require(outcome != MatchOutcome.Notstarted, "Outcome not set yet");
        Bet storage bet = bets[_betId];
        require(!bet.paidOut, "Bet already paid out");
        require(bet.team == uint256(outcome), "Incorrect outcome");

        uint256 payoutAmount = bet.amount * 2;
        payable(bet.user).transfer(payoutAmount);
        pendingWithdrawals[bet.user] += payoutAmount;
        bet.paidOut = true;

        emit BetPaidOut(_betId, bet.user, payoutAmount);
    }

    function withdraw() public {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        pendindWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

/* The PredictionMarket contract stores information about the current state of the prediction market, including the current outcome of the match, the number of bets placed, and the details of each individual bet. Users can place bets on the outcome of the match by calling the placeBet function, which stores their bet details in the bets mapping.

Once the match has ended, the owner of the contract can set the outcome of the match using the setOutcome function. This updates the outcome variable, which determines the winning team. Users who placed bets on the winning team can then call the payout function to collect their winnings.

The withdraw function allows users to withdraw their winnings from the contract. When a user wins a bet and calls the payout function, their winnings are added to their pendingWithdrawals balance. This balance can be withdrawn by calling the withdraw function. */

// 28. Write a Solidity function to implement a smart contract lottery, where the winner is chosen randomly and transparently using a verifiable random function (VRF).

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase {
    address public manager;
    uint256 public ticketPrice;
    uint256 public ticketCount;
    uint256 public randomResult;
    bytes32 public requestId;
    adddress[] public participants;
    mapping(address => uint256) public balances;

    bytes32 internal keyHash;
    uint256 internal fee;

    constructor (address _vrfCoordinator, address _link, bytes32 _keyHash, uint256 _fee, uint256 _ticketPrice)
    VRFConsumerBase(_vreCoordinator, _link){
        manager=msg.sender;
        ticketPrice = _ticketPrice;
        keyHash = _keyHash;
        fee = _fee;
    }

    function enter() public payable {
        require(msg.value >= ticketPrice, "Not enough ether sent.");
        participants.push(msg.sender);
        balances[msg.sender] += msg.value;
        ticketCount++;
    }

    function pickWinner() public onlyManager returns (address) {
        require(ticketCount > 0, "No participants in the lottery");
        require(LINK.balancesOf(address(this)) >= fee, "Not enough LINK to fullfill vrf request");
        requestId = requestRandomness(keyHash, fee);
        return participants[randomResult % ticketCount]; 
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
        require(_requestId == requestId, "Unexpected requestId");
        randomResult = _randomness;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "No funds to withdraw");
        payable(msg.sender).transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can perform this action");
        _;
    }
}

/* Here's a brief explanation of the key parts of this contract:

The Lottery contract inherits from VRFConsumerBase, which is part of the Chainlink VRF library. This library is used to generate a verifiable random number.
The enter function allows participants to enter the lottery by sending enough ether to cover the ticket price.
The pickWinner function can only be called by the manager and triggers a request for a random number from the VRF. The winner is chosen by taking the remainder of the random number divided by the number of participants.
The fulfillRandomness function is called by the Chainlink VRF oracle when the random number is generated. It sets the randomResult variable to the generated random number.
The withdraw function allows participants to withdraw their winnings after the lottery has ended.
The onlyManager modifier ensures that certain functions can only be called by the manager.
Note that this is just an example implementation and should not be used in production without proper testing and auditing. Additionally, this implementation does not handle edge cases, such as what happens if there are no participants or if there is a tie for the winning ticket. */


//29. Write a Solidity function to implement a yield farming contract, where users can earn rewards by staking tokens in a liquidity pool.
/*Yield farming is a mechanism by which cryptocurrency investors can earn rewards by providing liquidity to decentralized finance (DeFi) 
protocols. In yield farming, investors deposit cryptocurrencies into a liquidity pool on a DeFi platform and receive rewards in the 
form of interest or newly minted tokens.

Yield farming has become a popular way to earn passive income in the cryptocurrency market, as it allows investors to earn rewards 
without actively trading or speculating on the price of a particular cryptocurrency. However, yield farming also carries risks, including 
the potential for smart contract bugs, liquidity risks, and impermanent loss, which occurs when the value of the deposited tokens fluctuates 
relative to each other. It is important for investors to understand these risks before participating in yield farming.
*/


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract YeildFarming {
    using SafeMath for IERC20;
    
    address public lptoken; //address of liquidity pool
    address public rewardToken; //address of reward token
    address public totalRewards; //total amount of reward token that will be distributed
    uint256 public startTime; //the timestamp when the farming starts
    uint256 public endTime; //timestamp when farming ends
    uint256 public rewardRate; //amount of reward token per second

    mapping(address => uint256) public stakeBalances; //amount of LP tokens staked by each user
    mapping(address => uint256) public lastClainmTimes;  //timestamp of the last time user claimed their rewards

    constructor(address _lpToken, address _rewardToken, uint256 _totalRewards, uint256 _startTime, uint256 _endTime) {
        lpToken = _lpToken;
        rewardToken = _rewardToken;
        totalReward = _totalReward;
        startTime = _startTime;
        endTime = _endTime;

        //Calculate reward rate
        uint256 duration = endTime - startTime;
        rewardRate = totalReward / duration;
    }

    function stake(uint256 amount) external {
        require(block.timestamp >= startTime && block.timestamp < endTime, "Farming has not started or ended");
        require(amount > 0, "cannot stake 0 tokens");

        //Transfer LP tokens from the user to contract
        IERC20(lpToken).safeTransferFrom(msg.sender, address(this), amount);

        //Update the staked balance of the user
        stakedBalances[msg.sender] += amount;
    }

    function unstake(uiunt256 amount) external {
        require(amount > 0, "Cannot unstake 0 tokens");
        stakedBalances[msg.sender] -= amount; //update staked balance of user
        IERC20(lpToken).safeTransfer(msg.sender, amount);
    }

    function claimRewards() external {
        uint256 rewards = getPendingRewards(msg.sender);
        require(rewards > 0, "No reward to claim");
        lastClaimTime[msg.sender] = block.timestamp; //update the last claim time of the user
        IERC20(rewardToken).safeTransfer(msg.sender, rewards);
    }

    function getPendingRewards(address user) public view returns (uint256) {
        uint256 stakedBalance = stakeBalances[user];

        if(stakedBalance == 0) {
            return 0;
        }

        uint256 lastClaimTime = lastClaimTimes[user];

        if(lastClaimTime >= endTime) {
            return 0;
        }

        uint256 currentTimestamp = block.timestamp;

        if(currentTimestamp > endTime) {
            currentTimestamp = endTime;
        }

        uint256 timeElapsed = currentTimestamp - lasrClaimTime;
        return stakeBalance * timeElapsed * rewardRate;
    }

}

//30. Write a Solidity function to implement a decentralized identity system for healthcare, where users can share their medical records with trusted parties.

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract HealthcareIdentity {

    struct MedicalRecord {
        string diagnosis;
        string treatment;
        uint256 timestamp;
        address doctor;
    }

    struct Identity {
        address owner;
        mapping(address => bool) trustedParties;
        mapping(bytes32 => MedicalRecord) medicalRecords;
    }

    mapping(address => Identity) private identities;

    event MedicalRecordAdded(address indexed owner, address indexed doctor, bytes32 recordHash);

    function addMedicalRecord(bytes32 recordHash, string memory diagnosis, string memory treatment) public {
        Identity storage identity = identities[msg.sender];

        require(identity.owner == msg.sender, "You do not have an identity");

        MedicalRecord memory newRecord = MedicalRecord({
            diagnosis: diagnosis,
            treatment: treatment,
            timestamp: block.timestamp,
            doctor: msg.sender
        });

        identity.medicalRecords[recordHash] = newRecord;

        emit MedicalRecordAdded(msg.sender, msg.sender, recordHash);
    }

    function grantAccess(address trustedParty) public {
        Identity storage identity = identities[msg.sender];

        require(identity.owner == msg.sender, "You do not have an identity");

        identity.trustedParties[trustedParty] = true;
    }

    function revokeAccess(address trustedParty) public {
        Identity storage identity = identities[msg.sender];

        require(identity.owner == msg.sender, "You do not have an identity");

        identity.trustedParties[trustedParty] = false;
    }

    function getMedicalRecord(bytes32 recordHash) public view returns (string memory diagnosis, string memory treatment, uint256 timestamp, address doctor) {
        Identity storage identity = identities[msg.sender];

        require(identity.owner == msg.sender || identity.trustedParties[msg.sender] == true, "You are not authorized to view this record");

        MedicalRecord memory record = identity.medicalRecords[recordHash];

        return (record.diagnosis, record.treatment, record.timestamp, record.doctor);
    }
}

/* The above Solidity contract implements a decentralized identity system for healthcare, where users can share their medical records with trusted parties.

The contract defines two structs, MedicalRecord and Identity. MedicalRecord contains fields for diagnosis, treatment, timestamp, and the address of the doctor who created the record. Identity contains fields for the owner of the identity, a mapping of trusted parties, and a mapping of medical records.

The contract also defines a mapping of identities, where the key is the address of the identity owner and the value is an Identity struct. The contract includes four functions:

addMedicalRecord: This function allows a user to add a new medical record to their identity. The function takes as input a hash of the record, as well as the diagnosis and treatment. The function creates a new MedicalRecord struct with the input parameters and the current timestamp and adds it to the medicalRecords mapping in the Identity struct for the user. The function emits a MedicalRecordAdded event with the owner's address, the doctor's address (which is set to msg.sender), and the record hash.

grantAccess: This function allows a user to grant access to their medical records to a trusted party. The function takes as input the address of the trusted party. The function sets the value of the trusted party's address in the trustedParties mapping of the user's Identity struct to true.

revokeAccess: This function allows a user to revoke access to their medical records from a trusted party. The function takes as input the address of the trusted party. The function sets the value of the trusted party's address in the trustedParties mapping of the user's Identity struct to false.

getMedicalRecord: This function allows a user or a trusted party to view a medical record associated with the user's identity. The function takes as input the hash of the record. The function first checks if the caller is either the owner of the identity or a trusted party. If the caller is not authorized, the function reverts. If the caller is authorized, the function returns the diagnosis, treatment, timestamp, and doctor address associated with the record.*/

//31. Write a Solidity function to implement a decentralized governance platform, where users can vote on proposals and make decisions about the direction of a project.


// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Governance {
    address public admin;
    uint public proposalCount;
    mapping(uint => Proposal) public proposals;

    struct Proposal {
        uint id;
        address creater;
        string description;
        uint votes;
        bool executed;
        mapping(address => bool) voters;
    }

    constructor() {
        admin = msg.sender;
        proposalCount = 0;
    }

    function createProposal(string memory _description) public {
        proposalCount++;
        Proposal storage p = proposals[proposalCount];
        p.id = proposalCount;
        p.creater = msg.sender;
        p.description = _description;
        p.votes = 0;
        p.executed = false;
    }

    function vote(uint _id) public {
        Proposal storage p = proposals[_id];
        require(!p.voters[msg.sender], "You have already voted on this proposal");
        p.voters[msg.sender] = true;
        p.votes++;
    }

    function executeProposal(uint _id) public {
        Proposal storage p = proposals[_id];
        require(msg.sender == admin, "Only admin can execute proposals");
        require(p.votes > (proposalCount / 2), "The proposal did not receive enough vote");
        require(!p.executed, "The proposal has already been executed");
        p.executed = true;
    }
}

//32. Write a Solidity function to implement a decentralized social media platform, where users can post and interact with content without relying on a centralized authority.


// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.7.0 < 0.9.0;

contract SocialMediaPlatform {
    struct Post {
        uint id;
        address author;
        string content;
        uint timestamp;
        uint[] likes;
        uint[] dislikes;
        uint[] comments;
    }

    struct Comment {
        uint id;
        address author;
        string content;
        uint timestamp;
        uint[] likes;
        uint[] dislikes;
    }

    mapping(uint => Post) public posts;
    uint public postCount;

    mapping(uint => Comment) public comments;
    uint public commentCount;

    function createPost(string memory content) public {
        postCount++;
        uint[] memory likes;
        uint[] memory dislikes;
        uint[] memory comments;
        Post memory newPost = Post(postCount, msg.sender, content, block.timestamp, likes, dislikes, comments);
        posts[postCount] = newPost;
    }

    function likePost(uint postId) public {
        Post storage post = posts[postId];
        require(post.author != address(0), "Post does not exist");
        require(!hasLiked(post.likes, msg.sender), "Already liked");

        post.likes.push(msg.sender);
    }

    function dislikePost(uint postId) public {
        Post storage post = posts[postId];
        require(post.author != address(0), "Post does not exist");
        require(!hasDisliked(post.dislikes, msg.sender), "Already disliked");

        post.dislikes.push(msg.sender);
    }

    function commentOnPost(uint postId, string memory content) public {
        postCount++;
        uint[] memory likes;
        uint[] memory dislikes;
        Comment memory newComment = Comment(commentCount, msg.sender, content, block.timestamp, likes, dislikes);
        comments[commentCount] = newComment;

        Post storage post = posts[postId];
        require(post.author != address(0), "Post does not exist");
        post.comments.push(commentCount);
    }

    function likeComment(uint commentId) public {
        Comment storage comment = comments[commentId];
        require(comment.author != address(0), "Comment does not exist");
        require(!hasLiked(comment.likes, msg.sender), "Already liked");

        comment.likes.push(msg.sender);
    }

    function dislikeComment(uint commentId) public {
        Comment storage comment = comments[commentId];
        require(comment.author != address(0), "Comment does not exist");
        require(!hasDisliked(comment.dislikes, msg.sender), "Already disliked");

        comment.dislikes.push(msg.sender);
    }

    function hasLiked(uint[] memory users, address user) private pure returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == user) {
                return true;
            }
        }

        return false;
    }

    function hasDisliked(uint[] memory users, address user) private pure returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == user) {
                return true;
            }
        }

        return false;
    }
}

//2. 
contract SocialMedia {
    struct Post {
        address author;
        string content;
        uint timestamp;
    }

    Post[] public posts;

    event NewPost(address author, string content);

    function createPost(string memory content) public {
        Post memory post = Post(msg.sender, content, block.timestamp);
        posts.push(post);
        emit NewPost(msg.sender, content);
    }

    function getPostCount() public view returns (uint) {
        return posts.length;
    }

    function getPost(uint index) public view returns (address, string memory, uint) {
        require(index < posts.length, "Invalid post index");
        Post memory post = posts[index];
        return (post.author, post.content, post.timestamp);
    }
}
/*
In this example, the SocialMedia contract stores posts in a dynamic array of Post structs. Each Post struct contains the address of the author, the content of the post, and a timestamp indicating when the post was created.

The createPost function allows users to create new posts by passing in the content of the post. The function creates a new Post struct with the sender's address as the author and the current block timestamp as the timestamp, and adds it to the posts array. The function also emits a NewPost event to notify clients of the new post.

The getPostCount function returns the number of posts currently stored in the posts array.

The getPost function allows clients to retrieve a specific post by passing in its index in the posts array. The function checks that the index is within the bounds of the array, and then returns the author address, content, and timestamp of the specified post.

Note that this example contract does not include any functionality for interacting with posts, such as liking or commenting. Such functionality could be added through additional functions and data structures.
*/

//33. Write a Solidity function to implement a decentralized reputation system, where users can earn reputation points based on their contributions to a project.

contract ReputationSystem {
    
    struct Contributor {
        uint256 reputationPoints;
        bool exists;
    }
    
    mapping (address => Contributor) public contributors;
    
    function contribute(uint256 points) public {
        require(points > 0, "Contribution points must be greater than zero.");
        
        if (!contributors[msg.sender].exists) {
            contributors[msg.sender] = Contributor(0, true);
        }
        
        contributors[msg.sender].reputationPoints += points;
    }
    
    function getReputationPoints(address contributorAddress) public view returns (uint256) {
        require(contributors[contributorAddress].exists, "Contributor does not exist.");
        
        return contributors[contributorAddress].reputationPoints;
    }
}
/*Explanation:

The ReputationSystem contract contains a Contributor struct that includes the number of reputationPoints a contributor has earned, as well as a exists boolean to indicate whether or not the contributor has been added to the mapping.
The contributors mapping associates each contributor's address with their Contributor struct.
The contribute function allows contributors to earn reputation points by contributing to a project. It first checks that the number of points being contributed is greater than zero, and then checks if the contributor already exists in the mapping. If the contributor doesn't exist, a new Contributor struct is created for them with an initial reputation point balance of 0. The contributor's reputation points are then incremented by the number of points being contributed.
The getReputationPoints function allows anyone to look up a contributor's reputation points by passing in their address. It first checks that the contributor exists in the mapping, and then returns their reputation points.
Note that this is just a simple example to illustrate the basic functionality of a decentralized reputation system. In a real-world application, you would likely want to add additional checks and balances to prevent abuse and manipulation of the system. */

//34. Write a Solidity function to implement a decentralized insurance platform, where users can purchase insurance policies and file claims without relying on a centralized insurer.

contract DeccentralizedInsurence {

    struct policy {
        address policyHolder;
        uint256 premiumAmount;
        uint256 payoutAmount;
        uint256 startDate;
        uint256 endDate;
        bool isActive;
        bool hasClaimed;
    }

    mapping (bytes32 => Policy) public policies;
    mapping (address => uint256) public userBalances;

    event PolicyCreated(bytes32 indexed policyHash);
    event PolicyClaimed(bytes32 indexed policyHash);
    
    function createPolicy(bytes32 policyHash, uint256 premiumAmount, uint256 payoutAmount, uint256 startDate, uint256 endDate) public payable {
        require(msg.value == premiumAmount, "Incorrect premium amount");
        require(policies[policyHash].policyHolder == address(0), "Policy alrady exists.");

        Policy memory newPolicy = Policy(msg.sender, premiumAmount, payoutAmount, startDate, endDate, true, false);
        policies[policyHash] = newPolicy;

        emit PolicyCreated(policyHash);
    }

    function fileClaim(bytes32 policyHash) public {
        Policy storage policy = policies[policyhash];
        require(policy.policyHolder == msg.sender, "Only the policy holder can file a claim");
        require(policy.isActive, "Policy is not active");
        require(!policy.hasClaimed, "Policy has already been claimed");
        require(block.timestamp >= policy.startDate, "Claim cannot be filed before start date of the policy");
        require(block.timestamp <= policy.endDate, "Claim connot be filed after the end date of policy");

        policy.hasClaimed = true;
        userBalances[msg.sender] += policy.payoutAmount;

        emit PolicyClaimed(policyHash);
    }

    function withdraw() public {
        require(userBalances[msg.sender] > 0, "No balance to withdraw.");
        uint256 amount = userbalances[msg.sender];
        userBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}

/* The DecentralizedInsurance contract contains a Policy struct that includes information about the policy holder, premium amount, payout amount, start and end dates, and whether or not the policy is active and has been claimed.
The policies mapping associates each policy hash with its corresponding Policy struct.
The userBalances mapping associates each user's address with their balance of payout amounts.
The createPolicy function allows users to create a new policy by passing in a policy hash, premium amount, payout amount, start date, and end date. The function checks that the user has paid the correct premium amount and that a policy with the same hash does not already exist. If the checks pass, a new Policy struct is created and stored in the policies mapping, and an event is emitted.
The fileClaim function allows policy holders to file a claim by passing in a policy hash. The function checks that the caller is the policy holder, that the policy is active and has not already been claimed, and that the current time falls within the start and end dates of the policy. If the checks pass, the hasClaimed flag on the policy is set to true and the policy payout amount is added to the user's balance in the userBalances mapping.
The withdraw function allows users to withdraw their payout amounts by sending a transaction to the contract. The function checks that the user has a non-zero balance in the userBalances mapping, and transfers the payout amount to the user's address
*/

// 35. Write a Solidity function to implement a decentralized job marketplace, where users can find work and hire freelancers without relying on a centralized platform.

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract JobMarketplace {

    struct Job {
        uint256 id;
        address employer;
        uint256 wage;
        string description;
        bool completed;
        address freelancer;
    }

    mapping (uint256 => Job) public jobs;
    uint256 public jobCount = 0;

    function postJob(string memory description, uint256 wage) public {
        require(wage > 0, "Wage must be greater than zero.");
        jobs[jobCount] = Job(jobCount, msg.sender, wage, description, false, address(0));
        jobCount++;
    }

    function applyForJob(uint256 jobId) public {
        require(jobs[jobId].employer != address(0), "Job does not exist.");
        require(!jobs[jobId].completed, "Job has already been completed.");
        require(jobs[jobId].freelancer == address(0), "Job already has a freelancer.");

        jobs[jobId].freelancer = msg.sender;
    }

    function completeJob(uint256 jobId) public {
        require(jobs[jobId].employer == msg.sender, "Only the employer can complete the job.");
        require(jobs[jobId].freelancer != address(0), "Job does not have a freelancer.");
        require(!jobs[jobId].completed, "Job has already been completed.");

        jobs[jobId].completed = true;
        payable(jobs[jobId].freelancer).transfer(jobs[jobId].wage);
    }

    /*
    function registerFreelancer(string memory _name, string[] memory _skills, uint _hourlyRate) public {
        require(bytes(_name).length > 0, "Name is required");
        require(_hourlyRate > 0, "Hourly rate must be greater than 0");

        Freelancer storage freelancer = freelancers[msg.sender];
        freelancer.name = _name;
        freelancer.skills = _skills;
        freelancer.hourlyRate = _hourlyRate;
        freelancer.available = true;

        emit FreelancerRegistered(msg.sender, _name);
    }
    */
}

//36 Write a Solidity function to implement a decentralized advertising platform, where users can earn rewards for viewing and interacting with ads.

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract AdPlatform {
    struct Ad {
        string title;
        string description;
        uint reward;
        address advertiser;
        bool isActive;
    }

    mapping(address => uint) public rewards;
    mapping(address => bool) public hasViewed;
    Ad[] public ads;

    event AdCreated(uint indexed adId, string title, uint reward);
    event AdViewed(uint indexed adId, address indexed viewer);

    function createAd(string memory _title, string memory _description, uint _reward) public {
        require(bytes(_title).length > 0, "Title is required");
        require(_reward > 0, "Reward must be greater than 0");

        ads.push(Ad({
            title: _title,
            description: _description,
            reward: _reward,
            advertiser: msg.sender,
            isActive: true
        }));

        uint adId = ads.length - 1;

        emit AdCreated(adId, _title, _reward);
    }

    function viewAd(uint _adId) public {
        require(_adId >= 0 && _adId < ads.length, "Invalid ad ID");

        Ad storage ad = ads[_adId];
        require(ad.isActive, "Ad is not active");

        require(!hasViewed[msg.sender], "User has already viewed this ad");

        rewards[msg.sender] += ad.reward;
        hasViewed[msg.sender] = true;

        emit AdViewed(_adId, msg.sender);
    }

    function withdrawRewards() public {
        uint reward = rewards[msg.sender];
        require(reward > 0, "No rewards to withdraw");

        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(reward);
    }
}

//37. Write a Solidity function to implement a decentralized real-time bidding platform, where advertisers can bid on ad space in real time.

contract RealTimeBidding {
    struct Ad {
        address advertiser;
        uint bid;
        uint startTime;
        uint endTime;
        bool active;
    }

    mapping(uint => Ad) public adSlots;
    uint public numSlots;
    uint public slotDuration;
    uint public slotPrice;
    uint public auctionEndTime;

    event AdBid(uint indexed slotId, address indexed advertiser, uint bid);

    constructor(uint _numSlots, uint _slotDuration, uint _slotPrice) {
        numSlots = _numSlots;
        slotDuration = _slotDuration;
        slotPrice = _slotPrice;
    }

    function startAuction() public {
        require(block.timestamp >= auctionEndTime, "Auction is already in progress");

        auctionEndTime = block.timestamp + slotDuration * numSlots;

        for (uint i = 0; i < numSlots; i++) {
            adSlots[i] = Ad({
                advertiser: address(0),
                bid: 0,
                startTime: auctionEndTime + i * slotDuration,
                endTime: auctionEndTime + (i + 1) * slotDuration,
                active: false
            });
        }
    }

    function placeBid(uint _slotId, uint _bid) public {
        require(_slotId >= 0 && _slotId < numSlots, "Invalid slot ID");
        require(_bid >= slotPrice, "Bid must be greater than or equal to slot price");
        require(block.timestamp < auctionEndTime, "Auction has ended");

        Ad storage ad = adSlots[_slotId];

        if (!ad.active || _bid > ad.bid) {
            ad.advertiser = msg.sender;
            ad.bid = _bid;
            ad.active = true;

            emit AdBid(_slotId, msg.sender, _bid);
        }
    }
}

/* In this implementation, there is one main data structure: Ad. A real-time bidding auction is started by calling the startAuction function, which initializes an array of numSlots ad slots, each with a duration of slotDuration and a price of slotPrice. The auctionEndTime variable is used to determine when the auction ends.

Advertisers can bid on ad slots by calling the placeBid function and passing in the slot ID and bid amount. The function checks that the bid is greater than or equal to the slot price, the auction is still in progress, and the bid is the highest received for the slot. If all of these conditions are met, the ad slot is assigned to the advertiser and the bid amount is recorded.

The event AdBid is emitted whenever a new bid is placed.

It's important to note that a fully functional decentralized real-time bidding platform will likely have more features, such as a more sophisticated bidding algorithm, anti-fraud measures, and a mechanism for determining the winning bid for each ad slot. */


//38. Write a Solidity function to implement a decentralized credit scoring system, where users can receive credit scores based on their financial behavior and use these scores to obtain loans.

contract CreditScoring {
    struct User {
        uint score;
        uint balance;
        bool exists;
    }

    mapping(address => User) public users;

    function uodateCreditScore(address _user, uint _transactionAmount) public {
        uint scoreChange;

        if(_transactionAmount >= 1000) {
            scoreChange = 50;
        } else if (_transactionAmount >= 500){
            scoreChange = 30;
        } else if (_transactionAmount >= 100 ){
            scoreChange = 10;
        } else if (_transactionAmount >= 10) {
            scoreChange = 5
        }else {
            scoreChange = 1;
        }

        users[_user].score += scoreChange;
    }

    function checkCreditScore(address _user) public view returns(uint) {
        require(users[_user].exists, "User does not exist");
        return users[_user].score;
    }

    function applyForLoad(uint _amount) public returns (bool) {
        require(users[msg.sender].exists "User does not exist");
        require(users[msg.sender].score >= 50, "Credit score too low");
        require(users[msg.sender].balance >= _amount, "Insufficient balance");

        //Process loan application
        users[msg.sender].balance -= _amount;
        return true;
    }

    function registerUser() public {
        require(!users[msg.sender].exists, "User already exists");

        users[msg.sender] = User({
            score: 0,
            balance: 0,
            exists: true
        });
    }

    function updateBalance(uint _amount) public {
        require(users[msg.sender].exists, "User does not exist");
        users[msg.sender].balance += _amount;
    }

}

/* In this implementation, each user is represented by a User struct, which contains their credit score (score), balance (balance), and whether they exist in the system (exists).

The updateCreditScore function is used to update a user's credit score based on their financial behavior. The function takes in the user's address and the transaction amount and calculates the score change based on the transaction amount. The score change is then added to the user's credit score.

The checkCreditScore function allows users to check their current credit score.

The applyForLoan function is used to apply for a loan. The function checks that the user exists, has a credit score of at least 50, and has a balance greater than or equal to the loan amount. If all of these conditions are met, the loan application is processed by deducting the loan amount from the user's balance.

The registerUser function is used to register a new user in the system.

The updateBalance function is used to update a user's balance.

It's important to note that this is a basic implementation and a fully functional decentralized credit scoring system will likely have more features, such as a more sophisticated credit scoring algorithm and a mechanism for determining loan eligibility based on credit score and other factors.*/

//39. Write a Solidity function to implement a decentralized voting system, where users can cast votes that are counted in a transparent and tamper-proof way.

contract VotingSystem {
    struct Vote {
        address voter;
        uint choice;
    }

    mapping(address => Vote) public votes;
    mapping(uint => uint) public voteCounts;
    uint public numChoices;

    event VoteCast(address indexed voter, uint choice);

    constructor(uint _numChoices) {
        numChoices = _numChoices;
    }

    function castVote(uint _choice) public {
        require(_choice >= 0 && _choice < numChoices, "Invalid vote choice");

        Vote storage vote = votes[msg.sender];
        require(vote.voter == address(0), "Voter has already cast a vote");

        vote.voter = msg.sender;
        vote.choice = _choice;

        voteCounts[_choice]++;

        emit VoteCast(msg.sender, _choice);
    }

    function getVoteCount(uint _choice) public view returns (uint) {
        require(_choice >= 0 && _choice < numChoices, "Invalid vote choice");

        return voteCounts[_choice];
    }
}

/* In this implementation, there is one main data structure: Vote. The contract is initialized with a numChoices value, which determines the number of possible choices for each vote. The castVote function is used to cast a vote, which must be within the valid range of choices and the user must not have already cast a vote. The getVoteCount function is used to retrieve the number of votes for a particular choice.

The contract uses two mappings to store vote data: votes stores the user's vote choice, and voteCounts stores the total number of votes for each choice. Whenever a vote is cast, the corresponding vote count is incremented.

The contract also emits an event VoteCast whenever a new vote is cast, providing transparency to the voting process.

It's important to note that a fully functional decentralized voting system will likely have more features, such as a mechanism for verifying the identity of voters, a way to prevent double voting, and a way to audit the voting process to ensure its integrity.
*/

//40 . Write a Solidity function to implement a decentralized data marketplace, where users can buy and sell data without relying on a centralized authority.

contract DataMarketplace {
    
    struct Data {
        address owner;
        uint price;
        string metadata;
        bool isAvailable;
    }
    
    mapping(uint => Data) private dataRegistry;
    uint private dataCounter;
    
    event DataAdded(uint indexed id, address indexed owner, uint price, string metadata);
    event DataSold(uint indexed id, address indexed buyer, uint price);
    
    function addData(uint price, string memory metadata) public {
        require(price > 0, "Price must be greater than 0");
        dataCounter++;
        dataRegistry[dataCounter] = Data(msg.sender, price, metadata, true);
        emit DataAdded(dataCounter, msg.sender, price, metadata);
    }
    
    function buyData(uint id) public payable {
        require(dataRegistry[id].isAvailable, "Data is not available");
        require(msg.value == dataRegistry[id].price, "Incorrect payment amount");
        
        address payable seller = payable(dataRegistry[id].owner);
        seller.transfer(msg.value);
        dataRegistry[id].isAvailable = false;
        
        emit DataSold(id, msg.sender, msg.value);

        // Remove data after purchase
        delete data[id];
    }
    
    function getData(uint id) public view returns (address, uint, string memory, bool) {
        return (dataRegistry[id].owner, dataRegistry[id].price, dataRegistry[id].metadata, dataRegistry[id].isAvailable);
    }
}
/* This contract allows users to add data to the marketplace by specifying a price and metadata, and also allows users to buy available data by sending the correct payment amount to the owner. The contract keeps track of the data in a mapping, and emits events when new data is added or sold.

To use this contract, users can interact with it using a web3-enabled browser like MetaMask. They can call the addData function to add their own data to the marketplace, and call the buyData function to buy available data from other users. The getData function can be used to retrieve information about a specific piece of data, including the owner, price, metadata, and availability.
*/

//41. Write a Solidity function to implement a decentralized energy trading platform, where users can buy and sell renewable energy certificates (RECs).
contract EnergyTrading {
    // Define data structures
    struct REC {
        string name;
        uint256 amount;
        uint256 price;
        address seller;
        bool exists;
    }

    mapping(uint256 => REC) public recs;
    uint256 public recCount;

    // Events
    event RECAdded(uint256 id, string name, uint256 amount, uint256 price, address seller);
    event RECPurchased(uint256 id, string name, uint256 amount, uint256 price, address buyer);

    // Functions for adding and buying RECs
    function addREC(string memory _name, uint256 _amount, uint256 _price) public {
        require(bytes(_name).length > 0, "REC name cannot be empty");
        require(_amount > 0, "REC amount must be greater than 0");
        require(_price > 0, "REC price must be greater than 0");

        recCount++;
        recs[recCount] = REC(_name, _amount, _price, msg.sender, true);
        emit RECAdded(recCount, _name, _amount, _price, msg.sender);
    }

    function buyREC(uint256 _id, uint256 _amount) public payable {
        require(recs[_id].exists, "REC does not exist");
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= recs[_id].amount, "Not enough RECs available");
        uint256 totalCost = _amount * recs[_id].price;
        require(msg.value == totalCost, "Incorrect payment amount");

        address payable seller = payable(recs[_id].seller);
        seller.transfer(msg.value);
        emit RECPurchased(_id, recs[_id].name, _amount, totalCost, msg.sender);

        // Update remaining REC amount
        recs[_id].amount -= _amount;

        // Remove REC if no more available
        if (recs[_id].amount == 0) {
            delete recs[_id];
        }
    }
}

/* Implementing a decentralized energy trading platform for buying and selling renewable energy certificates (RECs) in Solidity requires defining data structures, writing functions for buying and selling RECs, and implementing payment and dispute resolution mechanisms. Here is an example implementation of a decentralized energy trading platform for RECs in Solidity:

scss
Copy code
pragma solidity ^0.8.0;

contract EnergyTrading {
    // Define data structures
    struct REC {
        string name;
        uint256 amount;
        uint256 price;
        address seller;
        bool exists;
    }

    mapping(uint256 => REC) public recs;
    uint256 public recCount;

    // Events
    event RECAdded(uint256 id, string name, uint256 amount, uint256 price, address seller);
    event RECPurchased(uint256 id, string name, uint256 amount, uint256 price, address buyer);

    // Functions for adding and buying RECs
    function addREC(string memory _name, uint256 _amount, uint256 _price) public {
        require(bytes(_name).length > 0, "REC name cannot be empty");
        require(_amount > 0, "REC amount must be greater than 0");
        require(_price > 0, "REC price must be greater than 0");

        recCount++;
        recs[recCount] = REC(_name, _amount, _price, msg.sender, true);
        emit RECAdded(recCount, _name, _amount, _price, msg.sender);
    }

    function buyREC(uint256 _id, uint256 _amount) public payable {
        require(recs[_id].exists, "REC does not exist");
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= recs[_id].amount, "Not enough RECs available");
        uint256 totalCost = _amount * recs[_id].price;
        require(msg.value == totalCost, "Incorrect payment amount");

        address payable seller = payable(recs[_id].seller);
        seller.transfer(msg.value);
        emit RECPurchased(_id, recs[_id].name, _amount, totalCost, msg.sender);

        // Update remaining REC amount
        recs[_id].amount -= _amount;

        // Remove REC if no more available
        if (recs[_id].amount == 0) {
            delete recs[_id];
        }
    }
}
In this implementation, the REC struct defines the properties of each renewable energy certificate, including its name, amount, price, and the seller's address. The recs mapping stores each certificate, indexed by a unique identifier id. The recCount variable keeps track of the total number of certificates in the marketplace.

The addREC function allows sellers to add certificates to the marketplace by specifying the certificate's name, amount, and price. The function checks that the name, amount, and price are valid and then adds the certificate to the recs mapping with a new id and the seller's address. The function also emits a RECAdded event to notify clients of the new certificate.

The buyREC function allows buyers to purchase certificates from the marketplace by specifying the id of the desired certificate and the amount to purchase, and sending the correct amount of ether to the marketplace contract. The function checks that the specified certificate exists, that the requested amount is available, and that the correct amount of ether was sent. If the payment is correct, the function transfers the ether to the seller's address and emits a RECPurchased event to notify clients of the purchase. Finally, the function updates the remaining amount of the certificate and removes
*/

//42. Write a Solidity function to implement a decentralized prediction market for weather events, where users can bet on the outcome of weather events such as hurricanes and tornadoes.

contract WeatherMarket {
    // Define data structures
    struct Bet {
        uint256 amount;
        bool outcome;
        bool exists;
    }

    struct WeatherEvent {
        string name;
        uint256 endTime;
        bool occurred;
        bool exists;
        bool outcome;
        mapping(address => Bet) bets;
        address[] betters;
    }

    mapping(uint256 => WeatherEvent) public events;
    uint256 public eventCount;

    // Events
    event BetPlaced(uint256 eventId, address bettor, uint256 amount, bool outcome);
    event EventResolved(uint256 eventId, bool outcome);

    // Functions for placing and resolving bets
    function placeBet(uint256 _eventId, bool _outcome) public payable {
        require(events[_eventId].exists, "Event does not exist");
        require(!events[_eventId].occurred, "Event has already occurred");
        require(msg.value > 0, "Bet amount must be greater than 0");

        events[_eventId].bets[msg.sender] = Bet(msg.value, _outcome, true);
        events[_eventId].betters.push(msg.sender);
        emit BetPlaced(_eventId, msg.sender, msg.value, _outcome);
    }

    function resolveEvent(uint256 _eventId, bool _outcome) public {
        require(events[_eventId].exists, "Event does not exist");
        require(!events[_eventId].occurred, "Event has already occurred");
        require(block.timestamp >= events[_eventId].endTime, "Event has not yet ended");

        events[_eventId].occurred = true;
        events[_eventId].outcome = _outcome;
        emit EventResolved(_eventId, _outcome);
    }

    // Functions for withdrawing winnings
    function withdrawWinnings(uint256 _eventId) public {
        require(events[_eventId].exists, "Event does not exist");
        require(events[_eventId].occurred, "Event has not yet occurred");
        require(events[_eventId].bets[msg.sender].exists, "No bet placed");

        uint256 amount = events[_eventId].bets[msg.sender].amount;
        bool outcome = events[_eventId].bets[msg.sender].outcome;
        bool correctOutcome = events[_eventId].outcome == outcome;

        if (correctOutcome) {
            // Pay out winnings
            uint256 payout = amount * (100 + (100 / events[_eventId].betters.length)) / 100;
            payable(msg.sender).transfer(payout);
        } else {
            // Return original bet
            payable(msg.sender).transfer(amount);
        }

        delete events[_eventId].bets[msg.sender];
    }
}

//43 . Write a Solidity function to implement a decentralized music streaming platform, where users can stream music and earn rewards for creating and sharing playlists.
contract MusicPlatform {
    // Define data structures
    struct Song {
        string title;
        string artist;
        string url;
        uint256 plays;
        bool exists;
    }

    struct Playlist {
        string name;
        address owner;
        mapping(uint256 => Song) songs;
        uint256 songCount;
        uint256 plays;
        bool exists;
    }

    mapping(uint256 => Song) public songs;
    mapping(uint256 => Playlist) public playlists;
    uint256 public songCount;
    uint256 public playlistCount;

    // Events
    event SongUploaded(uint256 songId, string title, string artist);
    event SongPlayed(uint256 songId);
    event PlaylistCreated(uint256 playlistId, string name, address owner);
    event PlaylistShared(uint256 playlistId);

    // Functions for uploading and streaming music
    function uploadSong(string memory _title, string memory _artist, string memory _url) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_artist).length > 0, "Artist cannot be empty");
        require(bytes(_url).length > 0, "URL cannot be empty");

        songs[songCount] = Song(_title, _artist, _url, 0, true);
        emit SongUploaded(songCount, _title, _artist);
        songCount++;
    }

    function playSong(uint256 _songId) public {
        require(songs[_songId].exists, "Song does not exist");

        songs[_songId].plays++;
        emit SongPlayed(_songId);
    }

    // Functions for creating and sharing playlists
    function createPlaylist(string memory _name) public {
        require(bytes(_name).length > 0, "Playlist name cannot be empty");

        playlists[playlistCount] = Playlist(_name, msg.sender, 0, 0, true);
        emit PlaylistCreated(playlistCount, _name, msg.sender);
        playlistCount++;
    }

    function sharePlaylist(uint256 _playlistId) public {
        require(playlists[_playlistId].exists, "Playlist does not exist");
        require(playlists[_playlistId].owner == msg.sender, "Only owner can share playlist");

        playlists[_playlistId].plays++;
        emit PlaylistShared(_playlistId);
    }

    // Functions for rewarding users for creating and sharing playlists
    function rewardPlaylist(uint256 _playlistId) public {
        require(playlists[_playlistId].exists, "Playlist does not exist");
        require(playlists[_playlistId].owner == msg.sender, "Only owner can claim reward");

        uint256 reward = playlists[_playlistId].plays * 100;
        payable(msg.sender).transfer(reward);
    }
}
/*In this implementation, the Song struct defines a music track, including its title, artist, URL, number of plays, and whether it exists. The Playlist struct defines a playlist, including its name, owner, songs, number of songs, number of plays, and whether it exists. The songs mapping stores each song, indexed by a unique identifier songId. The playlists mapping stores each playlist, indexed by a unique identifier playlistId. The songCount and playlistCount variables keep track of the total number of songs and playlists on the platform.

The uploadSong function allows users to upload a new song to the platform by specifying
*/

//44. Write a Solidity function to implement a decentralized ride-sharing platform, where users can find and offer rides without relying on a centralized platform.

contract RideSharingPlatform {
    struct Ride {
        address driver;
        uint256 seatsAvailable;
        uint256 pricePerSeat;
        mapping(address => bool) passengers;
    }

    mapping(uint256 => Ride) public rides;

    event RideOffered(uint256 rideId, address driver, uint256 seatsAvailable, uint256 pricePerSeat);
    event RideBooked(uint256 rideId, address passenger);

    function offerRide(uint256 _seatsAvailable, uint256 _pricePerSeat) public {
        require(_seatsAvailable > 0, "Ride must have at least one seat available");
        require(_pricePerSeat > 0, "Price per seat must be greater than zero");

        uint256 rideId = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)));

        rides[rideId] = Ride({
            driver: msg.sender,
            seatsAvailable: _seatsAvailable,
            pricePerSeat: _pricePerSeat
        });

        emit RideOffered(rideId, msg.sender, _seatsAvailable, _pricePerSeat);
    }

    function bookRide(uint256 _rideId) public payable {
        Ride storage ride = rides[_rideId];

        require(ride.driver != address(0), "Ride does not exist");
        require(!ride.passengers[msg.sender], "Passenger has already booked this ride");
        require(ride.seatsAvailable > 0, "No seats available");

        uint256 totalCost = ride.pricePerSeat * 1 ether;
        require(msg.value >= totalCost, "Insufficient payment");

        ride.passengers[msg.sender] = true;
        ride.seatsAvailable--;

        emit RideBooked(_rideId, msg.sender);

        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }
}
















