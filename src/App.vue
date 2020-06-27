<template>
  <div>
    <!-- <Sidebar></Sidebar> -->
    <Navbar></Navbar>
    <router-view />
  </div>
</template>

<script>
import Sidebar from "./component/Sidebar.vue";
import Navbar from "./component/NavBar.vue";
export default {
  name: "APP",
  components: {
    Sidebar,
    Navbar
  }
};
</script>

<style>
</style>
