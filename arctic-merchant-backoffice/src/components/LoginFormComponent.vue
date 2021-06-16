<template>
  <form @submit.prevent="login">
    <label>
      Email
      <input
        type="email"
        name="email"
        placeholder="john@microsoft.com"
        required
        v-model="username"
        ref="username"
        autofocus="username" />
    </label>

    <label>
      Password
      <input
        type="password"
        name="password"
        placeholder="mysecretpassword"
        required
        autocomplete="off"
        v-model="password" />
    </label>

    <button
      type="submit"
      class="button expanded"
      :disabled="submitting">
      Sign in
    </button>
  </form>
</template>

<script>
import AuthenticationMixin from "@/mixins/AuthenticationMixin";

export default {
  name: "LoginButtonComponent",

  mixins: [AuthenticationMixin],

  data() {
    return {
      username: null,
      password: null,
      submitting: false
    };
  },

  methods: {
    async login() {
      window.console.log("Signing in..");
      this.submitting = true;

      try {
        const options = {
          username: this.username,
          password: this.password
        };

        const response = await this.axios.post(
          process.env.VUE_APP_OAUTH_SERVICE_PROVIDER_URL +
            "/authorize/password",
          options
        );

        this.$store.dispatch("setAccessToken", response.data.access_token);

        window.location.replace("/");
      } catch (e) {
        this.$notify({
          title: "Failure",
          text: "Invalid email and/or password",
          type: "error",
          group: "global"
        });
        this.submitting = false;
      }
    }
  },

  mounted() {
    this.$refs.username.focus();
  }
};
</script>

<style lang="scss" scoped>
.button {
  margin-top: 40px;
}
</style>
