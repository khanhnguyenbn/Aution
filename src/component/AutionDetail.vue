<template>
  <div class="container">
    <div class="card">
      <div class="container-fliud">
        <div class="wrapper row">
          <div class="preview col-md-6">
            <div class="preview-pic tab-content">
              <div class="tab-pane active" id="pic-1">
                <img src="http://placekitten.com/400/252" />
              </div>
              <div class="tab-pane" id="pic-2">
                <img src="http://placekitten.com/400/252" />
              </div>
              <div class="tab-pane" id="pic-3">
                <img src="http://placekitten.com/400/252" />
              </div>
              <div class="tab-pane" id="pic-4">
                <img src="http://placekitten.com/400/252" />
              </div>
              <div class="tab-pane" id="pic-5">
                <img src="http://placekitten.com/400/252" />
              </div>
            </div>
            <!-- <ul class="preview-thumbnail nav nav-tabs">
              <li class="active">
                <a data-target="#pic-1" data-toggle="tab">
                  <img src="http://placekitten.com/200/126" />
                </a>
              </li>
              <li>
                <a data-target="#pic-2" data-toggle="tab">
                  <img src="http://placekitten.com/200/126" />
                </a>
              </li>
              <li>
                <a data-target="#pic-3" data-toggle="tab">
                  <img src="http://placekitten.com/200/126" />
                </a>
              </li>
              <li>
                <a data-target="#pic-4" data-toggle="tab">
                  <img src="http://placekitten.com/200/126" />
                </a>
              </li>
              <li>
                <a data-target="#pic-5" data-toggle="tab">
                  <img src="http://placekitten.com/200/126" />
                </a>
              </li>
            </ul>-->
          </div>
          <div class="details col-md-6">
            <h3 class="product-title">{{title}}</h3>
            <div class="rating">
              <div class="stars">
                <span class="fa fa-star checked"></span>
                <span class="fa fa-star checked"></span>
                <span class="fa fa-star checked"></span>
                <span class="fa fa-star"></span>
                <span class="fa fa-star"></span>
              </div>
              <span class="review-no">end-date: {{endDate}}</span>
            </div>
            <p class="product-description">{{description}}</p>
            <h4 class="price">
              Start Price:
              <span>{{startPrice}} ETH</span>
            </h4>
            <h4 class="price">
              Highest Price:
              <span>{{highestPrice}} ETH</span>
            </h4>
            <h6>
              <b>STATE OF AUCTION: {{auctionState}}</b>
            </h6>
            <h6 v-if="auctionState != 'RUNNING'">WINNER: {{winner}}</h6>
            <!-- <p class="vote"><strong>91%</strong> of buyers enjoyed this product! <strong>(87 votes)</strong></p> -->
            <!-- <h5 class="sizes">sizes:
							<span class="size" data-toggle="tooltip" title="small">s</span>
							<span class="size" data-toggle="tooltip" title="medium">m</span>
							<span class="size" data-toggle="tooltip" title="large">l</span>
							<span class="size" data-toggle="tooltip" title="xtra large">xl</span>
            </h5>-->
            <!-- <h5 class="colors">colors:
							<span class="color orange not-available" data-toggle="tooltip" title="Not In store"></span>
							<span class="color green"></span>
							<span class="color blue"></span>
            </h5>-->
            <div class="action">
              <button
                v-if="isAllowDeposit"
                class="add-to-cart btn btn-default"
                type="button"
                @click="handleJoin()"
              >Join</button>
              <button
                v-if="isAllowBid"
                class="add-to-cart btn btn-default"
                type="button"
                v-b-modal.modal-prevent-closing
              >BID</button>

              <button
                v-if="isAllowWinnerTransferMoney"
                class="add-to-cart btn btn-default"
                type="button"
                @click="handleWinnerTransferMoney()"
              >Transfer Money</button>

              <button
                v-if="isAllowFinalize"
                class="add-to-cart btn btn-default"
                type="button"
                @click="handleFinalize()"
              >Finalize</button>
              <button
                v-if="isAllowRefunForFailBidder"
                class="add-to-cart btn btn-default"
                type="button"
                @click="handleRefunCauseOverTime()"
              >Refun cause overtime</button>
            </div>

            <div v-if="isAllowWinnerDoAfter">
              <b>FOR WINNER:</b>
              <button type="button" @click="handleReceived()">RECEIVED</button>
              <button type="button" @click="handleCanotReceive()">CAN'T RECEIVE</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <b-modal id="modal-prevent-closing" ref="modal" title="Bid Your ETH" @ok="handleSubmit">
      <form ref="form" @submit.stop.prevent="handleSubmit">
        <b-form-group label="ETH" label-for="eth-input" invalid-feedback="Your ETH is required">
          <b-form-input id="eth-input" v-model="bidPrice" required></b-form-input>
        </b-form-group>
      </form>
    </b-modal>

    <div class="row" style="margin-top: 20px">
      <div class="col-sm-3">
        <h2>Your Bid History</h2>
        <table>
          <thead>
            <tr>
              <th>STT</th>
              <th>AMOUNT (ETH)</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="bidHistory in bidsHistory" :key="bidHistory.id">
              <td>{{bidHistory.id}}</td>
              <td>{{bidHistory.amount}}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="col-sm-9 text-center">
        <h3>Owner Information</h3>
        <h6>Name: {{ownerName}}</h6>
        <h6>Phone number: {{ownerPhoneNumber}}</h6>
        <h6>Address: {{ownerAddress}}</h6>
      </div>
    </div>
  </div>
