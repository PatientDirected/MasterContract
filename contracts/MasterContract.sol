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
		uint[] costIdArray;
		uint[] costListArray;
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
	event Result(address patientAddress, address requestor, bool result, uint[] costIds, uint[] costs);

	/**
	* Contract Constructor
	*/
	function MasterContract() public {}

	/**
	* @dev Function to add patient addresses to patients array
	*
	* @dev Restricted to Owner within MVF scope
	*/
	function addPatient(address patientAddress, address[] requestors, uint[] costIdArray, uint[] costListArray) public onlyOwner {
		require(whitelists[patientAddress].patient == address(0x0));
		patients.push(patientAddress);
		whitelists[patientAddress] = Whitelist(patientAddress, requestors, costIdArray, costListArray);
		buildCostListMapping(patientAddress, costIdArray, costListArray);
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
	function updateWhitelistCosts(address patientAddress, uint[] costIdsArray, uint[] costsArray) public onlyOwner {
		require(whitelists[patientAddress].patient != address(0x0));

		buildCostListMapping(patientAddress, costIdsArray, costsArray);
		whitelists[patientAddress].costIdArray = costIdsArray;
		whitelists[patientAddress].costListArray = costsArray;
	}

	/**
	* @dev Function to create the patient's cost map
	*/
	function buildCostListMapping(address patientAddress, uint[] costIdArray, uint[] costListArray) internal {
		for (uint i = 0; i < costIdArray.length; i++) {
			whitelists[patientAddress].costlist[costIdArray[i]] = costListArray[i];
		}
	}
	
	/**
	* @dev Function to check a Requestor's authorization for a patient
	* @dev Returns result and, if authorized, patient's pricelist
	*/
	function authorizeRequestor(address patientAddress, address requestor) public returns 
	(address patientAddressReturn, address requestorReturn, bool resultReturn, uint[] costIdReturn, uint[] costListReturn) {
		require(whitelists[patientAddress].patient == patientAddress);

		address[] memory requestors = whitelists[patientAddress].requestors;
		bool approved = false;
		uint[] memory costIDs;
		uint[] memory costs;

		for (uint i = 0; i < requestors.length; i++) {
			if (requestors[i] == requestor) {
				approved = true;
				break;
			}
		}

		if (approved == true) {
			costIDs = whitelists[patientAddress].costIdArray;
			costs = whitelists[patientAddress].costListArray;
		}

		Result(patientAddress, requestor, approved, costIDs, costs);
		return (patientAddress, requestor, approved, costIDs, costs);

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
	function getPatientCostIdArray(address patientAddress) public view returns (uint[] costIDArray) {
		require(whitelists[patientAddress].patient == patientAddress);
		return whitelists[patientAddress].costIdArray;
	}

	/**
	* Function to get Cost List Array from struct
	*/
	function getPatientCostListArray(address patientAddress) public view returns (uint[] costlistArray) {
		require(whitelists[patientAddress].patient == patientAddress);
		return whitelists[patientAddress].costListArray;
	}


}