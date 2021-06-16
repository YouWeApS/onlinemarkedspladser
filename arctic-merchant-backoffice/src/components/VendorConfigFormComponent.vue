<template>
  <div v-if="schemaPresent && config && schema">
    <h2>Shop configuration</h2>

    <json-editor
      :schema="schema"
      v-model="config"
      auto-complete="off"
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
  name: "VendorConfigFormComponent",

  mixins: [VendorMixin],

  data() {
    return {
      schema: {},
      config: {}
    };
  },

  methods: {
    redraw() {
      this.schema = {};
      this.config = {};

      setTimeout(() => {
        this.schema = this.currentVendor.channel.config_schema;
        this.config = this.currentVendor.config.config;
      }, 300);
    },

    async submit(e) {
      e.preventDefault();
      e.stopPropagation();

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/config`;

      const response = await this.axios.patch(url, {
        config: this.config
      });

      await this.loadVendors();
      this.setCurrentVendor(response.data);
    }
  },

  computed: {
    configPresent() {
      return !!Object.keys(this.config).length;
    },

    schemaPresent() {
      return !!Object.keys(this.schema).length;
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
