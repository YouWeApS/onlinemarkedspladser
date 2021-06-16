<template>
  <div>
    <h2>Upload product data</h2>

    <p>
      Once you have downloaded the product data and updated it you can upload it
      here to update your products.
    </p>

    <p>
      After a successfull upload we sill shortly start processing the file.
      Depending on the file size it may take a while before you see the changes
      reflected in your products.
    </p>

    <notifications
      class="inline-notifications"
      group="import" />

    <input
      type="file"
      id="importFile"
      ref="file"
      class="show-for-sr">

    <label
      for="importFile"
      class="button"
      v-if="!uploaded">
      <i class="fal fa-fw fa-upload" />
      Upload
    </label>
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "VendorProductDataExport",

  mixins: [VendorMixin],

  data() {
    return {
      uploaded: false
    };
  },

  methods: {
    async upload() {
      const file = this.fileInput.files[0];

      const formData = new FormData();

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products/import`;

      formData.append("file", file, file.name);

      try {
        const response = await this.axios.put(url, formData);

        this.fileInput.value = null;

        this.uploaded = response.status === 202;

        if (response.status === 202) {
          this.$notify({
            title: "Product import accepted",
            type: "success",
            group: "import",
            duration: -1
          });
        }
      } catch (error) {
        this.$notify({
          title: "Error",
          text: "Unable to upload file. Please try again later",
          type: "error",
          group: "import"
        });
      } finally {
        this.fileInput.value = null;
      }
    }
  },

  computed: {
    fileInput() {
      return this.$refs.file;
    }
  },

  mounted() {
    this.fileInput.addEventListener("change", this.upload);
  }
};
</script>
