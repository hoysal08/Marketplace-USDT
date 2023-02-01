const {expect} = require("chai");
const { ethers,upgrades } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { describe } = require("mocha");
require("@nomicfoundation/hardhat-chai-matchers");
let params=require("../constants/params.json");
const { BigNumber } = require("ethers");




describe("Marketplace",async function() {
      
    
    async function deployFixture(){
        const [account1,account2,account3,owner]=await ethers.getSigners();


        const SampleUSDT=await ethers.getContractFactory("Tether");
        const sampleusdt=await SampleUSDT.deploy();
        await sampleusdt.deployed();
        console.log("USDT deployed at " + sampleusdt.address);


        const SampleOracles=await ethers.getContractFactory("oracle");
        const sampleoracle=await SampleOracles.deploy();
        await sampleoracle.deployed();
        console.log("Oracles deployed at " + sampleoracle.address);


        const Marketplacecontract=await ethers.getContractFactory("Marketplace",owner);
        const marketplace=await upgrades.deployProxy(Marketplacecontract,[sampleusdt.address,sampleoracle.address],{unsafeAllowCustomTypes:true});
        await marketplace.deployed();
        console.log("Marketplace deployed at "+ marketplace.address);

        return {account1,account2,account3,owner,sampleoracle,sampleusdt,marketplace};
    }
    async function deployFixtureItemadded(){
        const [account1,account2,account3,owner]=await ethers.getSigners();


        const SampleUSDT=await ethers.getContractFactory("Tether");
        const sampleusdt=await SampleUSDT.deploy();
        await sampleusdt.deployed();
        console.log("USDT deployed at " + sampleusdt.address);


        const SampleOracles=await ethers.getContractFactory("oracle");
        const sampleoracle=await SampleOracles.deploy();
        await sampleoracle.deployed();
        console.log("Oracles deployed at " + sampleoracle.address);


        const Marketplacecontract=await ethers.getContractFactory("Marketplace",owner);
        const marketplace=await upgrades.deployProxy(Marketplacecontract,[sampleusdt.address,sampleoracle.address],{unsafeAllowCustomTypes:true});
        await marketplace.deployed();
        console.log("Marketplace deployed at "+ marketplace.address);

        let sampleitem1={...params.sampleitem1};
        sampleitem1.price=ethers.utils.parseEther(sampleitem1.price);
        sampleitem1.shippingprice=ethers.utils.parseEther(sampleitem1.shippingprice);
       
        await marketplace.connect(account1).addItem(sampleitem1.id,sampleitem1.name,sampleitem1.price,sampleitem1.shippingprice);

        return {account1,account2,account3,owner,sampleoracle,sampleusdt,marketplace,sampleitem1};
    }

    describe("Check for valid initialisation",async function(){
        it("should be refering to correct usdt and oracle address",async function(){
            const{sampleoracle,sampleusdt,marketplace}=await loadFixture(deployFixture);

            expect(await marketplace.oracle()).to.be.equal(sampleoracle.address);
            expect(await marketplace.usdt()).to.be.equal(sampleusdt.address);
        })
        it("should not allow to call initialize function more than once",async function(){
            const{sampleoracle,sampleusdt,marketplace}=await loadFixture(deployFixture);

            await expect( marketplace.initialize(sampleusdt.address,sampleoracle.address)).to.be.revertedWith("Initializable: contract is already initialized");
        })
    })

    describe("Check for add items on marketplace",async function(){
        it("should be able add new items with shipping price",async function(){
            const{sampleoracle,sampleusdt,marketplace,account1,sampleitem1}=await loadFixture(deployFixtureItemadded);


            let item=await marketplace.items(sampleitem1.id);
           

            expect(item.price).to.be.equal(sampleitem1.price);
            expect(item.name).to.be.equal(sampleitem1.name);
            expect(item.owner).to.be.equal(account1.address);
            expect(item.exists).to.be.equal(true);
            expect(await marketplace.shippingPrices(sampleitem1.id)).to.be.equal(0);
        })

        it("should be able to update shipping prices", async function() {
            const{sampleoracle,sampleusdt,marketplace,account1,sampleitem1}=await loadFixture(deployFixtureItemadded);
   

            let updatedshippingprice=params.updatedshippingprice
            updatedshippingprice=ethers.utils.parseEther(updatedshippingprice)
           
            await marketplace.connect(account1).addShippingPrices(sampleitem1.id,updatedshippingprice);

            let item=await marketplace.items(sampleitem1.id);
           

            expect(item.price).to.be.equal(sampleitem1.price);
            expect(item.name).to.be.equal(sampleitem1.name);
            expect(item.owner).to.be.equal(account1.address);
            expect(item.exists).to.be.equal(true);
            expect(await marketplace.shippingPrices(sampleitem1.id)).to.be.equal(updatedshippingprice);
        })

        it("should not  be able add new items with same Id",async function(){
            const{sampleoracle,sampleusdt,marketplace,account1,sampleitem1}=await loadFixture(deployFixtureItemadded);

            await expect ( marketplace.connect(account1).addItem(sampleitem1.id,sampleitem1.name,sampleitem1.price,sampleitem1.shippingprice)).to.be.revertedWith("Id already exists");            
        })
    })

    describe("check for buy related features",async function(){
       
        it("should allow users to reserve and buy",async function(){
            const{sampleoracle,sampleusdt,marketplace,account1,sampleitem1,account2}=await loadFixture(deployFixtureItemadded);

           let genHash=await marketplace.connect(account2).generatehash(1);
           await marketplace.connect(account2).reserve(genHash);

           //to assume account2 holds USDT
           await sampleusdt.connect(account1).transfer(account2.address,2000*10**6);

           let item=await marketplace.items(sampleitem1.id);
           await sampleusdt.connect(account2).approve(marketplace.address,item.price);

           await marketplace.connect(account2).buyItem(sampleitem1.id);

           let updateditem=await marketplace.items(sampleitem1.id);

           expect(updateditem.owner).to.be.equal(account2.address);
        })

        it("should not allow users to buy without  reserving ",async function(){
            const{sampleoracle,sampleusdt,marketplace,account1,sampleitem1,account2}=await loadFixture(deployFixtureItemadded);

           //to assume account2 holds USDT
           await sampleusdt.connect(account1).transfer(account2.address,2000*10**6);

           let item=await marketplace.items(sampleitem1.id);
           await sampleusdt.connect(account2).approve(marketplace.address,item.price);

           await expect (marketplace.connect(account2).buyItem(sampleitem1.id)).to.be.revertedWith("Please reserve item before purchase");
        })

      
    })
})
   