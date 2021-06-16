<template>
  <div class="grid-x align-middle align-center">
    <div class="cell shrink card">
      <h1>Recover my password</h1>

      <recover-password-form-component />

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
import RecoverPasswordFormComponent from "@/components/RecoverPasswordFormComponent";

export default {
  name: "RecoverPasswordView",

  components: {
    RecoverPasswordFormComponent
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
