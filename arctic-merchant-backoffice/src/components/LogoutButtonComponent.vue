<template>
  <a @click="resetStoreState" class="clear button">
    <i class="fal fa-sign-out" />
    Logout
  </a>
</template>

<script>
export default {
  name: "LogoutButtonComponent",

  methods: {
    resetStoreState() {
      window.globalLogout();
    }
  }
};
</script>

<style scoped lang="scss">
.button {
  text-align: left !important;
  font-size: 16px; // Same as other menu elements
}

i {
  margin-right: 10px;
}
</style>