</template>

<script>
import web3 from "../../contracts/web3";
import auction from "../../contracts/auctionInstance";
import auctionBox from "../../contracts/auctionBoxInstance";
import TimeConverterUtil from "../Utils/TimeConverterUtil";
import AuctionUtil from "../Utils/AuctionUtil";

export default {
  name: "AutionDetail",
  data() {
    return {
      id: Number,
      title: "",
      startPrice: Number,
      highestPrice: Number,
      description: "",
      auctionState: "",
      ownerName: "",
      ownerPhoneNumber: "",
      ownerAddress: "",
      endDate: "",
      bidPrice: "",
      auctionAddress: "",
      bidsHistory: [],
      winner: "",
      amountOfDeposit: "2",

      isAllowDeposit: false,
      isAllowBid: false,
      isAllowFinalize: false,
      isAllowWinnerTransferMoney: false,
      isAllowWinnerDoAfter: false,
      isAllowRefunForFailBidder: false
    };
  },
  beforeMount() {
    auctionBox.methods
      .getAuctionById(this.$route.params.autionId)
      .call()
      .then(aution => {
        console.log("aution: " + aution);
        this.auctionAddress = aution;
        this.getBidsHistory(aution);

        // auction(aution)
        //   .methods.getLengthOfBidList()
        //   .call()
        //   .then(len => {
        //     console.log("len is " + len);
        //   });

        auction(aution)
          .methods.returnContents()
          .call()
          .then(list => {
            this.id = list[0];
            this.title = list[1];
            this.startPrice = web3.utils.fromWei(list[2], "ether");
            this.highestPrice = web3.utils.fromWei(list[3], "ether");
            this.description = list[4];
            this.auctionState = AuctionUtil.getStringState(Number(list[5]));
            let ownerInfoList = list[6];
            this.ownerName = ownerInfoList[0];
            this.ownerPhoneNumber = ownerInfoList[1];
            this.ownerAddress = ownerInfoList[2];

            this.endDate = TimeConverterUtil.toString(Number(list[8]));
          });

        auction(aution)
          .methods.getWinner()
          .call()
          .then(winner => {
            this.winner = winner;
            console.log("winner: " + winner);
          });

        auction(aution)
          .methods.isAllowDeposit(
            web3.eth.accounts.givenProvider.selectedAddress,
            new Date().getTime()
          )
          .call()
          .then(isAllow => {
            this.isAllowDeposit = isAllow;
            console.log("isAllowDeposit: " + isAllow);
          });

        auction(aution)
          .methods.isAllowBid(
            web3.eth.accounts.givenProvider.selectedAddress,
            new Date().getTime()
          )
          .call()
          .then(isAllow => {
            this.isAllowBid = isAllow;
            console.log("isAllowBid: " + isAllow);
          });

        auction(aution)
          .methods.isAllowFinalize(
            web3.eth.accounts.givenProvider.selectedAddress
          )
          .call()
          .then(isAllow => {
            this.isAllowFinalize = isAllow;
            console.log("isAllowFinalize: " + isAllow);
          });

        auction(aution)
          .methods.isAllowWinnerTransferMoney(
            web3.eth.accounts.givenProvider.selectedAddress
          )
          .call()
          .then(isAllow => {
            this.isAllowWinnerTransferMoney = isAllow;
            console.log("isAllowWinnerTransferMoney: " + isAllow);
          });

        auction(aution)
          .methods.isAllowWinnerDoAfter(
            web3.eth.accounts.givenProvider.selectedAddress
          )
          .call()
          .then(isAllow => {
            this.isAllowWinnerDoAfter = isAllow;
            console.log("isAllowWinnerDoAfter: " + isAllow);
          });

        auction(aution)
          .methods.isAllowRefun(
            web3.eth.accounts.givenProvider.selectedAddress,
            new Date().getTime()
          )
          .call()
          .then(isAllow => {
            this.isAllowRefunForFailBidder = isAllow;
            console.log("isAllowRefunForFailBidder: " + isAllow);
          });
      });
  },
  updated(){

    

  },
  methods: {
    handleSubmit() {
      // convert 'ether' to 'wei'
      const bidPriceWei = web3.utils.toWei(this.bidPrice, "ether");

      console.log("bidPriceWei: " + bidPriceWei);
      // get the wallet adddress
      const fromAddress = web3.eth.accounts.givenProvider.selectedAddress;

      console.log("fromAddress: " + fromAddress);
      // set the address as the parameter
      const selectedAuction = auction(this.auctionAddress);

      console.log("auctionAddress" + this.auctionAddress);

      console.log("selectedAuction: " + selectedAuction);
      // placeBid in Auction contract
      selectedAuction.methods
        .placeBid(bidPriceWei)
        .send({
          from: fromAddress
        })
        .then(() => {
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
        console.log("accounts[0]" + accounts[0]);
        console.log(
          "given: " + web3.eth.accounts.givenProvider.selectedAddress
        );
        // set the address as the parameter
        const selectedAuction = auction(this.auctionAddress);
        // finalizeAuction in Auction contract
        selectedAuction.methods
          .finalizeAuction()
          .send({ from: accounts[0] })
          .then(() => {
            // this.isFin = false;
            // this.finalizeStatus = "finalized";
          });
      });
    },
    getBidsHistory(addressOfAution) {
      auction(addressOfAution)
        .methods.getBidHistoryByAdress(
          web3.eth.accounts.givenProvider.selectedAddress
        )
        .call()
        .then(listHistory => {
          for (let index = 0; index < listHistory.length; index++) {
            console.log("listHistory: " + listHistory[index]);
            const bidHistoryObject = { id: "", amount: "" };
            bidHistoryObject.id = index;
            bidHistoryObject.amount = web3.utils.fromWei(
              listHistory[index],
              "ether"
            );
            this.bidsHistory.push(bidHistoryObject);
          }
        });
    },
    handleReceived() {
      web3.eth.getAccounts().then(accounts => {
        console.log("accounts[0]" + accounts[0]);
        console.log(
          "given: " + web3.eth.accounts.givenProvider.selectedAddress
        );
        // set the address as the parameter
        const selectedAuction = auction(this.auctionAddress);
        // finalizeAuction in Auction contract
        selectedAuction.methods
          .sendToOwner()
          .send({ from: accounts[0] })
          .then(() => {
            // this.isFin = false;
            // this.finalizeStatus = "finalized";
          });
      });

    },
    handleCanotReceive() {
      web3.eth.getAccounts().then(accounts => {
        console.log("accounts[0]" + accounts[0]);
        console.log(
          "given: " + web3.eth.accounts.givenProvider.selectedAddress
        );
        // set the address as the parameter
        const selectedAuction = auction(this.auctionAddress);
        // finalizeAuction in Auction contract
        selectedAuction.methods
          .refunForHighestBidder()
          .send({ from: accounts[0] })
          .then(() => {
            // this.isFin = false;
            // this.finalizeStatus = "finalized";
          });
      });
    },
    handleRefunCauseOverTime() {
      web3.eth.getAccounts().then(accounts => {
        console.log("accounts[0]" + accounts[0]);
        console.log(
          "given: " + web3.eth.accounts.givenProvider.selectedAddress
        );
        // set the address as the parameter
        const selectedAuction = auction(this.auctionAddress);
        // finalizeAuction in Auction contract
        selectedAuction.methods
          .refunForFaileBidder(new Date().getTime())
          .send({ from: accounts[0] })
          .then(() => {
            // this.isFin = false;
            // this.finalizeStatus = "finalized";
          });
      });
    },
    handleJoin() {
      web3.eth.getAccounts().then(accounts => {
        console.log("accounts[0]" + accounts[0]);
        console.log(
          "given: " + web3.eth.accounts.givenProvider.selectedAddress
        );
        // set the address as the parameter
        const selectedAuction = auction(this.auctionAddress);
        const amount = web3.utils.toWei(this.amountOfDeposit, "ether");
        // finalizeAuction in Auction contract
        selectedAuction.methods
          .payDeposit()
          .send({
            from: accounts[0],
            value: amount
          })
          .then(() => {
            // this.isFin = false;
            // this.finalizeStatus = "finalized";
            this.isAllowDeposit = false;
          });
      });
    },
    handleWinnerTransferMoney() {
      web3.eth.getAccounts().then(accounts => {
        console.log("accounts[0]" + accounts[0]);
        console.log(
          "given: " + web3.eth.accounts.givenProvider.selectedAddress
        );
        // set the address as the parameter
        const selectedAuction = auction(this.auctionAddress);
        selectedAuction.methods
          .getDeposit(web3.eth.accounts.givenProvider.selectedAddress)
          .call()
          .then(amount => {
            console.log("amount of deposit: " + amount);

            selectedAuction.methods
              .getHighestPrice()
              .call()
              .then(highestPrice => {
                selectedAuction.methods.payMoneyOfWinner().send({
                  from: accounts[0],
                  value: highestPrice - amount
                });
              });
          });
      });
    }
  }
};
</script>

