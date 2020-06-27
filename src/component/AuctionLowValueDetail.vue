<template>
  <div class="container">
    <div class="card">
      <div class="container-fliud">
        <div class="wrapper row">
          <div class="preview col-md-6">
            <div class="preview-pic tab-content">
              <div class="tab-pane active" id="pic-1">
                <img
                  src="https://gotecland.vn/wp-content/uploads/2019/04/phoi-canh-eurowindow-river-park-canh-xe-chieu.jpg"
                />
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
              <span class="review-no">end-date: {{endTime}}</span>
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
              <b>STATE OF AUCTION: {{stateString}}</b>
            </h6>
            <h6 v-if="state != '1'">WINNER: {{winner}}</h6>
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
      <div class="col-sm-5">
        <h2>Your Bid History</h2>
        <b-table striped hover :items="userBiddingHistoryItems" :fields="userBiddingHistoryField"></b-table>
      </div>
      <div class="col-sm-7 text-center">
        <h3>Owner Information</h3>
        <h6>Name: {{ownerName}}</h6>
        <h6>Phone number: {{ownerPhoneNumber}}</h6>
        <h6>Address: {{ownerAddress}}</h6>
      </div>
    </div>

    <div class="row">
      <b-table striped hover :items="items" :fields="fields"></b-table>
    </div>
  </div>
</template>

<script>
import web3 from "../../contracts/web3";
import auction from "../../contracts/auctionLV";
import auctionBox from "../../contracts/auctionBoxLV";
import TimeConverterUtil from "../Utils/TimeConverterUtil";
import AuctionUtil from "../Utils/AuctionUtil";
import axios from "axios";

