<!-- eslint-disable vue/no-use-v-if-with-v-for -->

<template>
  <section class="grid-x" v-if="currentVendor">
    <div class="cell small-11">
      <h1>Products for
          <span class="blue-bold-text">{{ currentVendor.name }}</span></h1>

      <div class="card">
        <div class="card-section ">
          <form
            class="grid-x align-middle grid-padding-x"
            :disabled="loading"
            @submit.prevent="reloadPages">

            <input
              type="search"
              name="search"
              v-model="filters.search"
              placeholder="Search"
              class="cell shrink"
              autocomplete="search"
              :disabled="loading" />

            <span class="spacer" />

            <div class="cell shrink pagination-container">
              <paginate
                v-model="filters.page"
                :page-count="Math.ceil(parseInt(totalProductsCount, 10) / Math.ceil(parseInt(filters.per_page, 10)))"
                :click-handler="paginationChange"
                prev-text="Prev"
                next-text="Next"
                container-class="pagination" />
            </div>

            <span class="spacer" />

            <label class="cell shrink middle align-right">
              State
            </label>

            <div class="cell shrink">
              <select
                v-model="filters.state"
                :disabled="loading">
                <option value="null">All</option>
                <option value="dispersed">Dispersed</option>
                <option value="erroneous">Erroneous</option>
              </select>
            </div>

            <span class="spacer" />

            <label
              for="removed"
              class="middle">
              Deleted
            </label>

            <div class="cell shrink">
              <select
                v-model="filters.removed"
                :disabled="loading"
                id="removed" >
                  <option value="">Not deleted</option>
                  <option value="true">Deleted</option>
                  <option value="false">All</option>
              </select>
            </div>

            <span class="spacer" />

            <label class="cell shrink middle align-right">
              Enabled
            </label>

            <div class="cell shrink">
              <select
                v-model="filters.disabled"
                :disabled="loading">
                <option value="null">All</option>
                <option value="enabled">Enabled</option>
                <option value="disabled">Disabled</option>
              </select>
            </div>

            <span class="spacer-extra" />

            <div class="cell shrink">
              <select v-model="filters.per_page">
                <option value="20">20</option>
                <option value="50">50</option>
                <option value="100">100</option>
                <option value="250">250</option>
              </select>
            </div>
          </form>

          <table class="hover stack">
            <thead>
              <tr>
                <th></th>
                <th width="60" v-if="shouldDisplayStatus">Status</th>
                <th></th>
                <th>SKU</th>
                <th>Name</th>
                <th>EAN</th>
                <th>Last {{ vendorType }}</th>
                <th>Enabled</th>
              </tr>
            </thead>

            <tbody>
              <tr v-if="loading">
                <td colspan="4">
                  <spinner size="md" />
                </td>
              </tr>

              <tr v-if="!loading && !products.length">
                <td colspan="4">
                  No products found
                </td>
              </tr>

            </tbody>
            <product-master-list-item-component
              v-for="(prod, idx) in products"
              :key="prod.sku"
              :product_master="prod"
              :idx="idx"
              v-if="!loading && products.length" />
          </table>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import AuthenticationMixin from "@/mixins/AuthenticationMixin";
import Paginate from "vuejs-paginate";
import ProductMasterListItemComponent from "@/components/ProductMasterListItemComponent";
import ProductMixin from "@/mixins/ProductMixin";

export default {
  name: "ProductsListView",

  mixins: [AuthenticationMixin, ProductMixin],

  components: {
    Paginate,
    ProductMasterListItemComponent
  },

  data() {
    return {
      inputTimeout: null,
      loading: false,
      filters: Object.assign(
        {
          status: null,
          sort_direction: "asc",
          sort_by: "sku",
          search: null,
          removed: "",
          state: null,
          disabled: null,
          per_page: 20,
          page: 1
        },
        this.$route.query
      )
    };
  },

  watch: {
    filters: {
      handler() {
        if (parseInt(this.filters.page, 10) !== this.filters.page) {
          this.filters.page = parseInt(this.filters.page, 10);
        }

        if (this.inputTimeout) clearTimeout(this.inputTimeout);
        this.inputTimeout = setTimeout(this.reloadPages, 600);
      },
      deep: true
    },

    currentVendorId() {
      this.reloadPages();
    }
  },

  computed: {
    vendorType() {
      return this.currentVendor.type;
    },

    shouldDisplayStatus() {
      return this.currentVendor.type !== "collection";
    },

    trimmedFilter() {
      const h = {};

      for (var i = Object.keys(this.filters).length - 1; i >= 0; i--) {
        const k = Object.keys(this.filters)[i];
        const v = this.filters[k];
        if (k && v) h[k] = v;
      }

      return h;
    },

    getMasterProductsOnly() {
      return Object.assign({ master: true }, this.trimmedFilter);
    }
  },

  methods: {
    paginationChange(page) {
      this.filters.page = page;
    },

    async reloadPages() {
      this.loading = true;

      try {
        await this.loadProducts(this.getMasterProductsOnly);
        this.$router.replace({
          path: "/products",
          query: this.getMasterProductsOnly
        });
      } catch (e) {
        console.log(e);
      } finally {
        this.$nextTick(() => {
          this.loading = false;
        });
      }
    }
  },

  async mounted() {
    await this.reloadPages();
  }
};
</script>

<style scoped lang="scss">
input[type="checkbox"].cell {
  margin-left: 10px;
  margin-right: 5px;
  margin-bottom: 20px;
}

.spacer {
  width: 30px;
}

.spacer-extra {
  flex-grow: 1;
}
</style>