<style>
img {
  max-width: 100%;
}

.preview {
  display: -webkit-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-orient: vertical;
  -webkit-box-direction: normal;
  -webkit-flex-direction: column;
  -ms-flex-direction: column;
  flex-direction: column;
}
@media screen and (max-width: 996px) {
  .preview {
    margin-bottom: 20px;
  }
}

.preview-pic {
  -webkit-box-flex: 1;
  -webkit-flex-grow: 1;
  -ms-flex-positive: 1;
  flex-grow: 1;
}

.preview-thumbnail.nav-tabs {
  border: none;
  margin-top: 15px;
}
.preview-thumbnail.nav-tabs li {
  width: 18%;
  margin-right: 2.5%;
}
.preview-thumbnail.nav-tabs li img {
  max-width: 100%;
  display: block;
}
.preview-thumbnail.nav-tabs li a {
  padding: 0;
  margin: 0;
}
.preview-thumbnail.nav-tabs li:last-of-type {
  margin-right: 0;
}

.tab-content {
  overflow: hidden;
}
.tab-content img {
  width: 100%;
  -webkit-animation-name: opacity;
  animation-name: opacity;
  -webkit-animation-duration: 0.3s;
  animation-duration: 0.3s;
}

.card {
  margin-top: 50px;
  background: #eee;
  padding: 3em;
  line-height: 1.5em;
}

