<template>
  <div>
    <b-navbar type="dark" variant="dark" fixed = "false">
      <b-navbar-nav>
        <b-nav-item href="">Home</b-nav-item>
        <b-nav-item href="#"><router-link :to="{ name: 'create-auction'}">Create Auction</router-link></b-nav-item>'
        <b-nav-item><router-link :to="{ name: 'auction-low-list'}">Low value auctions</router-link></b-nav-item>
        <b-nav-item><router-link :to="{ name: 'aution-list'}">High value auctions</router-link></b-nav-item>

        <b-nav-item-dropdown text="Lang" right>
          <b-dropdown-item href="#">EN</b-dropdown-item>
          <b-dropdown-item href="#">ES</b-dropdown-item>
          <b-dropdown-item href="#">RU</b-dropdown-item>
          <b-dropdown-item href="#">FA</b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>

      <b-navbar-nav class="ml-auto">

        <b-nav-item-dropdown right>
          <!-- Using 'button-content' slot -->
          <template v-slot:button-content>
            <em>2.0.1</em>
          </template>
          <b-dropdown-item href="#">Profile</b-dropdown-item>
          <b-dropdown-item href="#">Sign Out</b-dropdown-item>
        </b-nav-item-dropdown>
      </b-navbar-nav>
    </b-navbar>
  </div>
</template>

<script>
export default {};
</script>

<style>
</style>