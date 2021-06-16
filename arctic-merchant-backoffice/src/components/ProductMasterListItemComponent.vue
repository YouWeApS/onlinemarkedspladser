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
      <td>
        <router-link :to="`/products/${product_master.id}`">
          <img :src="mainImageUrl" class="main">
        </router-link>
      </td>
      <td>
        <router-link :to="`/products/${product_master.id}`">
          {{ product_master.sku }}
        </router-link>
      </td>
      <td>
        <router-link :to="`/products/${product_master.id}`">
          {{ product_master.name }}
        </router-link>
      </td>
      <td>
        <router-link :to="`/products/${product_master.id}`">
          {{ product_master.ean }}
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
            :title="product_master.updated_at"
            prefix=""
            suffix="ago"
            :date="product_master.updated_at" />
        </small>
      </td>
      <td>
        <delete-product-checkbox-component
          v-on:enabled="enabled"
          :product="product_master"
          :disabled_vendor="product_master.vendor_id"
          :disabled_value="product_master.enabled"
          :disabled_product="product_master.id"/>
      </td>
    </tr>
    <product-list-item-component
      v-show="!show_var"
      v-for="(prod, idx) in products"
      :key="prod.sku"
      :product="prod"
      :idx="idx" />
  </tbody>
</template>

<script>
import ProductListItemComponent from "@/components/ProductListItemComponent";
import ProductStatusComponent from "@/components/ProductStatusComponent";
import DeleteProductCheckboxComponent from "@/components/DeleteProductCheckboxComponent";
import FoundationMixin from "@/mixins/FoundationMixin";
import VendorMixin from "@/mixins/VendorMixin";
import ProductMixin from "@/mixins/ProductMixin";

export default {
  name: "ProductMasterListItemComponent",

  mixins: [FoundationMixin, VendorMixin, ProductMixin],

  components: {
    ProductStatusComponent,
    ProductListItemComponent,
    DeleteProductCheckboxComponent
  },

  props: {
    product_master: {
      type: Object,
      required: true
    },

    idx: {
      type: Number,
      required: true
    }
  },

  methods: {
    enabled() {
      // this.show_variables();
    },

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
          path: "/products",
          query: product_variables
        });
      } catch (e) {
        console.log(e);
      }
    }
  },

  computed: {
    mainImageUrl() {
      if (this.product_master.images[0])
        return this.product_master.images[0].url;
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
          return this.product_master.last_dispersed_at;
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
.main {
  max-width: 150px;
}
</style>