export default {
  name: "AutionDetail",
  data() {
    return {
      id: "",
      title: "",
      startPrice: Number,
      highestPrice: Number,
      description: "",
      state: "",
      stateString: "",
      ownerName: "",
      ownerPhoneNumber: "",
      ownerAddress: "",
      endTime: "",
      bidPrice: "",
      auctionAddress: "",
      bidsHistory: [],
      winner: "",
      amountOfDeposit: "",
      ownerAccountAddress: "",

      isAllowDeposit: false,
      isAllowBid: false,
      isAllowFinalize: false,
      isAllowWinnerTransferMoney: false,
      isAllowWinnerDoAfter: false,
      isAllowRefunForFailBidder: false,

      fields: [
        // {
        //   label: "ID",
        //   key: "id"
        // },
        {
          label: "Type",
          key: "actionTypeString",
          sortable: true
        },
        {
          label: "Amount(ETH)",
          key: "amount"
        },
        {
          label: "Time",
          key: "createdDate",
          sortable: true
        },
        {
          label: "Wallet",
          key: "walletAddress",
          sortable: true
        }
      ],
      items: [],

      userBiddingHistoryField: [
        {
          label: "TIME",
          key: "createdDate",
          sortable: true
        },
        {
          label: "AMOUNT(ETH)",
          key: "amount",
          sortable: true
        }
      ],
      userBiddingHistoryItems: []
    };
  },
  beforeMount() {},
  mounted() {
    axios
      .get("http://127.0.0.1:8086/auctions/" + this.$route.params.auctionId)
      .then(response => {
        let item = response.data.data;

        this.title = item.title;
        this.description = item.description;
        this.startPrice = web3.utils.fromWei(
          item.startPrice.toString(),
          "ether"
        );
        this.highestPrice = web3.utils.fromWei(
          String(item.highestPrice),
          "ether"
        );
        this.state = item.state;
        this.stateString = AuctionUtil.getStringState(item.state);
        this.endTime = item.endTime;
        this.amountOfDeposit = item.deposit;

        this.ownerAccountAddress = item.ownerAccountAddress;
        this.ownerName = item.ownerName;
        this.ownerPhoneNumber = item.ownerPhoneNumber;
        this.ownerAddress = item.ownerAddress;

        // check isAllowFinalize

        if (
          this.state == AuctionUtil.STATE.RUNNING &&
          this.ownerAccountAddress ==
            web3.eth.accounts.givenProvider.selectedAddress
        ) {
          this.isAllowFinalize = true;
        }

        auctionBox.methods
          .getAuctionById(this.$route.params.auctionId)
          .call()
          .then(aution => {
            console.log("aution: " + aution);
            this.auctionAddress = aution;
            // this.getBidsHistory(aution);

            auction(aution)
              .methods.isAllowDeposit(
                web3.eth.accounts.givenProvider.selectedAddress
              )
              .call()
              .then(isAllow => {
                console.log("isAllowDeposit" + isAllow);

                if (
                  this.state == AuctionUtil.STATE.RUNNING &&
                  this.ownerAccountAddress !=
                    web3.eth.accounts.givenProvider.selectedAddress &&
                  new Date() < new Date(this.endTime) &&
                  isAllow == true
                ) {
                  this.isAllowDeposit = true;
                }
              });

            auction(aution)
              .methods.isAllowBid(
                web3.eth.accounts.givenProvider.selectedAddress
              )
              .call()
              .then(isAllow => {
                console.log("isAllowBid" + isAllow);

                if (
                  this.state == AuctionUtil.STATE.RUNNING &&
                  this.ownerAccountAddress !=
                    web3.eth.accounts.givenProvider.selectedAddress &&
                  new Date() < new Date(this.endTime) &&
                  isAllow == true
                ) {
                  this.isAllowBid = true;
                }
              });
          });

        axios
          .get("http://127.0.0.1:8086/actions/get-actions-by-auction-id", {
            params: {
              auctionId: this.$route.params.auctionId
            }
          })
          .then(response => {
            let initialDataList = response.data.data;
            for (let i = 0; i < initialDataList.length; i++) {
              console.log(typeof initialDataList[i].amount);
              initialDataList[i].amount = web3.utils.fromWei(
                String(initialDataList[i].amount),
                "ether"
              );
              initialDataList[
                i
              ].actionTypeString = AuctionUtil.getStringActionType(
                initialDataList[i].actionType
              );
            }

            this.items = initialDataList;
          });

        axios
          .get("http://127.0.0.1:8086/actions/action-type-bid", {
            params: {
              auctionId: this.$route.params.auctionId,
              walletAddress: web3.eth.accounts.givenProvider.selectedAddress,
              actionType: 2
            }
          })
          .then(response => {
            let initialDataList = response.data.data;
            for (let i = 0; i < initialDataList.length; i++) {
              console.log(typeof initialDataList[i].amount);
              initialDataList[i].amount = web3.utils.fromWei(
                String(initialDataList[i].amount),
                "ether"
              );
            }

            this.userBiddingHistoryItems = initialDataList;
          });

        // check isAllowWinnerTransferMoney and isAllowWinnerDoAfter
        axios
          .get("http://127.0.0.1:8086/actions/winner", {
            params: {
              auctionId: this.$route.params.auctionId
            }
          })
          .then(response => {
            this.winner = response.data.data;
            if (
              this.state == AuctionUtil.STATE.FINALIZED &&
              web3.eth.accounts.givenProvider.selectedAddress ==
                response.data.data
            ) {
              this.isAllowWinnerTransferMoney = true;
            }

            if (
              this.state == AuctionUtil.STATE.MONEY_WAS_TRANSFERED &&
              web3.eth.accounts.givenProvider.selectedAddress ==
                response.data.data
            ) {
              this.isAllowWinnerDoAfter = true;
            }
          });
      });
  },

  updated() {},
  methods: {
    handleSubmit() {
      // convert 'ether' to 'wei'
      const bidPriceWei = web3.utils.toWei(this.bidPrice, "ether");

      console.log("bidPriceWei: " + bidPriceWei);

      web3.eth.getAccounts().then(accounts => {
        console.log("accounts[0]" + accounts[0]);
        console.log(
          "given: " + web3.eth.accounts.givenProvider.selectedAddress
        );

        var body = {};
        var auctionModel = {};
        console.log("id: " + this.$route.params.auctionId);
        auctionModel.id = this.$route.params.auctionId;
        body.actionType = AuctionUtil.ACTION.BID;
        body.walletAddress = web3.eth.accounts.givenProvider.selectedAddress;
        body.amount = bidPriceWei;
        body.auctionModel = auctionModel;

        axios
          .post("http://127.0.0.1:8086/actions/place-bid", body)
          .then(response => {
            console.log("response: " + response.data.success);
            if (response.data.success == false) {
              alert(
                "Bid is not success, your bid must greater than highest price"
              );
              this.$router.go();
            }
          })
          .catch(e => {
            console.log("ex: " + e);
          });
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

        axios
          .get("http://127.0.0.1:8086/actions/wallet-address/refund", {
            params: {
              auctionId: this.$route.params.auctionId
            }
          })
          .then(response => {
            selectedAuction.methods
              .refunForLoser(response.data.data)
              .send({ from: web3.eth.accounts.givenProvider.selectedAddress })
              .then(() => {
                axios.get("http://127.0.0.1:8086/auctions/finalize", {
                  params: {
                    auctionId: this.$route.params.auctionId
                  }
                });
              });
          });

        // finalizeAuction in Auction contract
        // var loser = ["0x6BBE19506296b137E2749E3BF69331bB0dca8588"];
        // selectedAuction.methods
        //   .refunForLoser(loser)
        //   .send({ from: accounts[0] })
        //   .then(() => {
        //     // this.isFin = false;
        //     // this.finalizeStatus = "finalized";
        //   });
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
          .transferToOwner(this.ownerAccountAddress)
          .send({ from: web3.eth.accounts.givenProvider.selectedAddress })
          .then(() => {
            // this.isFin = false;
            // this.finalizeStatus = "finalized";

            axios.get("http://127.0.0.1:8086/auctions/update-state", {
              params: {
                auctionId: this.$route.params.auctionId,
                state: AuctionUtil.STATE.DONE
              }
            });
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

        axios
          .get("http://127.0.0.1:8086/actions/winner", {
            params: {
              auctionId: this.$route.params.auctionId
            }
          })
          .then(response => {
            selectedAuction.methods
              .refundForWinner()
              .send({ from: web3.eth.accounts.givenProvider.selectedAddress })
              .then(() => {
                axios.get("http://127.0.0.1:8086/auctions/update-state", {
                  params: {
                    auctionId: this.$route.params.auctionId,
                    state: AuctionUtil.STATE.FAILSE
                  }
                });
              });
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
          .send({ from: web3.eth.accounts.givenProvider.selectedAddress })
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
        // const amount = web3.utils.toWei(this.amountOfDeposit, "ether");
        // finalizeAuction in Auction contract
        selectedAuction.methods
          .payDeposit()
          .send(
            {
              from: web3.eth.accounts.givenProvider.selectedAddress,
              value: this.amountOfDeposit
            },
            (err, hash) => {
              console.log("err: " + err);
              console.log("hash: " + hash);

              if (typeof hash !== "undefined" && err == null) {
                console.log("this is then after bid");

                var body = {};
                var auctionModel = {};
                console.log("id: " + this.$route.params.auctionId);
                auctionModel.id = this.$route.params.auctionId;
                body.actionType = AuctionUtil.ACTION.DEPOSIT;
                body.walletAddress =
                  web3.eth.accounts.givenProvider.selectedAddress;
                body.amount = this.amountOfDeposit;
                body.auctionModel = auctionModel;

                axios
                  .post("http://127.0.0.1:8086/actions", body)
                  .then(response => {
                    console.log("response: " + response.data);
                  })
                  .catch(e => {
                    console.log("ex: " + e);
                  });
              }
            }
          )
          .then(() => {
            // this.isFin = false;
            // this.finalizeStatus = "finalized";
            this.isAllowDeposit = false;

            console.log("this is then send");
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

        axios
          .get("http://127.0.0.1:8086/auctions/" + this.$route.params.auctionId)
          .then(response => {
            let item = response.data.data;

            this.title = item.title;
            this.description = item.description;
            this.startPrice = web3.utils.fromWei(
              item.startPrice.toString(),
              "ether"
            );
            this.highestPrice = item.highestPrice;
            this.state = item.state;
            this.endTime = item.endTime;
            this.amountOfDeposit = item.deposit;

            selectedAuction.methods
              .payMoney()
              .send(
                {
                  from: web3.eth.accounts.givenProvider.selectedAddress,
                  value: item.highestPrice - item.deposit
                },
                (err, hash) => {
                  console.log("err: " + err);
                  console.log("hash: " + hash);

                  if (typeof hash !== "undefined" && err == null) {
                    var body = {};
                    var auctionModel = {};
                    auctionModel.id = this.$route.params.auctionId;
                    body.actionType = AuctionUtil.ACTION.TRANFER;
                    body.walletAddress =
                      web3.eth.accounts.givenProvider.selectedAddress;
                    body.amount = item.highestPrice - item.deposit;
                    body.auctionModel = auctionModel;

                    axios
                      .post(
                        "http://127.0.0.1:8086/actions/transfer-money",
                        body
                      )
                      .then(response => {
                        console.log("response: " + response.data);
                      })
                      .catch(e => {
                        console.log("ex: " + e);
                      });
                  }
                }
              )
              .then(() => {
                // this.isFin = false;
                // this.finalizeStatus = "finalized";
                // this.isAllowDeposit = false;
                // console.log("this is then send");
              });
          });
      });
    },
    checkAllowDeposit() {
      console.log("this is test method");
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