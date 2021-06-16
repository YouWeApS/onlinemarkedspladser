<template>
  <form
    @submit.prevent="submit"
    class="switch small">

    <div class="grid-x">
      <div class="cell shrink">
        <label for="enabled" class="switch-middle">
          Enabled
        </label>
      </div>

      <div class="cell auto">
        <input
          v-model="enabled"
          id="enabled"
          type="checkbox"
          class="switch-input"
          @change="submit" />

        <label
          for="enabled"
          class="switch-paddle">
          <span class="switch-active" aria-hidden="true">Yes</span>
          <span class="switch-inactive" aria-hidden="true">No</span>
        </label>
      </div>
    </div>
  </form>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "VendorEnableToggleComponent",

  mixins: [VendorMixin],

  data() {
    return {
      enabled: false
    };
  },

  methods: {
    async submit() {
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/config`;

      const response = await this.axios.patch(url, {
        enabled: this.enabled
      });

      await this.loadVendors();

      this.setCurrentVendor(response.data);

      this.$notify({
        title: "Synchronization updated",
        type: "success",
        group: "global"
      });
    },

    setEnabled() {
      if (this.currentVendor) this.enabled = this.currentVendor.enabled;
    }
  },

  watch: {
    currentVendor() {
      this.setEnabled();
    }
  },

  mounted() {
    this.setEnabled();
  }
};
</script>

<style lang="scss" scoped>
.switch-middle {
  padding-top: 2px;
  margin-right: 5px;
}
</style>
