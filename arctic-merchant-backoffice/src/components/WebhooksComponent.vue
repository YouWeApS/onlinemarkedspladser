<template>
  <div>
    <json-editor
      :schema="schema"
      v-model="webhooks"
      input-wrapping-class="json-editor-row"
      @submit="submit">

      <button
        class="button primary"
        type="submit">
        Save changes
      </button>
    </json-editor>
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "WebhooksComponent",

  mixins: [VendorMixin],

  data() {
    return {
      webhooks: {}
    };
  },

  methods: {
    async submit(e) {
      e.preventDefault();
      e.stopPropagation();

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/config`;

      const response = await this.axios.patch(url, {
        webhooks: this.webhooks
      });

      this.$notify({
        title: "Webhooks updated",
        type: "success",
        group: "global"
      });

      await this.loadVendors();
      this.setCurrentVendor(response.data);
    },

    setWebhooks() {
      if (this.currentVendorId) {
        this.webhooks = this.currentVendor.config.webhooks;
      }
    }
  },

  computed: {
    schema() {
      return this.currentVendor.channel.webhook_schema || {};
    }
  },

  watch: {
    currentVendor() {
      this.setWebhooks();
    }
  },

  mounted() {
    this.setWebhooks();
  }
};
</script>
