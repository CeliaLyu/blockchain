/*
 I refer to the following resources I found on Internet:
    1. https://www.bilibili.com/video/BV13Z4y127Ea/?spm_id_from=333.788
    2. https://www.bilibili.com/video/BV1DY411j75y/?spm_id_from=333.788&vd_source=cfe829c5f5babcd4bceee511757a067f
    3. https://coinsbench.com/solidity-smart-contract-for-rock-paper-scissors-6420f43d534d
    4. https://github.com/94929/rock-paper-scissors/blob/master/RockPaperScissors.sol
*/





/*
    - This smart contract can guarantees the fair exchange in non-syncing game, no matter who commit to their choice at first. 
    - Define input data:
        1: scissors; 
        2: rock; 
        3: paper.
    - Use library 
        how to get the winner
    - Use interface (optional)
*/


pragma solidity^0.8.7;
// SPDX-License-Identifier: UNLICENSED


// Define the interface
interface IRPS {
    // register
    function register(string memory _name) external payable;
    // choose
    function choose(bytes32 _hash) external payable; 
    // verify 
    function proof(uint8 _opt, string memory _salt) external; // to make sure others can see your choice, we need to use hash value
    // winner
    // return values: 
        // 1) name of the winner, 
        // 2) what player 1 commit, 
        // 3) what player 2 commit, 
        // 4) how many rounds they have to have the winner 
        // 5) what is the final balance of the winner
        // 6) what is the final balance of the loser
    function winner() external view returns (string memory, uint8, uint8, uint256, uint, uint); 
    function resetAll() external;
}


// Define library
library Math{
    // player 1, player 2
    // return values: 
        // 0: tie
        // 1: player 1 wins
        // 2: player 2 wins
    function winner(uint8 a, uint8 b) internal pure returns (uint8) {
        require(a<=3);
        require(b<=3);
        if (a==b) {
            return 0;
        } else if (a>b) {
            // a=2, b=1
            // a=3, b=2
            // a=3, b=1
            return a-b;
        } else {
            if (b-a==2) return 1;
            if (b-a==1) return 2;
        }
        return 0;
    }
}


// Info of players
struct Player {
    address user;
    string  name;
    uint8   opt;   // what does this player commit (0, 1, or 2)
    uint256 round; // which round the player is in 
    bytes32 hash;
    uint8 status; // 0: player hasn't commit 1: player has already commit (the hash value) 2: has already submit the proof
}