@media screen and (min-width: 997px) {
  .wrapper {
    display: -webkit-box;
    display: -webkit-flex;
    display: -ms-flexbox;
    display: flex;
  }
}

.details {
  display: -webkit-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-orient: vertical;
  -webkit-box-direction: normal;
  -webkit-flex-direction: column;
  -ms-flex-direction: column;
  flex-direction: column;
}

.colors {
  -webkit-box-flex: 1;
  -webkit-flex-grow: 1;
  -ms-flex-positive: 1;
  flex-grow: 1;
}

.product-title,
.price,
.sizes,
.colors {
  text-transform: UPPERCASE;
  font-weight: bold;
}

.checked,
.price span {
  color: #ff9f1a;
}

.product-title,
.rating,
.product-description,
.price,
.vote,
.sizes {
  margin-bottom: 15px;
}

.product-title {
  margin-top: 0;
}

.size {
  margin-right: 10px;
}
.size:first-of-type {
  margin-left: 40px;
}

.color {
  display: inline-block;
  vertical-align: middle;
  margin-right: 10px;
  height: 2em;
  width: 2em;
  border-radius: 2px;
}
.color:first-of-type {
  margin-left: 20px;
}

.add-to-cart,
.like {
  background: #ff9f1a;
  padding: 1.2em 1.5em;
  border: none;
  text-transform: UPPERCASE;
  font-weight: bold;
  color: #fff;
  -webkit-transition: background 0.3s ease;
  transition: background 0.3s ease;
}
.add-to-cart:hover,
.like:hover {
  background: #b36800;
  color: #fff;
}

.not-available {
  text-align: center;
  line-height: 2em;
}
.not-available:before {
  font-family: fontawesome;
  content: "\f00d";
  color: #fff;
}

.orange {
  background: #ff9f1a;
}

.green {
  background: #85ad00;
}

.blue {
  background: #0076ad;
}

.tooltip-inner {
  padding: 1.3em;
}

@-webkit-keyframes opacity {
  0% {
    opacity: 0;
    -webkit-transform: scale(3);
    transform: scale(3);
  }
  100% {
    opacity: 1;
    -webkit-transform: scale(1);
    transform: scale(1);
  }
}

@keyframes opacity {
  0% {
    opacity: 0;
    -webkit-transform: scale(3);
    transform: scale(3);
  }
  100% {
    opacity: 1;
    -webkit-transform: scale(1);
    transform: scale(1);
  }
}
</style>