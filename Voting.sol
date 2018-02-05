pragma solidity ^4.0.19;

contract Ballot {

  // create a struct (data structure)
  // for the Voter object
  struct Voter {
    uint weight; // voting weight
    bool voted; // bool for if the Voter voted
    address delegate; // assign delegate if necessary
    uint vote;
  }

  // create a struct
  // for the Proposal object
  struct Proposal {
    bytes32 name; // bytes32 is a string
    uint voteCount; // holds how many votes for Proposal
  }

  // assign the address for chairperson 
  // (public creates getters)
  address public chairperson;

  // create a mapping (basically an object)
  // that maps an address as the key
  // and a Voter as the value
  // named it voters
  mapping(address => Voter) public voters;

  // create an array of Proposals
  Proposal[] public proposals;

  // Constructor function
  // takes in an array of strings 
  function Ballot(bytes32[] proposalNames) public {
    // assign the chairperson
    // to the sender of the contract
    chairperson = msg.sender;

    // change the weight of the voter
    // go inside the voters map
    // create the chairperson key
    // assign it's weight to 1
    voters[chairperson].weight = 1;

    // loop over all the proposal names array
    for (uint i = 0; i < proposalNames.length; i++) {
      // push a new Proposal to the 
      // proposal array
      proposals.push(Proposal({
        name: proposalNames[i],
        voteCount: 0
      }));
    }
  }

  // takes a voter's address
  function giveRightToVote(address voter) public {
    // make sure the invoker of the function is a chairperson
    // and voter inside the voters map cannot have voted
    // and the voter's weight must be 0
    require((msg.sender == chairperson) && !voters[voter].voted && (voters[voter].weight == 0));

    // assign the voter's weight to 1 
    voters[voter].weight = 1;
  }

  // delegate voting right
  function delegate(address _to) public {
    // sender is the voter who called
    // this function
    Voter storage sender = voters[msg.sender];
    
    // check that the sender has not voted
    require(!sender.voted);

    // check that the recepient is not the sender
    // (infinite loop)
    require(_to != msg.sender);

    
    while (voters[_to].delegate != address(0)) {
      _to = voters[_to].delegate;
      require(_to != msg.sender);
    }

    sender.voted = true;
    sender.delegate = _to;
    Voter storage delegate = voters[_to];

    if (delegate.voted) {
      proposals[delegate.vote].voteCount += sender.weight;
    } else {
      delegate.weight += sender.weight;
    }
  }

  function vote(uint proposal) public {
    Voter storage sender = voters[msg.sender];

    require(!sender.voted);

    sender.voted = true;
    sender.vote = proposal;

    proposals[proposal].voteCount += sender.weight;
  }

  // @dev 
  function winningProposal() public view returns (uint winningProposal) {
    uint winningVoteCount = 0;

    for (uint p = 0; p < proposals.length; p++) {
      if (proposals[p].voteCount > winningVoteCount) {
        winningVoteCount = proposals[p].voteCount;
        winningProposal = p;
      }
    }
  }

  function winnerName() public view returns (bytes32 winnerName) {
    winnerName = proposals[winningProposal()].name;
  }

}

