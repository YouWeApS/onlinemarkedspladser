<template>
  <form @submit.prevent="submit">
    <label>
      Default currency

      <select
        v-model="currency">
        <option
          v-for="c in currencies"
          :key="c.id"
          :value="c.iso_code">
            {{ c.iso_code }}
          </option>
      </select>
    </label>

    <button class="button primary" type="submit">
      Save changes
    </button>
  </form>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "VendorProductCurrencyComponent",

  mixins: [VendorMixin],

  data() {
    return {
      currencies: [],
      currency: null
    };
  },

  methods: {
    async submit() {
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/config`;

      const data = {
        currency_config: {
          currency: this.currency
        }
      };

      const response = await this.axios.patch(url, data);

      await this.loadVendors();

      this.setCurrentVendor(response.data);
    }
  },

  async mounted() {
    const response = await this.axios.get("currencies");
    this.currencies = response.data;
    this.currency = this.currentVendor.config.currency_config.currency;
  }
};
</script>
