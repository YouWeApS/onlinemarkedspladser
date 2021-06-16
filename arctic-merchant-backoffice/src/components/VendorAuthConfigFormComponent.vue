<template>
  <div>
    <div v-if="config && schema">
      <h2>Authentication configuration</h2>

      <json-editor
        :schema="schema"
        v-model="config"
        auto-complete="off"
        input-wrapping-class="json-editor-row"
        @submit="submit">

        <p>
          <button
            class="button primary"
            type="submit">
            Save changes
          </button>
        </p>
      </json-editor>
    </div>

    <spinner v-else />
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "VendorAuthConfigFormComponent",

  mixins: [VendorMixin],

  data() {
    return {
      schema: null,
      config: null
    };
  },

  methods: {
    redraw() {
      this.schema = null;
      this.config = null;

      setTimeout(() => {
        this.schema = this.currentVendor.channel.auth_config_schema;
        this.config = this.currentVendor.config.auth_config;
      }, 300);
    },

    async submit(e) {
      e.preventDefault();
      e.stopPropagation();

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/config`;

      const response = await this.axios.patch(url, {
        auth_config: this.config
      });

      await this.loadVendors();
      this.setCurrentVendor(response.data);
    }
  },

  watch: {
    currentVendor() {
      this.redraw();
    }
  },

  mounted() {
    this.redraw();
  }
};
</script>
