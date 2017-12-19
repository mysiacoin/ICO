/* version metahash ERC20 multi sign wallet 0.1.3 RC */
pragma solidity ^0.4.18;

interface token {
	function transfer(address recipient, uint amount) public returns (bool);
}

contract mhethkeeper {

	/* contract settings */
	token public tokenToTrans;		/* token */
	address public recipient;		/* recipient */
	uint256 public count;			/* quantity */

	uint public isFinalyze;			/* settings are finalized */
	address public owner;			/* contract creator */

	/* arrays */
	mapping (address => bool) public ownersAgree;
	mapping (uint => address) public ownersIndex;

	function mhethkeeper() public{
		owner = msg.sender;
		isFinalyze = 0;
	}

	function SetupContract(address _owner1, address _owner2, address _owner3, address _tokenToTrans) public {
		if ((msg.sender == owner) && (isFinalyze == 0)){
			/* set owners */
			ownersIndex[1] = _owner1;
			ownersIndex[2] = _owner2;
			ownersIndex[3] = _owner3;
			
			/* set vote */
			ownersAgree[_owner1] = false;
			ownersAgree[_owner2] = false;
			ownersAgree[_owner3] = false;       

			/* set token */
			tokenToTrans = token(_tokenToTrans);
		} else {
			revert();
		}
	}

	/* finalyze settings */
	function finalyze() public {
		if ((msg.sender == owner) && (isFinalyze == 0)){
			isFinalyze = 1;
		} else {
			revert();
		}
	}

	/* set new action and set to zero vote */
	function SetAction(address _recipient, uint256 _count) public {
		if ((IsOwner(msg.sender)) && (isFinalyze == 1)){ 
			recipient = _recipient;
			count = _count;
			for (uint i = 1; i <= 3; i++) {
				address nOwner = ownersIndex[i];
				ownersAgree[nOwner] = false;
			}
		} else {
			revert();
		}
	}

	/* manager votes for the action */
	function Approve(address _recipient, uint256 _count) public {
		if (IsOwner(msg.sender) && (isFinalyze == 1)){
			if ((recipient == _recipient) && (count == _count)){
				ownersAgree[msg.sender] = true;
			} else {
				revert();
			}
		} else {
			revert();
		}

		uint nAgree = 0;
		for (uint i = 1; i <= 3; i++) {
			address nOwner = ownersIndex[i];
			if (ownersAgree[nOwner] == true){
				nAgree = nAgree + 1;
			}
		}

		if (nAgree >= 2){
			if (!tokenToTrans.transfer(recipient,count)){
				revert();
			} else {
				NullSettings();
			}
		}
	}

	/* set default payable function */
	function () payable public {}

	/* clean up vote settings */
	function NullSettings() private {
		recipient = address(0x0);
		count = 0;
		for (uint i = 1; i <= 3; i++) {
			address nOwner = ownersIndex[i];
			ownersAgree[nOwner] = false;
		}
	}

	/* check adress */
	function IsOwner(address _sender) private view returns(bool){
		if ((_sender == ownersIndex[1]) || (_sender == ownersIndex[2]) || (_sender == ownersIndex[3])){
			return true;
		} else {
			return false;
		}
	}
}
