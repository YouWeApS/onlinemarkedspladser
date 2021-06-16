<template>
  <div>
    <h2>Download product data</h2>

    <p>
      Download all product data for {{ this.currentVendor.name }} for
      mass-editing.
    </p>

    <p>
      After a succesful request we will start building the file. We will send
      you an email with a link to download the file once it's ready.
    </p>

    <notifications
      class="inline-notifications"
      group="export" />

    <button
      class="primary button"
      @click="requestDownload"
      v-if="!success">
      <i class="fal fa-fw fa-download" />
      Download
    </button>
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "VendorProductDataExport",

  mixins: [VendorMixin],

  data() {
    return {
      success: false
    };
  },

  methods: {
    async requestDownload() {
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products/export`;

      try {
        const response = await this.axios.get(url);

        this.success = response.status === 202;

        if (response.status === 202) {
          this.$notify({
            title: "Product export started",
            type: "success",
            group: "export",
            duration: -1 // disable auto-hiding
          });
        }
      } catch (e) {
        this.success = false;

        this.$notify({
          title: "Product export failed",
          text: "Please try again later",
          type: "error",
          group: "export"
        });
      }
    }
  }
};
</script>
