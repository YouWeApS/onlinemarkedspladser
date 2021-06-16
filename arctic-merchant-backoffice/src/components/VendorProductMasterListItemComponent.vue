<template>
 <tbody>
    <tr :id="`product-${product_master.id}`">
        <td>
            <div class="text-center">
                <i
                        class="fal fa-fw fa-chevron-down"
                        aria-hidden="true"
                        @click="show_variables"
                        v-show="show_var"
                        v-if="(Object.keys(product_master.variants).length > 1 && product_master.master_sku == null)">
                </i>

                <transition name="fade">
                    <div key="3" v-show="!show_var" class="user-expanded-options">
                        <i class="fal fa-fw fa-chevron-up" aria-hidden="true" @click="hide_variables"></i>
                    </div>
                </transition>
            </div>
        </td>
        <td v-if="shouldDisplayStatus" class="text-center">
            <product-status-component :product="product_master" />
        </td>
        <td class="text-center">
            <router-link :to="`/products/${product_master.id}`">
                <div class="cell small-12 medium-3">
                    <img :src="mainImageUrl" class="main">
                </div>
            </router-link>
        </td>

        <td>
            <router-link :to="`/products/${product_master.id}`">
                SKU: {{ product_master.sku }}

                <br>

                <span>
          EAN: {{ product_master.ean }}
        </span>

                <br>

                <span>
          {{ product_master.name }}
        </span>
            </router-link>
        </td>

        <td
            v-for="vendor in vendors"
            :key="vendor.key">
                <delete-product-checkbox-component
                        v-on:enabled="console.log($event)"
                        :product="product_master"
                        :disabled_vendor="vendor.id"
                        :disabled_value="enabled_vendors[vendor.name][0]"
                        :disabled_product="enabled_vendors[vendor.name][1]">

                </delete-product-checkbox-component>

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
                        :title="product_master.updated_at"
                        prefix=""
                        suffix="ago"
                        :date="product_master.updated_at" />
            </small>
        </td>
    </tr>
        <vendor-product-list-item-component
                v-for="(prod, idx) in products"
                v-show="!show_var"
                :key="prod.sku"
                :product="prod"
                :enabled_vendors="prod.enabled_for_vendors"
                :idx="idx"
                v-if="products.length" />
 </tbody>
</template>

<script>
import VendorProductListItemComponent from "@/components/VendorProductListItemComponent";
import ProductImagesComponent from "@/components/ProductImagesComponent";
import ProductStatusComponent from "@/components/ProductStatusComponent";
import DeleteProductCheckboxComponent from "@/components/DeleteProductCheckboxComponent";
import FoundationMixin from "@/mixins/FoundationMixin";
import VendorMixin from "@/mixins/VendorMixin";
import ProductMixin from "@/mixins/ProductMixin";
export default {
  name: "VendorProductMasterListItemComponent",
  mixins: [FoundationMixin, VendorMixin, ProductMixin],
  components: {
    VendorProductListItemComponent,
    ProductImagesComponent,
    ProductStatusComponent,
    DeleteProductCheckboxComponent
  },
  props: {
    product_master: {
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

  methods: {
    async hide_variables() {
      this.show_var = true;
    },

    async show_variables() {
      this.show_var = false;

      try {
        const product_variables = {
          master_id: this.product_master.sku
        };
        await this.loadProducts(product_variables);
        this.$router.replace({
          path: "/products_vendors",
          query: product_variables
        });
      } catch (e) {
        console.log(e);
      }
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
      if (this.product_master.images[0])
        return this.product_master.images[0].url;
      return null;
    },
    images() {
      return this.product_master.images[0];
    }
  }
};
</script>

<style lang="scss" scoped>
.has-tooltip {
  font-weight: 300;
  border: none;
}
.main {
  max-width: 150px;
}
</style>
