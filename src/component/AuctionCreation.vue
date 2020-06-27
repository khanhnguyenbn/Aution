<template>
  <div class="container">
    <b-row class="b-row">
      <!-- <div>
        <h1>
          Aution
          <span>#{{ amount }}</span>
        </h1>
      <hr />-->
      <b-col class="b-col">
        <div>
          <label for="title">Title</label>
          <b-form-input id="title" v-model="title" type="text" placeholder="title of auction" />
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
        <div>
          <label>End Datetime</label>
          <datetime format="YYYY-MM-DD h:i" v-model="endTime"></datetime>
        </div>
        <div>
          <label for="Description">Description</label>
          <b-form-textarea id="Description" v-model="description" rows="5" />
        </div>
      </b-col>

      <b-col class="b-row">
        <div>
          <label for="ownerName">Your Name</label>
          <b-form-input id="ownerName" v-model="ownerName" placeholder="your name" />
        </div>
        <div>
          <label for="phoneNumber">phone number</label>
          <b-form-input
            id="phoneNumber"
            v-model="ownerPhoneNumber"
            placeholder="your phone number"
          />
        </div>
        <div>
          <label for="address">Address</label>
          <b-form-input id="address" v-model="ownerAddress" placeholder="your address" />
        </div>
        <div>
          <label>Type of auction</label>
         <b-form-select
            v-model="sortDirection"
            id="initialSortSelect"
            :options="['Low Value', 'High Value']"
          ></b-form-select>
        </div>
      </b-col>
    </b-row>
    <hr />
    <div class="b-row">
      <div>
        <b-button :variant="'primary'" @click="createAuction">{{createStatus}}</b-button>
        <img v-show="isLoad" src="https://media.giphy.com/media/2A6xoqXc9qML9gzBUE/giphy.gif" />
      </div>
    </div>
  </div>
</template>

<script>
import web3 from "../../contracts/web3";
import auctionLV from "../../contracts/auctionLV";
import auctionBoxLV from "../../contracts/auctionBoxLV";
import DataTable from "./Table";
// import SidebarMenu from "./SidebarMenu";
import datetime from "vuejs-datetimepicker";
import TimeConverterUtil from "../Utils/TimeConverterUtil";
import AuctionUtil from "../Utils/AuctionUtil";

import axios from "axios";
export default {
  components: {
    datetime
  },
  data() {
    return {
      createStatus: "CREATE",
      isLoad: false,
      title: "",
      startPrice: "",
      description: "",
      endTime: "",
      ownerName: "",
      ownerPhoneNumber: "",
      ownerAddress: ""
    };
  },
  methods: {
    createAuction() {
      console.log("endDate: " + Date.parse(this.endDate));
      web3.eth
        .getAccounts()
        .then(accounts => {
          var id = web3.eth.accounts.givenProvider.selectedAddress + new Date().getTime();
          const startPrice = web3.utils.toWei(this.startPrice, "ether");

          this.isLoad = true;
          return auctionBoxLV.methods
            .createAuction(id)
            .send({ from: web3.eth.accounts.givenProvider.selectedAddress }, (err, hash) => {
              console.log("hash: " + hash);
              console.log("err: " + err);

              if (typeof hash !== "undefined") {
                var body = {};

                body.id = id;
                body.title = this.title;
                body.startPrice = Number(startPrice);
                body.highestPrice = 0;
                body.startTime = new Date().getTime();
                body.endTime = Date.parse(this.endTime);
                body.description = this.description;
                body.state = AuctionUtil.STATE.RUNNING;
                body.ownerName = this.ownerName;
                body.ownerPhoneNumber = this.ownerPhoneNumber;
                body.ownerAddress = this.ownerAddress;
                body.ownerAccountAddress = web3.eth.accounts.givenProvider.selectedAddress;
                

                axios
                  .post("http://127.0.0.1:8086/auctions", body)
                  .then(response => {
                    console.log("response: " + response.data);
                  })
                  .catch(e => {
                    console.log("ex: " + e);
                  });
              }
            });
        })
        .then(value => {
          // console.log("title: " + this.title);
          // console.log("startPrice: " + this.startPrice);

          // let body = {};

          // console.log("id then: " + id);
          // Console.log(value.address);
          // body.id = value[1];
          // body.title = this.title;
          // body.startPrice = Number(startPrice);
          // body.description = this.description;
          // body.ownerName = this.ownerName;
          // body.ownerPhoneNumber = this.ownerPhoneNumber;
          // body.ownerAddress = this.ownerAddress;
          // body.ownerAccountAddress = value[0];

          // console.log("body title: " + body.title);
          // console.log("body id: " + body.id);

          this.isLoad = false;
          this.title = "";
          this.startPrice = "";
          this.description = "";
          this.startPrice = "";
          this.ownerName = "";
          this.ownerPhoneNumber = "";
          this.ownerAddress = "";
          // // get the previous auction
          // return auctionBoxLV.methods.returnAllAuctions().call();
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
          .send({ from: web3.eth.accounts.givenProvider.selectedAddress })
          .then(() => {
            this.isFin = false;
            this.finalizeStatus = "finalized";
          });
      });
    },
    getStringState(numberState) {
      console.log("xxxxxxxxxxxxxxxxx");
      return AuctionUtil.getStringState(numberState);
    }
  }
};
</script>

<style>
</style>