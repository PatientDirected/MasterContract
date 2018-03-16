pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/**
* @title MasterContract
*
* MasterContract MVF for PatientDirected.io
*
* Contract handles approval and cost-listing for 
* patient data requests by authorized requestors
*
*/
contract MasterContract is Ownable {
	
	/**
	* Requestor Whitelist struct
	*/
	struct Whitelist {
		address patient;
		address[] requestors;
		uint[2][] costPairs;
		mapping (uint => uint) costlist;
	}

	/**
	* @dev Map patient address(ID) to whitelist struct
	*/
	mapping (address => Whitelist) public whitelists;

	/**
	* @dev Array of patient addresses
	*/
	address[] public patients;

	/**
	* @dev Event to notify results of transaction
	*/
	event Result(address patientAddress, address requestor, bool result, uint[2][] costpairs);

	/**
	* Contract Constructor
	*/
	function MasterContract() public {}

	/**
	* @dev Function to add patient addresses to patients array
	*
	* @dev Restricted to Owner within MVF scope
	*/
	function addPatient(address patientAddress, address[] requestors, uint[2][] costpairs) public onlyOwner {
		require(whitelists[patientAddress].patient == address(0x0));
		patients.push(patientAddress);
		whitelists[patientAddress] = Whitelist(patientAddress, requestors, costpairs);
		buildCostListMapping(patientAddress, costpairs);
	}

	/**
	* @dev Function to remove patient addresses from patients array and whitelist
	*
	* @dev Restricted to Owner within MVF scope
	*/
	function removePatient(address patientAddress) public onlyOwner {
		require(whitelists[patientAddress].patient != address(0x0));
		uint patientIndex;
		for (uint i = 0; i < patients.length; i++) {
			if (patients[i] == patientAddress) {
				patientIndex == i;
				break;
			}
		}

		patients[patientIndex] = patients[patients.length - 1];
		delete patients[patients.length - 1];
		removePatientWhitelist(patientAddress);

	}

	/**
	* @dev Function to remove patient's whitelist struct
	*/
	function removePatientWhitelist(address patientAddress) internal {
		require(whitelists[patientAddress].patient != address(0x0));
		delete whitelists[patientAddress];
	}

	/**
	* @dev Function to update a patient's requestor whitelist (must provide full array of requestors)
	*/
	function updateWhitelistRequestors(address patientAddress, address[] requestorsArray) public onlyOwner {
		require(whitelists[patientAddress].patient != address(0x0));
		whitelists[patientAddress].requestors = requestorsArray;
	}

	/**
	* @dev Function to update a patient's cost list
	*/
	function updateWhitelistCosts(address patientAddress, uint[2][] costpairs) public onlyOwner {
		require(whitelists[patientAddress].patient != address(0x0));
		buildCostListMapping(patientAddress, costpairs);
		whitelists[patientAddress].costPairs = costpairs;
	}

	/**
	* @dev Function to create the patient's cost map
	*/
	function buildCostListMapping(address patientAddress, uint[2][] costpairs) internal {
		for (uint j = 0; j < costpairs.length; j++) {
			whitelists[patientAddress].costlist[costpairs[j][0]] = costpairs[j][1];
		}
	}
	
	/**
	* @dev Function to check a Requestor's authorization for a patient
	* @dev Returns result and, if authorized, patient's pricelist
	*/
	function authorizeRequestor(address patientAddress, address requestor) public returns 
	(address patientAddressReturn, address requestorReturn, bool resultReturn, uint[2][] costpairs) {
		require(whitelists[patientAddress].patient == patientAddress);

		address[] memory requestors = whitelists[patientAddress].requestors;
		bool approved = false;
		uint[2][] memory costpairArr;

		for (uint i = 0; i < requestors.length; i++) {
			if (requestors[i] == requestor) {
				approved = true;
				break;
			}
		}

		if (approved == true) {
			costpairArr = whitelists[patientAddress].costPairs;
		}

		Result(patientAddress, requestor, approved, costpairArr);
		return (patientAddress, requestor, approved, costpairArr);

	}

	/**
	* 
	* Getter Functions for working with mapped struct
	*
	*/

	/**
	* Function to get Patient ID from struct
	*/
	function getPatientId(address patientAddress) public view returns (address patientAddy) {
		require(whitelists[patientAddress].patient == patientAddress);
		return whitelists[patientAddress].patient;
	}
	
	/**
	* Function to get Requestor Array from struct
	*/
	function getPatientRequestorArray(address patientAddress) public view returns (address[] requestorArray) {
		require(whitelists[patientAddress].patient == patientAddress);
		return whitelists[patientAddress].requestors;
	}

	/**
	* Function to get Cost ID Array from struct
	*/
	// function getPatientCostIdArray(address patientAddress) public view returns (uint[] costIDArray) {
	// 	require(whitelists[patientAddress].patient == patientAddress);
	// 	return whitelists[patientAddress].costIdArray;
	// }

	/**
	* Function to get Cost List Array from struct
	*/
	function getPatientCostListArray(address patientAddress) public view returns (uint[2][] costlistArray) {
		require(whitelists[patientAddress].patient == patientAddress);
		return whitelists[patientAddress].costPairs;
	}


}