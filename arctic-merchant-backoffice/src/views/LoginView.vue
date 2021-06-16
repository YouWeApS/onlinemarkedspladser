<template>
  <div class="grid-x align-middle align-center">
    <div class="cell shrink card">
      <h1>Sign in</h1>

      <login-form-component />

      <ul class="vertical menu align-center">
        <li>
          <router-link to="recover-password">
            I forgot my password
          </router-link>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import LoginFormComponent from "@/components/LoginFormComponent";

export default {
  name: "LoginView",

  components: {
    LoginFormComponent
  }
};
</script>

<style lang="scss" scoped>
.grid-x {
  background-color: #333;
  height: 100vh;
}

.card {
  min-height: 400px;
  min-width: 300px;
  padding: 20px;
}
</style>
