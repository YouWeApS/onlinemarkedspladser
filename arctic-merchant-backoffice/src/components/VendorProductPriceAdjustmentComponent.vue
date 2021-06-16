<template>
  <form @submit.prevent="submit">
    <label>
      All products should be adjusted by X {{ type }}

      <input
        type="number"
        name="value"
        v-model="value">
    </label>

    <p>
      <button type="suvmit" class="button primary">
        Save changes
      </button>
    </p>
  </form>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "VendorProductPriceAdjustmentComponent",

  mixins: [VendorMixin],

  props: {
    vendor: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      value: 0,
      type: "percent"
    };
  },

  methods: {
    recalculate() {
      this.value = this.vendor.config.price_adjustment_value;
      this.type = this.vendor.config.price_adjustment_type;
    },

    async submit(e) {
      e.preventDefault();
      e.stopPropagation();

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/config`;

      const response = await this.axios.patch(url, {
        price_adjustment_type: this.type,
        price_adjustment_value: this.value
      });

      await this.loadVendors();
      this.setCurrentVendor(response.data);
    }
  },

  watch: {
    vendor() {
      this.recalculate();
    }
  },

  mounted() {
    this.recalculate();
  }
};
</script>
