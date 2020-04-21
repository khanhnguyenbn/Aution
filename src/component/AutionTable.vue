<template>
  <div class="container">
    <button v-on:click="testEvent()"></button>
    <table>
      <thead>
        <tr>
          <th>id</th>
          <th>Titile</th>
          <th>Start Price</th>
          <th>Highest Price</th>
          <th>State</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="aution in autionList" :key="aution.id">
          <td>{{aution.id}}</td>
          <td><router-link :to="{ name: 'aution-detail', params: { autionId: aution.id}}">{{aution.title}}</router-link></td>
          <td>{{aution.startPrice}}</td>
          <td>{{aution.highestPrice}}</td>
          <td>{{aution.state}}</td>
        </tr>
      </tbody>
    </table>

    <div class="b-row">
      <div>
        <h1>
          Aution
          <span>#{{ amount }}</span>
        </h1>
        <hr />
        <div>
          <label for="title">Title</label>
          <b-form-input id="title" v-model="title" type="text" placeholder="title" />
        </div>
        <div>
          <label for="startPrice">startPrice</label>
          <b-form-input
            id="startPrice"
            v-model="startPrice"
            type="text"
            placeholder="start price ETH"
          />
        </div>
      </div>
    </div>
    <div class="b-row">
      <div>
        <label for="Description">Description</label>
        <br />
        <b-form-textarea id="Description" v-model="description" rows="5" />
      </div>
    </div>
    <hr />
    <div class="b-row">
      <div>
        <b-button :variant="'primary'" @click="createAuction">{{ createStatus }}</b-button>
        <img v-show="isLoad" src="https://media.giphy.com/media/2A6xoqXc9qML9gzBUE/giphy.gif" />
      </div>
    </div>
    <div v-show="isShow">
      <hr />
      <b-card-group columns class="mb-3">
        <b-card
          :title="auctionCard[1]"
          :sub-title="'Start Price:' + auctionCard[2] + 'ETH' + ', Highest Price: ' + auctionCard[3]"
          tag="article"
          style="max-width: 20rem;"
          class="mb-2"
        >
          <hr />
          <p class="card-text, mt-3">{{ auctionCardDev[2] }}</p>
          <p class="card-text, mt-3">Bidders: {{ bidders }}</p>
          <div>
            <form @submit.prevent="handleSubmit()">
              <b-input-group>
                <b-form-input v-model="bidPrice" />
                <b-input-group-append>
                  <button>place BID</button>
                  <img
                    v-show="isBid"
                    id="isBid"
                    src="https://media.giphy.com/media/2A6xoqXc9qML9gzBUE/giphy.gif"
                  />
                </b-input-group-append>
              </b-input-group>
            </form>
          </div>
          <b-button
            class="mt-3"
            variant="outline-success"
            @click="handleFinalize()"
          >{{ finalizeStatus }}</b-button>
          <img
            v-show="isFin"
            id="isFin"
            src="https://media.giphy.com/media/2A6xoqXc9qML9gzBUE/giphy.gif"
          />
        </b-card>
      </b-card-group>
    </div>
  </div>
</template>

<script>
import web3 from "../../contracts/web3";
import auction from "../../contracts/auctionInstance";
import auctionBox from "../../contracts/auctionBoxInstance";

