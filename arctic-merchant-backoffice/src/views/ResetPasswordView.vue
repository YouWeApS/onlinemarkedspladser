<template>
  <div class="grid-x align-middle align-center">
    <div class="cell shrink card">
      <h1>Reset my password</h1>

      <reset-password-form-component />

      <ul class="vertical menu align-center">
        <li>
          <router-link to="login">
            Back to login form
          </router-link>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import ResetPasswordFormComponent from "@/components/ResetPasswordFormComponent";

export default {
  name: "ResetPasswordView",

  components: {
    ResetPasswordFormComponent
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
