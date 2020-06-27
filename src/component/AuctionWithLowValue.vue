<template>
  <div class="container" id="low-value-list">
    <b-row>
      <b-col lg="4">
        <b-form-input v-model="filter" type="search" id="filterInput" placeholder="Type to Search"></b-form-input>
      </b-col>
    </b-row>
    <b-row>
      <b-col sm="5" md="6" class="my-1">
        <!-- <b-form-group
          label="Per page"
          label-cols-sm="6"
          label-cols-md="4"
          label-cols-lg="3"
          label-align-sm="right"
          label-size="sm"
          label-for="perPageSelect"
          class="mb-0"
        >-->
        <b-form-select v-model="perPage" id="perPageSelect" size="sm" :options="pageOptions"></b-form-select>
        <!-- </b-form-group> -->
      </b-col>

      <b-col sm="7" md="6" class="my-1">
        <b-pagination
          v-model="currentPage"
          :total-rows="totalRows"
          :per-page="perPage"
          align="fill"
          size="sm"
          class="my-0"
        ></b-pagination>
      </b-col>
    </b-row>

    <b-table
      striped
      hover
      responsive
      :items="items"
      :fields="fields"
      :filter="filter"
      :current-page="currentPage"
      :per-page="perPage"
      @row-clicked="myRowClickHandler"
    ></b-table>
  </div>
</template>

<script>
import axios from "axios";
import AuctionUtil from "../Utils/AuctionUtil";

export default {
  data() {
    return {
      fields: [
        // {
        //   label: "ID",
        //   key: "id"
        // },
        {
          label: "Title",
          key: "title",
          sortable: true
        },
        {
          label: "Start Price (ETH)",
          key: "startPrice"
        },
        {
          label: "Highest Price (ETH)",
          key: "highestPrice"
        },
        {
          label: "State",
          key: "state"
        },
        // {
        //   label: "Start Time",
        //   key: "startTime"
        // },
        {
          label: "End Time",
          key: "endTime",
          sortable: true
        }
      ],
      items: [],
      totalRows: 1,
      filter: "",
      currentPage: 1,
      perPage: 5,
      pageOptions: [5, 10, 15]
    };
  },
  mounted() {
    axios.get("http://127.0.0.1:8086/auctions").then(response => {
      var initialDataList = response.data.data;
      for (let i = 0; i < initialDataList.length; i++) {
        console.log(typeof initialDataList[i].amount);
        initialDataList[i].startPrice = web3.utils.fromWei(
          String(initialDataList[i].startPrice),
          "ether"
        );

        initialDataList[i].highestPrice = web3.utils.fromWei(
          String(initialDataList[i].highestPrice),
          "ether"
        );

        initialDataList[i].state = AuctionUtil.getStringState(
          initialDataList[i].state
        );
      }

      this.items = initialDataList;

      this.totalRows = this.items.length;
    });
  },
  methods: {
    myRowClickHandler(record, index) {
      this.$router.push({ path: "auctions-with-low-value/" + record.id });
    }
  }
};
</script>


<style>
#low-value-list {
  margin-top: 1rem;
}
</style>