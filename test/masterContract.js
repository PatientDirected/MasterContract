const MasterContract = artifacts.require('./MasterContract.sol');

contract('MasterContract', async (accounts) => {

	it('should deploy', async() => {
		let instance = await MasterContract.new();
		let owneraddy = await instance.owner.call();
		console.log(owneraddy);
		assert.notEqual(instance.address, 0x0);
	})

	it('should add a patient', async() => {
		let instance = await MasterContract.new();
		let addPax = await instance.addPatient(accounts[0], [accounts[1]], [[0,1],[1,2]]);
		let pax = await instance.whitelists.call(accounts[0]);
		assert.equal(pax, accounts[0]);
	})

	it('should delete a patient', async() => {
		let instance = await MasterContract.new();
		let addPax = await instance.addPatient(accounts[0], [accounts[1]], [[0,1],[1,2]]);
		let pax = await instance.whitelists.call(accounts[0]);
		assert.equal(pax, accounts[0]);

		let delPax = await instance.removePatient(accounts[0]);
		let deletedPax = await instance.whitelists.call(accounts[0]);
		assert.equal(deletedPax, 0x0);
	})

	it('should update a requestor list', async() => {
		let instance = await MasterContract.new();
		let addPax = await instance.addPatient(accounts[0], [accounts[1]], [[0,1],[1,2]]);
		let pax = await instance.whitelists.call(accounts[0]);
		assert.equal(pax, accounts[0]);

		let reqList = await instance.getPatientRequestorArray(accounts[0]);
		assert.equal(reqList[0], accounts[1]);
		
		let updatePaxReq = await instance.updateWhitelistRequestors(accounts[0], [accounts[2]]);
		let updatedReqList = await instance.getPatientRequestorArray(accounts[0]);
		assert.equal(updatedReqList[0], accounts[2]);

	})

	it('should update a cost list', async() => {
		let instance = await MasterContract.new();
		let addPax = await instance.addPatient(accounts[0], [accounts[1]], [[0,1]]);
		let pax = await instance.whitelists.call(accounts[0]);
		assert.equal(pax, accounts[0]);

		let costList = await instance.getPatientCostListArray(accounts[0]);
		assert.equal(costList[0][1], 1);

		let updatePaxCost = await instance.updateWhitelistCosts(accounts[0], [[1,2]]);
		let updatedCostList = await instance.getPatientCostListArray(accounts[0]);
		assert.equal(updatedCostList[0][1], 2);
	})

	it('should approve a whitelisted requestor', async() => {
		let instance = await MasterContract.new();
		let addPax = await instance.addPatient(accounts[0], [accounts[1]], [[0,1],[1,2]]);
		let pax = await instance.whitelists.call(accounts[0]);
		assert.equal(pax, accounts[0]);

		let approval = await instance.authorizeRequestor(accounts[0], accounts[1]);

		assert.equal(approval.logs[0].args.patientAddress, accounts[0]);
		assert.equal(approval.logs[0].args.requestor, accounts[1]);
		assert.equal(approval.logs[0].args.result, true);
		assert.equal(approval.logs[0].args.costpairs[0][1], 1);
		assert.equal(approval.logs[0].args.costpairs[1][1], 2);
	})

	it('should not approve a non-whitelisted requestor', async() => {
		let instance = await MasterContract.new();
		let addPax = await instance.addPatient(accounts[0], [accounts[1]], [[0,1],[1,2]]);
		let pax = await instance.whitelists.call(accounts[0]);
		assert.equal(pax, accounts[0]);

		let approval = await instance.authorizeRequestor(accounts[0], accounts[2]);
		assert.equal(approval.logs[0].args.patientAddress, accounts[0]);
		assert.equal(approval.logs[0].args.requestor, accounts[2]);
		assert.equal(approval.logs[0].args.result, false);
		assert.equal(approval.logs[0].args.costpairs[0], undefined);
		assert.equal(approval.logs[0].args.costpairs[1], undefined);
	})
})