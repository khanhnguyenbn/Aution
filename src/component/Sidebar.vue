<template>
  <div>
    <b-button v-b-toggle.sidebar-no-header>Menu</b-button>
    <b-sidebar id="sidebar-no-header" aria-labelledby="sidebar-no-header-title" no-header shadow>
      <template v-slot:default="{ hide }">
        <div class="p-3">
          <h4 id="sidebar-no-header-title">Custom header sidebar</h4>
          <!-- <b-img src="/home/khanhnguyen/Auction/src/assets/logo.png" fluid></b-img> -->
          <nav class="mb-3">
            <b-nav vertical>
              <b-nav-item active @click="hide">Active</b-nav-item>
              <b-nav-item @click="hide">
                <router-link :to="{ name: 'aution-list'}">Auction With High Value</router-link>
              </b-nav-item>
              <b-nav-item @click="hide">
                <router-link :to="{ name: 'auction-low-list'}">Auction With Low Value</router-link>
              </b-nav-item>
              <b-nav-item active @click="hide">
                <router-link :to="{ name: 'create-auction'}">Create Auction</router-link>
              </b-nav-item>
            </b-nav>
          </nav>
          <b-button variant="primary" block @click="hide">Close Sidebar</b-button>
        </div>
      </template>
    </b-sidebar>
  </div>
</template>

<script>
export default {};
</script>

<style>
</style>