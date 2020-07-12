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
          <b-form-select v-model="selected" id="initialSortSelect" :options="options"></b-form-select>
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
import auction from "../../contracts/auctionInstance";
import auctionBox from "../../contracts/auctionBoxInstance";

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
      ownerAddress: "",

      selected: 1,

      options: [
        { value: 1, text: "Low Value" },
        { value: 2, text: "High Value" }
      ]
    };
  },
  methods: {
    createAuction() {
      if (this.selected == 1) {
        console.log("endDate: " + Date.parse(this.endDate));
        web3.eth
          .getAccounts()
          .then(accounts => {
            var id =
              web3.eth.accounts.givenProvider.selectedAddress +
              new Date().getTime();
            const startPrice = web3.utils.toWei(this.startPrice, "ether");

            this.isLoad = true;
            return auctionBoxLV.methods
              .createAuction(id)
              .send(
                { from: web3.eth.accounts.givenProvider.selectedAddress },
                (err, hash) => {
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
                    body.ownerAccountAddress =
                      web3.eth.accounts.givenProvider.selectedAddress;

                    axios
                      .post("http://127.0.0.1:8086/auctions", body)
                      .then(response => {
                        console.log("response: " + response.data);
                      })
                      .catch(e => {
                        console.log("ex: " + e);
                      });
                  }
                }
              );
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
      } else if (this.selected == 2) {


        console.log("endDate: " + Date.parse(this.endDate));
        web3.eth
          .getAccounts()
          .then(accounts => {
            // convert 'ether' to 'wei'
            const startPrice = web3.utils.toWei(this.startPrice, "ether");
            // createAuction in AuctionBox contract
            this.isLoad = true;
            return auctionBox.methods
              .createAuction(
                this.title,
                startPrice,
                this.description,
                [this.ownerName, this.ownerPhoneNumber, this.ownerAddress],
                new Date().getTime(),
                Date.parse(this.endTime)
              )
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
      }
    }
  }
};
</script>

<style>
</style>