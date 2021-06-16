<template>
  <section class="grid-x">
    <spinner v-if="loading" />

    <div class="cell small-11" v-if="!loading && user">
      <h1>My profile</h1>

      <notifications
        group="user"
        position="top center" />

      <div class="card">
        <div class="card-section">
          <user-form-component
            :user="user"
            @change="resetUser" />
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import UserFormComponent from "@/components/UserFormComponent";

export default {
  name: "ProfileEditView",

  components: {
    UserFormComponent
  },

  data() {
    return {
      user: null,
      loading: true
    };
  },

  methods: {
    resetUser(user) {
      this.user = user;
      this.$store.dispatch("setCurrentUser", this.user);
      this.$notify({
        group: "user",
        title: "Success",
        text: "Your profile information has been updated",
        type: "success"
      });
    }
  },

  async mounted() {
    window.Notification = Notification;
    const response = await this.axios.get("me");
    this.user = response.data;
    this.loading = false;
  }
};
</script>
