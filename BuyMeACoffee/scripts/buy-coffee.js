// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

// deployed at 0x340A45c4bf8C41b267232c125B92E2694A3920B0

// Returns ether balance of a given address
async function getBalance(address) {
    const balanceBigInt = await hre.ethers.provider.getBalance(address);
    return hre.ethers.utils.formatEther(balanceBigInt);
}

// Logs the Ether balances for a list of addresses
async function printBalances(addresses) {
    let idx = 0;
    for (const address of addresses) {
        console.log(`Address ${idx} ${address} balance: `, await getBalance(address));
        ++idx;
    }
}

// logs the memos stored on-chain from coffee purchasers
async function printMemos(memos) {
    for (const memo of memos) {
        const timestamp = memo.timestamp;
        const tipper = memo.name;
        const tipperAddress = memo.address;
        const message = memo.message;
        console.log(`At ${timestamp}, ${tipper} (${tipperAddress}) said: "${message}"`);
    }
}

async function main() {
    // get example accounts
    const [owner, tipper, tipper2, tipper3] = await hre.ethers.getSigners();

    // get the contract to deploy
    const BuyMeACoffee = await hre.ethers.getContractFactory("BuyMeACoffee");
    const buyMeACoffee = await BuyMeACoffee.deploy()
    await buyMeACoffee.deployed();
    console.log("BuyMeACoffee deployed to ", buyMeACoffee.address);

    // check balances before the coffee purchases
    const addresses = [owner.address, tipper.address, tipper2.address, tipper3.address, buyMeACoffee.address];
    console.log("== Start ==");
    await printBalances(addresses);

    // Buy the owner a few coffees
    const tip = {value: hre.ethers.utils.parseEther("1")};
    await buyMeACoffee.connect(tipper).buyCoffee("Vishal", "I love the content", tip);
    await buyMeACoffee.connect(tipper2).buyCoffee("Ashish", "Excellent course.", tip);
    await buyMeACoffee.connect(tipper3).buyCoffee("Austin", "You are amazing.", tip);

    // check balances after the coffee purchases
    console.log("== bought coffee ==");
    await printBalances(addresses);

    // withdraw funds
    await buyMeACoffee.connect(owner).withDrawTips();

    // check balances after withdraw
    console.log("== withdraw tips ==");
    await printBalances(addresses);

    // read all the memos left for the owner.
    console.log("== memos ==");
    const memos = await buyMeACoffee.getMemos();
    printMemos(memos);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
