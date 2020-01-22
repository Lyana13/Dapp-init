pragma solidity ^0.4.22;

contract Passport {
     struct User {
        string name;
        string surname;
        uint age;
        uint id;
    }
    
    mapping(address => User) private users;
     
    function create(string name, string surname, uint age) public {
        require(users[msg.sender].id == 0,  "User already registered!");
        users[msg.sender] = User(name, surname, age, uint(msg.sender));
    }
    
    function exist(address addr) public view returns (bool){
        return users[addr].id != 0;
    }
    
}

contract Election {
    address owner;
    Passport private passport;
    
    constructor(Passport _passport) public {
        passport = _passport;
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed!");
        _;
    }
    
    modifier electionInProgress(){
         require(isFinished == false, "Election is finished!");
         _;
    }
    struct Candidate {
        uint votes;
        bool registered;
    }
    
    mapping(address => Candidate) private candidates;
    mapping(address => bool) private voters;
    address public winner;
    bool public isFinished;
    address private leader;
    uint private leaderVotes;
    
    function registerCandidate(address addrCandidate) public onlyOwner electionInProgress {
        require(candidates[addrCandidate].registered == false, "Candidate already registered!");
        candidates[addrCandidate] = Candidate(0, true);
        
    }
    
    function vote(address addrCandidate) public electionInProgress {
       require(candidates[addrCandidate].registered == true, "Candidate is not registered!");
       require(passport.exist(msg.sender) == true, "You don't have a passport!");
       require(voters[msg.sender] == false, "You have already voted!");
       require(isFinished == false, "Election is finished!");
       voters[msg.sender] = true;
       candidates[addrCandidate].votes += 1;
       if(candidates[addrCandidate].votes > leaderVotes) {
           leader = addrCandidate;
           leaderVotes = candidates[addrCandidate].votes;
       }
    }
    
    function finish() public onlyOwner electionInProgress {
        isFinished = true;
        winner = leader;
    }
}