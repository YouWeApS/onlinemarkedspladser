<template>
  <div class="grid-x grid-margin-x">
    <div class="cell shrink">
      <label>
        {{ title }}
        <input
          type="number"
          step=".01"
          name="offer_price"
          v-model="price"
          :placeholder="title"
          :required="priceRequired" />
      </label>
    </div>

    <div class="cell shrink">
      <label>
        Currency
        <select
          v-model="currency"
          :required="currencyRequired">
          <option
            v-for="c in currencies"
            :key="c.id"
            :value="c.iso_code">
            {{ c.iso_code }} - {{ c.name }}
          </option>
        </select>
      </label>
    </div>

    <div class="cell">
      <p class="help-text">
        Preview: {{ previewPrice }} {{ previewCurrency }}
      </p>
    </div>
  </div>
</template>

<script>
export default {
  name: "PriceFormComponent",

  data() {
    return {
      price: null,
      currency: null,
      currencies: []
    };
  },

  props: {
    product: {
      type: Object,
      required: true
    },

    type: {
      type: String,
      default: "original_price"
    }
  },

  computed: {
    currencyRequired() {
      return !!this.shadowCents;
    },

    priceRequired() {
      return !!this.shadowCurrency;
    },

    shadowCents() {
      return (this.product[this.type] || {}).cents;
    },

    shadowCurrency() {
      return (this.product[this.type] || {}).currency;
    },

    previewPrice() {
      const product_cents = (this.product.preview[this.type] || {}).cents;
      const price = (this.shadowCents || product_cents) / 100.0;
      return price || "No price";
    },

    previewCurrency() {
      const product_currency = (this.product.preview[this.type] || {}).currency;
      return this.shadowCurrency || product_currency || "No currency";
    },

    title() {
      switch (this.type) {
        case "offer_price":
          return "Offer price";

        default:
          return "Original price";
      }
    }
  },

  watch: {
    price() {
      if (!this.product[this.type]) this.product[this.type] = {};
      this.product[this.type].cents = this.price * 100.0;
    }
  },

  async mounted() {
    if (this.shadowCents) this.price = this.shadowCents / 100.0;
    if (this.shadowCurrency) this.currency = this.shadowCurrency;

    const response = await this.axios.get("currencies");
    this.currencies = response.data;
  }
};
</script>
