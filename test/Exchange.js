const { ethers } = require('hardhat')
const { expect } = require('chai')

const tokens = (n) => {
	return ethers.utils.parseUnits(n.toString(), 'ether')
}

describe("Exchange", () => {
	let deployer, feeAccount

	const feePercent = 10

	beforeEach( async () => {

		accounts = await ethers.getSigners()
		deployer = accounts[0]
		feeAccount = accounts[1]

		const Exchange = await ethers.getContractFactory("Exchange")
		exchange = await Exchange.deploy(feeAccount.address, feePercent)
	})

	describe('Deployment', () => {
		it("tracks fee account", async () => {
			expect(await exchange.feeAccount()).to.equal(feeAccount.address)
		})
	})

	describe('depositing tokens', () => {
		describe('success', () => {
			
		})

		describe('failure', () => {
			
		})
	})
})