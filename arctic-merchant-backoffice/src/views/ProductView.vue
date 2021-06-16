<template>
  <div class="grid-x">
    <notifications
      group="product"
      position="top center" />

    <spinner v-if="loading" />

    <div class="cell small-12 medium-11">
      <div v-if="product">
        <h1>
          <product-status-component
            :product="product"
            :forceDisplay="true" />
          {{
            product.name ||
            product.preview.name ||
            product.sku ||
            product.preview.sku ||
            "Unnamed product"
          }}
          for {{ currentVendor.name }}
        </h1>

        <nav aria-label="You are here:" role="navigation">
          <ul class="breadcrumbs">
            <li>
              <router-link to="/products">
                Products
              </router-link>
            </li>
            <li
              v-if="product.preview.master_sku"
              class="click-select-all">
              <router-link :to="`/products/${product.master_id}`">
                {{ product.preview.master_sku }}
              </router-link>
            </li>
            <li class="click-select-all">
              {{ product.preview.sku }}
            </li>
          </ul>
        </nav>

        <p>
          Last dispersed at:
          <time-ago
            data-tooltip
            class="has-tooltip"
            :title="product.last_dispersed_at"
            prefix=""
            suffix="ago"
            :date="product.last_dispersed_at"
            v-if="product.last_dispersed_at" />
          <span v-else>Never</span>

          (
            Last updated:
            <time-ago
              data-tooltip
              class="has-tooltip"
              :title="product.last_updated_at || product.created_at"
              prefix=""
              suffix="ago"
              :date="product.last_updated_at || product.created_at" />
          )

            <button class="button primary"
              @click="send_update">
              Update
            </button>
        </p>

        <div class="callout alert" v-if="product.deleted_at">
          This product was disabled on {{ product.deleted_at }}. If you update the product it will be restored.
        </div>

        <div class="card">
          <div class="card-section">
            <div class="grid-x grid-margin-x">
              <div :class="containerClass">
                <!-- Product errors -->
                <product-error-component
                  :product="product"
                  :vendorId="currentVendorId" />

                <!-- Product schema-match errors -->
                <product-match-error-component
                  :errors="product.match_errors" />

                <!-- Product shadow details -->
                <product-shadow-form-component
                  :product="product"
                  :vendor="currentVendor" />
              </div>

              <product-variants-list-component :product="product" />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ProductMixin from "@/mixins/ProductMixin";
import VendorMixin from "@/mixins/VendorMixin";
import ProductErrorComponent from "@/components/ProductErrorComponent";
import ProductStatusComponent from "@/components/ProductStatusComponent";
import ProductMatchErrorComponent from "@/components/ProductMatchErrorComponent";
import ProductShadowFormComponent from "@/components/ProductShadowFormComponent";
import ProductVariantsListComponent from "@/components/ProductVariantsListComponent";

export default {
  name: "ProductDetailsView",

  mixins: [ProductMixin, VendorMixin],

  components: {
    ProductErrorComponent,
    ProductMatchErrorComponent,
    ProductStatusComponent,
    ProductShadowFormComponent,
    ProductVariantsListComponent
  },

  data() {
    return {
      loading: true
    };
  },

  methods: {
    async send_update() {
      const syncParams = {
        sync: true
      };

      const params = Object.assign(syncParams, this.product);
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendor.id}/products/${this.product.id}`;

      await this.axios.patch(url, params);

      this.$notify({
        title: "Updated",
        type: "success",
        group: "product"
      });
    }
  },

  computed: {
    master_sku() {
      if (this.product) return this.product.master_sku;
      else return null;
    },

    sku() {
      return this.$route.params.sku;
    },

    vendorId() {
      if (this.vendor) return this.vendor.id;
      return null;
    },

    containerClass() {
      var classString = "cell";
      classString += Object.keys(this.product.variants || {}).length
        ? "medium-9 large-9 xlarge-9"
        : "";
      return classString;
    }
  },

  watch: {
    async sku() {
      try {
        await this.loadProduct(this.sku);
      } finally {
        this.loading = false;
      }
    },

    async currentVendorId() {
      this.$router.push({ path: "/products" });
    }
  },

  async mounted() {
    try {
      await this.loadProduct(this.sku);
    } catch (e) {
      window.location.href = "/";
    } finally {
      this.loading = false;
    }

    this.subscribeToChanges();
  }
};
</script>

<style lang="scss" scoped>
select {
  margin-bottom: 0;
}
</style>
