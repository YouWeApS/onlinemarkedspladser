<template>
  <tr :id="`product-${product.id}`" class="shifted">
    <td>
    </td>
    <td v-if="shouldDisplayStatus" class="text-center">
      <product-status-component :product="product" />
    </td>
    <td>
      <router-link :to="`/products/${product.id}`">
        <img :src="mainImageUrl" class="main">
      </router-link>
    </td>
    <td>
      <router-link :to="`/products/${product.id}`">
        {{ product.sku }}
      </router-link>
    </td>
    <td>
      <router-link :to="`/products/${product.id}`">
        {{ product.name }}
      </router-link>
    </td>
    <td>
      <router-link :to="`/products/${product.id}`">
        {{ product.ean }}
      </router-link>
    </td>
    <td>
      {{ date_type }} at:
      <time-ago
        data-tooltip
        class="has-tooltip"
        :title="date"
        prefix=""
        suffix="ago"
        :date="date"
        v-if="date" />
      <span v-else>Never</span>

      <br>

      <small>
        Last updated at:
        <time-ago
          data-tooltip
          class="has-tooltip"
          :title="product.updated_at"
          prefix=""
          suffix="ago"
          :date="product.updated_at" />
      </small>
    </td>
    <td>
      <delete-product-checkbox-component
        :product="product"
        :disabled_vendor="product.vendor_id"
        :disabled_value="product.enabled"
        :disabled_product="product.id"/>
    </td>
  </tr>
</template>

<script>
import ProductStatusComponent from "@/components/ProductStatusComponent";
import DeleteProductCheckboxComponent from "@/components/DeleteProductCheckboxComponent";
import FoundationMixin from "@/mixins/FoundationMixin";
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "ProductListItemComponent",

  mixins: [FoundationMixin, VendorMixin],

  components: {
    DeleteProductCheckboxComponent,
    ProductStatusComponent
  },

  props: {
    product: {
      type: Object,
      required: true
    },

    idx: {
      type: Number,
      required: true
    }
  },

  computed: {
    mainImageUrl() {
      if (this.product.images[0]) return this.product.images[0].url;
      return null;
    },

    shouldDisplayStatus() {
      return this.currentVendor.type !== "collection";
    },

    even() {
      return this.idx % 2 === 0;
    },

    date_type() {
      switch (this.currentVendor.type) {
        case "collection":
          return "Last collected";
        default:
          return "Last dispersed";
      }
    },

    date() {
      switch (this.currentVendor.type) {
        case "collection":
          return this.currentVendor.last_synced_at;
        default:
          return this.product.last_dispersed_at;
      }
    }
  }
};
</script>

<style lang="scss" scoped>
.has-tooltip {
  font-weight: 300;
  border: none;
}
.shifted {
  border-left: 4px solid #1779ba;
  background-color: rgba(129, 129, 129, 0.17);
}

.main {
  max-width: 150px;
}
</style>