contract RPS is IRPS {
    // constraint on the number of players (2)
    uint8 userCount; 
    // record of user info
    Player[2] playerlist;
    // if the game ens
    bool isFinished; // default value is false
    // record who is the winner
    uint8 winnerIndex; 
    // WinnerLog is an event to notice who is winner
    event WinnerLog(address indexed addr, uint8 opt, uint retval);
    // When a player joins the game, they have to pay a playing fee, the stake should be visible to Player2 so I use "public" here.
    uint256 public stake; 
    // The constructor initialise the stake. If the player doesn't setup his/her pre-paied moeny, the pre-paid money will automatically be set as 0.01 ether.  
    constructor() payable {stake = 0.01 ether;} 
    // mapping(address=>uint) public balances;
    mapping(address => uint) public balances;
    // block number to prevent timeout attack
    uint256 public startBlock = block.number;


    // reset all if there is a winner
    function resetAll() override external {
        require(isFinished, "game has not finished");
        // reset variables to start a new game between those 2 players
        startBlock = block.number;
        playerlist[0].opt = 0;
        playerlist[0].round = 0;
        playerlist[0].hash = "";
        playerlist[0].status = 0;
        playerlist[1].opt = 0;
        playerlist[1].round = 0;
        playerlist[1].hash = "";
        playerlist[1].status = 0;
        isFinished = false; // default value of isFinished is false
    }

    // register
    function register(string memory _name) override external payable {
        require (userCount<2, "two player already go");
        playerlist[userCount].user = msg.sender;
        playerlist[userCount].name = _name;
        userCount++;
        // player 1 can choose the stake, player 2 has to match.
        require((playerlist[0].user != msg.sender && msg.value == stake) || playerlist[0].user == msg.sender, "you must pay the stake to play the game; if you are the second player, please match the stake from player 1");
        // player 1 can not set the stake less than 0; otherwise - it means that player 1 and 2 might be able to collaborate to play this game for free
        require(msg.value > 0, "you must set your stake greater than 0 wei");
        // player 1 determines the stake
        if (playerlist[0].user == msg.sender) {
            stake = msg.value;
        } 
    }

    // choose
    function choose(bytes32 _hash) override external payable {
        // 1. validate player info
        require(isPlayer(msg.sender), "only register player can do");
        // 2. game has not ended
        require(!isFinished, "game already finished");
        // 3. make sure the user has paied to play the game
        require(msg.value == stake, "please pay to participate");
        // 4. prevent timeout
        require(block.number < (startBlock + 50));
        // 5. distinguish between player 1 and player 2
        uint8 host;
        uint8 client;
        if(playerlist[0].user == msg.sender) {
            host=0;
            client=1;
        } else {
            host=1;
            client=0;
        }
        Player storage player=playerlist[host];
        require(player.status == 0, "player has already chosen");
        // see if the other player have already commit
            // 1: < client commits first 
            // 2: = host commits first in this round 
            // 3: > need to wait for the other player to commit
        require(player.round <= playerlist[client].round, "please wait"); 
        player.hash = _hash; 
        player.status = 1;
        player.round ++;
    }

    // proof
    function proof(uint8 _opt, string memory _salt) override external {
        // 1. validate player information
        require(isPlayer(msg.sender), "only register player can do");
        // 2. game has not ended
        require(!isFinished, "game already finished");
        // 3. prevent timeout
        require(block.number < (startBlock + 100));
        // 4. distinguish between player 1 and player 2
        uint8 host;
        uint8 client;
        if(playerlist[0].user == msg.sender) {
            host=0;
            client=1;
        } else {
            host=1;
            client=0;
        }
        Player storage player=playerlist[host];
        require(player.status == 1, "player can not proof at current status"); // the player has already committed
        player.status = 2;
        // see who wins
        bytes32 hash = keccak256(abi.encode(_opt, _salt));
        // if player cheat
            // if player commit a choice other than 1,2,3 or the hash value doesn't match, this player will directly lose the money, and the game ends
        if(_opt > 3 || hash != player.hash) {
            isFinished = true;
            winnerIndex = client;
            balances[playerlist[client].user] += 2*stake;
            emit WinnerLog(msg.sender, _opt, 255);
            return;
        }
        // if there is no cheating
        player.opt = _opt;
        // both players has submitted the hash value
        if(player.status == playerlist[client].status && player.status == 2) { 
            uint8 win = Math.winner(player.opt, playerlist[client].opt);
            // status:
            // 0: tie
            // 1: player 2 wins
            // 2: player 1 wins
            if (win == 0) {
                player.status = 0;
                playerlist[client].status = 0;
                balances[playerlist[host].user] += stake;
                balances[playerlist[client].user] += stake;
            }
            else if(win == 1) {
                winnerIndex = host;
                balances[playerlist[winnerIndex].user] += 2*stake;
                isFinished = true;
            } else if(win == 2) {
                winnerIndex = client;
                balances[playerlist[winnerIndex].user] += 2*stake;
                isFinished = true;
            }
            // trigger the event
            emit WinnerLog(msg.sender, _opt, win);
        }
    }

    // winner
        // return values: 
        // 1) name of the winner, 
        // 2) what player 1 commit, 
        // 3) what player 2 commit, 
        // 4) how many rounds they have to have the winner 
        // 5) balance of winner 
        // 6) balance of loser
    function winner() override external view returns (string memory, uint8, uint8, uint256, uint, uint) {
        if(!isFinished) {
            return ("", 255, 255, 888, 66, 66);
        } 
        uint8 index = 0; // index represents index of the one who lose the game
        if(winnerIndex == 0) index= 1;
        return (
            playerlist[winnerIndex].name,
            playerlist[winnerIndex].opt,
            playerlist[index].opt,
            playerlist[winnerIndex].round,
            balances[playerlist[winnerIndex].user],
            balances[playerlist[index].user]
        );
    }

    // see if registered player
    function isPlayer(address _addr) public view returns (bool) {
        if(_addr == playerlist[0].user || _addr ==playerlist[1].user) return true;
        return false;
    }

    // provide a helper function to help players get the hash value
    function helper(string memory _salt, uint8 _opt) public pure returns (bytes32) {
        return keccak256(abi.encode(_opt, _salt));
    }

    // In case either party did not participate, refund money
        // If someone did not submit a hash, the other person can refund their deposit, hence getting back the stake.
        // If someone did not proof/reveal their choice within the timeframe, the other person can refund their deposit and get the opponent’s stake. 
    function refundMoney() public {
        bool NoHash = block.number >= (startBlock + 50) && (playerlist[0].hash == "" || playerlist[1].hash == "");
        bool NoProof = block.number >= (startBlock + 100) && (playerlist[0].opt == 0 || playerlist[1].opt == 0);
        require(NoHash || NoProof);
        require(address(this).balance >= stake);
        if (block.number >= (startBlock + 100)) {
            if (playerlist[0].opt == 0 && playerlist[1].opt != 0) {
                balances[playerlist[1].user] += 2*stake;
            } else if (playerlist[0].opt != 0 && playerlist[1].opt == 0) {
                balances[playerlist[0].user] += 2*stake;
            } else {
                balances[playerlist[0].user] += stake;
                balances[playerlist[1].user] += stake;
            }
        } else if (block.number >= (startBlock + 50)) {
            if (playerlist[0].hash == "" && playerlist[1].hash != "") {
                balances[playerlist[1].user] += stake;
            } else if (playerlist[0].hash != "" && playerlist[1].hash == "") {
                balances[playerlist[0].user] += stake;
            }
        }
    }

    // This function is for people to claim their money from balances
        /*
        Reentrancy attacks mean a malicious player can trick the smart contract to call a malicious function when the smart contract is paying money to the player, 
        and then this malicious function will call (reenter) the transferMoney function of this smart contract again.
        If we directly send the amount of balances[msg.sender] to the user, without decrementing the balances before sending, 
        the balances will still be positive and will still continue to send the money again and again, until the smart contract runs out of money.
        This function handles reentrancy attacks by first saving the amount, clearing the balances, and then sending the amount. 
        If the user reenters, its balances will be zero and hence cannot reenter the transfer process. If the transfer is unsuccessful, it set the balances back to the amount.
        */
    // Each player can transfer the money from his/her balance into his/her ETH account
    function transferMoney() public {
        uint money = balances[msg.sender];
        balances[msg.sender] = 0;
        bool contract_money_pocket = payable(msg.sender).send(money);
        if (contract_money_pocket == false) {
            balances[msg.sender] = money;
        }
    }

}





