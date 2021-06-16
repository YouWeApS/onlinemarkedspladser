import ActionCable from "actioncable";
import VendorMixin from "@/mixins/VendorMixin";

export default {
  mixins: [VendorMixin],

  data() {
    return {
      products: [],
      show_var: true,
      currentProductPage: this.$route.query.page || 1,
      totalProductsCount: 0,
      product: null,
      subscription: null
    };
  },

  methods: {
    async deleteProduct(product) {
      const id = product.shadow_product_id || product.id;

      const url = `/accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products/${id}`;

      await this.axios.delete(url);

      const idx = this.products.indexOf(product);
      if (idx >= 0) this.products.splice(idx, 1);
    },

    async updateProduct(product, data) {
      const url = `/accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products/${product.shadow_product_id}`;

      const response = await this.axios.patch(url, data);
      const newProduct = response.data;

      // If the product has been restored remove it from the current list
      if (product.deleted_at && !newProduct.deleted_at) {
        const idx = this.products.indexOf(product);
        if (idx >= 0) this.products.splice(idx, 1);
      }
    },

    async loadProduct(id) {
      // Prevent loading products unless we have all the necesary data
      if (!this.currentVendorId) return null;

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products/${id}`;

      const response = await this.axios.get(url);

      this.product = response.data;
    },

    async loadProducts(newParams) {
      // Prevent loading products unless we have all the necesary data
      if (!this.currentVendorId) return null;

      const defaultParams = {
        page: this.currentProductPage
      };

      const params = Object.assign(defaultParams, newParams);

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products`;

      const response = await this.axios.get(url, { params });

      this.currentProductPage = parseInt(response.headers.page, 10);
      this.totalProductsCount = parseInt(response.headers.total, 10);

      this.products = response.data;
    },

    subscribeToChanges() {
      const url =
        process.env.VUE_APP_API_WS_URL +
        "?access_token=" +
        this.$store.getters.accessToken;

      const connection = ActionCable.createConsumer(url);

      const options = {
        channel: "ProductsChannel"
      };

      const callbacks = {
        connected: () => {
          window.console.log("Subscribed to live product changes");
        },

        received: product => {
          window.console.log("Received product update for", product.id);
          window.console.log(product);

          if (product.vendor_id && product.vendor_id !== this.currentVendorId) {
            window.console.log(
              "Product update isn't for this vendor. Skipping."
            );
            return false;
          }

          const products = this.products;
          const old_prod = products.filter(p => p.id === product.id)[0];
          const idx = products.indexOf(old_prod);

          if (idx >= 0) {
            window.console.log("Replacing product in collection");
            products[idx] = product;
            this.products = []; // Required to trigger computed values
            this.products = products;
          }

          if (this.product && product.id === this.product.id) {
            window.console.log("Replacing single product");
            this.product = null;
            this.product = product;

            this.$notify({
              title: "Updated",
              type: "success",
              group: "product"
            });
          }
        }
      };

      this.subscription = connection.subscriptions.create(options, callbacks);
    }
  },

  beforeDestroy() {
    if (this.subscription) this.subscription.unsubscribe();
  }
};