export default {
  name: "aution-table",
  data() {
    return {
      title: "",
      startPrice: "",
      highestPrice: 0,
      description: "",
      amount: 0,
      auctionCard: [],
      autionList: [],
      auctionCardDev: [],
      isShow: false,
      isLoad: false,
      isBid: false,
      isFin: false,
      bidPrice: "",
      auctionAddress: "",
      bidders: 0,
      finalizeStatus: "Finalize auctioin",
      createStatus: "CREATE"
    };
  },
  beforeMount() {
    // get auctionBox method: returnAllAuctions()
    auctionBox.methods
      .returnAllAuctions()
      .call()
      .then(auctions => {
        console.log(auctions);
        // set the amount of auctions
        this.amount = auctions.length;

        // const listAutions = new Array();
        for (let index = 0; index < auctions.length; index++) {
          auction(auctions[index])
            .methods.returnContents()
            .call()
            .then(list => {
              var autionInfo = {
                id: "",
                title: "",
                startPrice: "",
                highestPrice: "",
                state: ""
              };
              autionInfo.id = list[0];
              autionInfo.title = list[1];
              autionInfo.startPrice = web3.utils.fromWei(list[2], "ether");
              autionInfo.highestPrice = web3.utils.fromWei(list[3], "ether");
              autionInfo.state = list[5];
              this.autionList.push(autionInfo);
            });
        }
      });
  },
  methods: {
    createAuction() {
      // get accounts
      web3.eth
        .getAccounts()
        .then(accounts => {
          // convert 'ether' to 'wei'
          const startPrice = web3.utils.toWei(this.startPrice, "ether");
          // createAuction in AuctionBox contract
          this.isLoad = true;
          return auctionBox.methods
            .createAuction(this.title, startPrice, this.description)
            .send({ from: accounts[0] });
        })
        .then(() => {
          // initialize forms
          this.isLoad = false;
          this.title = "";
          this.startPrice = "";
          this.description = "";
          // get the previous auction
          return auctionBox.methods.returnAllAuctions().call();
        })
        .then(auctions => {
          const index = auctions.length - 1;
          console.log(auctions[index]);
          // get the contract address of the previous auction
          this.auctionAddress = auctions[index];
          // set the address as the parameter
          const auctionInstance = auction(auctions[index]);
          return auctionInstance.methods.returnContents().call();
        })
        .then(lists => {
          // console.log("list is: " + lists);
          // for (let index = 0; index < lists.length; index++) {
          //   console.log(lists[index]);

          // }

          const auctionlists = lists;
          // convert 'wei' to 'ether'
          auctionlists[2] = web3.utils.fromWei(auctionlists[2], "ether");
          auctionlists[3] = web3.utils.fromWei(auctionlists[3], "ether");
          this.auctionCard = auctionlists;
          // show up the auction at the bottom of the page
          this.isShow = true;
          this.amount += 1;

          var autionInfo = { id: "", title: "", startPrice: "" };
          autionInfo.id = index;
          autionInfo.title = list[0];
          autionInfo.startPrice = list[1];
          this.autionList.push(autionInfo);
        })
        .catch(err => {
          console.log(err);
        });
    },
    handleSubmit() {
      // convert 'ether' to 'wei'
      const bidPriceWei = web3.utils.toWei(this.bidPrice, "ether");
      // get the wallet adddress
      const fromAddress = web3.eth.accounts.givenProvider.selectedAddress;
      // set the address as the parameter
      const selectedAuction = auction(this.auctionAddress);
      this.isBid = true;
      // placeBid in Auction contract
      selectedAuction.methods
        .placeBid()
        .send({
          from: fromAddress,
          value: bidPriceWei
        })
        .then(() => {
          this.isBid = false;
          // increase the number of bidders
          this.bidders += 1;
          this.bidPrice = "";
          return auction(this.auctionAddress)
            .methods.getHighestPrice()
            .call();
        })
        .then(a => {
          this.highestPrice = web3.utils.fromWei(a, "ether");
        });
    },
    handleFinalize() {
      // get accounts
      web3.eth.getAccounts().then(accounts => {
        // set the address as the parameter
        const selectedAuction = auction(this.auctionAddress);
        this.isFin = true;
        // finalizeAuction in Auction contract
        selectedAuction.methods
          .finalizeAuction()
          .send({ from: accounts[0] })
          .then(() => {
            this.isFin = false;
            this.finalizeStatus = "finalized";
          });
      });
    }
  }
};
</script>

<style scoped>
#app {
  font-family: "Avenir", Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

h1,
h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}

button {
  background-color: #008cba;
  color: white;
}

button:hover {
  background-color: white; /* Green */
  color: #008cba;
  border: #008cba 3px solid;
}

img {
  width: 32px;
}

#isBid,
#isFin {
  height: 32px;
  margin-top: 16px;
  margin-left: 8px;
}
</style>