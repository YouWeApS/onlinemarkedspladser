<template>
  <div>
    <form @submit.prevent="submit">
      <label>
        New password
        <input
          type="password"
          name="password"
          autocomplete="password"
          placeholder="my-new-secret-password"
          autofocus
          v-model="password"
          required />
      </label>

      <label>
        Confirm new password
        <input
          type="password"
          name="password_confirmation"
          autocomplete="password_confirmation"
          placeholder="my-new-secret-password"
          autofocus
          v-model="password_confirmation"
          required />
      </label>

      <button type="submit" class="button expanded">
        Reset my password
      </button>
    </form>
  </div>
</template>

<script>
export default {
  name: "RecoverPasswordFormComponent",

  data() {
    return {
      password: null,
      password_confirmation: null
    };
  },

  computed: {
    token() {
      return window.getParameterByName("token");
    }
  },

  methods: {
    async submit(e) {
      e.preventDefault();
      e.stopPropagation();

      await this.axios.post("reset_password", {
        token: this.token,
        password: this.password,
        password_confirmation: this.password_confirmation
      });

      this.$notify({
        title: "Success",
        text: "Your password has been reset",
        type: "success",
        group: "global"
      });

      this.$router.push({ path: "/login" });
    }
  }
};
</script>

<style lang="scss" scoped>
.callout {
  max-width: 300px;
}
</style>
