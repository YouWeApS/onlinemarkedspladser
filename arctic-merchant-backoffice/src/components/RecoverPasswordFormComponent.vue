<template>
  <div>
    <div class="callout primary" v-if="processStarted">
      <p>Success. If we know that email you will shortly receive an email with a link to reset your rassword.</p>
    </div>

    <form @submit.prevent="submit">
      <label>
        Email
        <input
          type="email"
          name="email"
          autocomplete="email"
          placeholder="john@microsoft.com"
          autofocus
          v-model="email"
          required />
      </label>

      <button type="submit" class="button expanded">
        Start recovery process
      </button>
    </form>
  </div>
</template>

<script>
export default {
  name: "RecoverPasswordFormComponent",

  data() {
    return {
      email: null,
      processStarted: false
    };
  },

  methods: {
    async submit(e) {
      e.preventDefault();
      e.stopPropagation();

      await this.axios.post("recover_password", {
        email: this.email,
        redirect_to: `${process.env.VUE_APP_HOST}/#reset-password`
      });

      this.email = null;
      this.processStarted = true;
    }
  }
};
</script>

<style lang="scss" scoped>
.callout {
  max-width: 300px;
}
</style>
