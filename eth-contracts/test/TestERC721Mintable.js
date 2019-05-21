var ERC721Token = artifacts.require("CustomERC721Token");

contract('ERC721Token', accounts => {

    const account_one = accounts[0];
    const account_two = accounts[1];

    describe('match erc721 spec', function () {
        beforeEach(async function () { 
            this.contract = await ERC721Token.new({from: account_one});


                   // TODO: mint multiple tokens
            await this.contract.mint(account_one, 1);
            await this.contract.mint(account_one, 2);
            await this.contract.mint(account_one, 3);     
        })

        it('should return total supply', async function () { 
            let result = await this.contract.totalSupply();
            console.log(result.toString())
            assert.equal(result, 3, "3 tokens should have been minted.");
            
        })

        it('should get token balance', async function () { 
            let varBalance = await this.contract.balanceOf(account_one);
            assert.equal(varBalance, 3, "Incorrect number of account_one token balance.");
            
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('should return token uri', async function () { 
                let resultTokenUri = await this.contract.tokenURI(1);
                assert.equal(resultTokenUri, "https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1", "TokenUri Not Found")  
            
        })

        it('should transfer token from one owner to another', async function () { 
            let result = await this.contract.transferFrom(account_one, account_two, 2);
            let owner = await this.contract.ownerOf(2);
            assert.equal(owner, account_two, "Owner did not change");
        })

        it('FAIL when NOT contract owner', async function () { 
            let reverted = false;
            try{
               let resultMinted = await this.contract.mint(account_one, 4, "baseURI4", {from: account_two}); 
            } catch (e) {
                reverted = true;
            }
            assert.equal(reverted, true, "Could not mint");
        })

        it('Returns contract owner', async function () { 
            let result = await this.contract.ownerOf(1,{from: account_one}); 
            assert.equal(result, account_one, "The owner was not returned.");
            
        })

    });
    
})