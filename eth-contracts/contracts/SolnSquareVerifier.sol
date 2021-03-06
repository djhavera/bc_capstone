pragma solidity >=0.4.21 <0.6.0;

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
import "./Verifier.sol";
import "./ERC721Mintable.sol";
import 'openzeppelin-solidity/contracts/utils/Address.sol';

contract SquareVerifier is Verifier {
}
// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
contract SolnSquareVerifier is CustomERC721Token{
// TODO define a solutions struct that can hold an index & an address
	struct SolutionStruct {
    	uint256 id;
		address solutionAddress;
	}

// TODO define an array of the above struct
SolutionStruct[] solutions;

// TODO define a mapping to store unique solutions submitted
mapping(bytes32 => SolutionStruct) private solutionsMapping;


// TODO Create an event to emit when a solution is added
event solutionAddedEvent(address solutionAddress);
event VerifierChanged(address newVerifier);



// TODO Create a function to add the solutions to the array and emit the event
function addSolutionToArray(address _solutionAddress, uint256 _id, uint[2] memory A, uint[2] memory A_p, uint[2][2] memory B, uint[2] memory B_p, uint[2] memory C, uint[2] memory C_p, uint[2] memory H, uint[2] memory K, uint[2] memory input) public {
	bytes32 key = keccak256(abi.encodePacked(A, A_p, B, B_p, C, C_p, H, K, input));
	require(isDuplicate(key), "Minted Token Already exsits.");
	SolutionStruct memory sol = SolutionStruct({id: _id, solutionAddress: _solutionAddress});
	solutionsMapping[key] = sol;
    solutions.push(sol);
	emit solutionAddedEvent(_solutionAddress);
}
    function isDuplicate(bytes32 key) public view returns (bool){
    	bool isDuplicate = true;
    	if (solutionsMapping[key].solutionAddress != address(0)){
    		isDuplicate = false;
    	}
		return isDuplicate;	
    }
// TODO Create a function to mint new NFT only after the solution has been verified
//  - make sure the solution is unique (has not been used before)
//  - make sure you handle metadata as well as tokenSuplly
	function mintNFT(address _to, 
					uint256 _tokenId, 
					uint[2] memory A, 
					uint[2] memory A_p, 
					uint[2][2] memory B, 
					uint[2] memory B_p, 
					uint[2] memory C, 
					uint[2] memory C_p, 
					uint[2] memory H, 
					uint[2] memory K, 
					uint[2] memory input) public{
		addSolutionToArray(_to, _tokenId, A, A_p, B, B_p, C, C_p, H, K, input);
		super.mint(_to, _tokenId);
    }
}
  















































