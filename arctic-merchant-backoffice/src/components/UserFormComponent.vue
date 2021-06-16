<template>
  <div v-if="user" class="grid-x grid-padding-x">
    <div class="cell small-12 medium-2">
      <picture-input
        ref="profilePicture"
        @change="changeProfilePicture"
        width="200"
        height="200"
        radius="50"
        accept="image/jpeg,image/png"
        :prefill="user.avatar_url"
        buttonClass="btn"
        :customStrings="{
          upload: '<h1>Bummer!</h1>',
          drag: 'Click to select a profile picture'
        }" />
    </div>

    <div class="cell small-12 medium-10">
      <form @submit.prevent="updateProfile">
        <h2>General information</h2>

        <label>
          Name
          <input
            type="text"
            required
            v-model="user.name" />
        </label>

        <label>
          Email
          <input
            type="email"
            required
            v-model="user.email" />
        </label>

        <label>
          Language
          <select
            v-model="user.locale"
            required>
            <option value="da">Dansk</option>
            <option value="en">English</option>
          </select>
        </label>

        <button type="submit" class="button primary">
          Update information
        </button>
      </form>

      <form @submit.prevent="updateProfile">
        <h2>Change password</h2>

        <label>
          New Password
          <input
            type="password"
            autocomplete="off"
            required
            v-model="user.password" />
        </label>

        <label>
          Repeat new Password
          <input
            type="password"
            autocomplete="off"
            required
            v-model="user.password_confirmation" />
        </label>

        <button type="submit" class="button primary">
          Change password
        </button>
      </form>
    </div>
  </div>
</template>

<script>
import AuthenticationMixin from "@/mixins/AuthenticationMixin";

export default {
  name: "UserFormComponent",

  mixins: [AuthenticationMixin],

  props: {
    user: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      activeTabs: ["general-information"]
    };
  },

  methods: {
    async updateProfile() {
      const response = await this.axios.patch(
        "users/" + this.user.id,
        this.user
      );
      this.$emit("change", response.data);
    },

    rememberClosingInfoBox() {
      this.$cookies.set("rememberProfileUpdatePasswordBox", 1);
    },

    async changeProfilePicture() {
      // Multipart form data submit (http://bit.ly/2ONEiNI)
      const formData = new FormData();
      formData.append("avatar", this.$refs.profilePicture.file);
      const response = await this.axios.patch(
        `users/${this.user.id}`,
        formData,
        {
          "Content-Type": "multipart/form-data"
        }
      );
      this.$emit("change", response.data);
    }
  }
};
</script>

<style lang="scss" scoped>
.avatar-uploader-icon {
  line-height: 178px; // Drag container height
}

.avatar {
  max-width: 200px;
  max-height: 178px;
  object-fit: contain;
  float: left;
  margin-right: 20px;
}
</style>