/*
    Go through the following steps to play the game as a player: 
    1. Choose your account, input your name after the button "register", and choose your stake as "VALUE", and click the button "register".
        If your input value is 0 or less than 0, or doesn't match the current stake (if you are the 2nd player), you will not be able to successfully register.
    2. Click the button "helper" to set the hash value of your choice and the salt you set. Speficically, 
        Here I just set value of _salt in the function helper as "1900", of course players can set it as any value they like;
        _opt is the choice the player made:         
            O: scissors; 
            1: rock; 
            2: paper.
        After clicking the button "call", I can get a hash value: 
        e.g., 
            salt: 1900; opt: 2
            0x2dffc8e4d5d05dba02da6487f03612c0c48db898bc4e7fa2be4933a034568414
            salt: 2100; opt: 3
            0x92933c7165b960d1e8631824ff06db646ae625fec3bea82269d84052a3853235
            salt: 1900; opt: 3
            0x718a75a68e9899b5c15a1e714031c5259c4a3b46c4df393e9d78ada1ec819155
    3. Copy and paste the hash value I got into the space following button "choose", and click the button "choose".
        When choosing, only if the stakes of 2 players match, the choose function can be executed.
    4. After the other player step 1-4, you click on the drop-down menu of bottun "proof", then copy and paste your choice in to "_opt", copy and paste your salt in to "_salt", 
        -> then click the button "transact", to proof that the hash value I enter into the space following button "choose" is valid. 
    5. Any user can click the button "winner" anytime, to see who is the winner. 
        0: Name of the winner
        1: what chocie does the winner made in the latest round
        2: what chocie does the loser made in the latest round
        3: how many round do these 2 players have, to have a winner
        4: what is the final balance of the winner
        5: what is the final balance of the loser
        If there is no winner currently, the default value of those 6 variables will be shown. 
    6. Click the button "transferMoney" to claim their money from balances to their ETH account
    7. In case either party did not participate, the player can refund his/her money by clicking the button "refundMoney".
    8. Once there is a winner, the game should ends; any player can click the botton "resetAll" to reset the game between player 1 and player 2.
        Stake will keep the same unchanged.
        Player 1 and Player 2 can make new choices to play a new game, unitl either of them becomes a winner.
*/



/*
    The smart contract I write can successfully prevent the following attacks: 
    1. If you want to commit (i.e., call function "choose"), you must register first.
    2. When register, your input stake in "VALUE" must be greater than 0.
    3. If you are the second registered player, your input stake in "VALUE" must match the one from the player who registered first. 
    4. There should be only 2 player registered. 
    5. Too make sure the commit choice will be be seen by the other player before revealing the choice, I use Hash with salt here.
        The function "function helper" is to help player get the hash value of their choise with the salt set be themselves.
    6. If the user has already commit the hash value, he/she can not re-enter a new hash value - we use the variable "round" in function "choose" to achieve this. 
    7. In my function "Proof", I also check if any player cheat here 
        e.g., submits choice other than 1,2,3, or submit invalid hash value which is different from what they enter into funtion "choose".
        If cheating is detected, the cheater's stake will go to the other player's balance.
    8. If there is a tie, the game will continue, until there is a winner (and loser). 
    9. I use  startBlock = block.number to prevent timeout attack, and use function refundDeposit() to refund the money to players if timeout attack is detected. 
    10. The function "transferMoney()" can help prevent reentrancy attacks.
*/
