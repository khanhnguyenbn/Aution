<template>
  <div id="aution-table">
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
          <td>{{aution.title}}</td>
          <td>{{aution.startPrice}}</td>
          <td>{{aution.highestPrice}}</td>
          <td>{{aution.state}}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: "aution-table",
  props: {
    autionList: Array
  },
  // data() {
  //   return {
  //     employees: [
  //       {
  //         id: 1,
  //         name: "test-name"
  //       },
  //       {
  //         id: 2,
  //         name: "test-name 2"
  //       }
  //     ]
  //   };
  // },
  methods: {
    testEvent: function() {
      console.log("click on button" + this.employees[0]);
    }
  }
};
</script>

<style scoped>
</style>