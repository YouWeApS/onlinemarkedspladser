<template>
    <tr :id="`product-${product.id}`" class="shifted">
        <td>
        </td>
        <td v-if="shouldDisplayStatus" class="text-center">
            <product-status-component :product="product" />
        </td>
        <td class="text-center">
            <router-link :to="`/products/${product.id}`">
                <div class="cell small-12 medium-3">
                    <img :src="mainImageUrl" class="main">
                </div>
            </router-link>
        </td>

        <td>
            <router-link :to="`/products/${product.id}`">
                SKU: {{ product.sku }}

                <br>

                <span>
          EAN: {{ product.ean }}
        </span>

                <br>

                <span>
          {{ product.name }}
        </span>
            </router-link>
        </td>

        <td
            v-for="vendor in vendors"
            :key="vendor.key">
                <delete-product-checkbox-component
                        :product="product"
                        :disabled_vendor="vendor.id"
                        :disabled_value="enabled_vendors[vendor.name][0]"
                        :disabled_product="enabled_vendors[vendor.name][1]"/>

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

    </tr>
</template>

<script>
import ProductImagesComponent from "@/components/ProductImagesComponent";
import ProductStatusComponent from "@/components/ProductStatusComponent";
import DeleteProductCheckboxComponent from "@/components/DeleteProductCheckboxComponent";
import FoundationMixin from "@/mixins/FoundationMixin";
import VendorMixin from "@/mixins/VendorMixin";
export default {
  name: "VendorProductListItemComponent",
  mixins: [FoundationMixin, VendorMixin],
  components: {
    ProductImagesComponent,
    ProductStatusComponent,
    DeleteProductCheckboxComponent
  },
  props: {
    product: {
      type: Object,
      required: true
    },
    enabled_vendors: {
      type: Object,
      required: true
    },
    idx: {
      type: Number,
      required: true
    }
  },
  computed: {
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
      return this.sku;
    },
    mainImageUrl() {
      if (this.product.images) return this.product.images[0].url;
      return null;
    },
    images() {
      return this.product.images[0];
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
