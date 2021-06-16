import AccountMixin from "@/mixins/AccountMixin";
import ShopMixin from "@/mixins/ShopMixin";

export default {
  mixins: [AccountMixin, ShopMixin],

  computed: {
    currentVendorId() {
      if (this.currentVendor) return this.currentVendor.id;
      return null;
    },

    currentVendor() {
      return this.$store.getters.currentVendor;
    },

    vendors() {
      return this.$store.getters.vendors;
    }
  },

  methods: {
    loadVendor(id) {
      const vendor = this.vendors.filter(v => v.id === id)[0];
      this.setCurrentVendor(vendor);
    },

    async loadVendors(page) {
      if (!this.$store.getters.loadingVendors) {
        window.console.log("Loading vendors..");

        try {
          this.$store.dispatch("startLoadingVendors");

          if (!page) page = 1;

          if (!this.currentAccountId || !this.currentShopId) {
            return null;
          }

          const url = `accounts/${this.currentAccountId}/shops/${
            this.currentShopId
          }/vendors`;

          const params = {
            page
          };

          const response = await this.axios.get(url, params);
          this.$store.dispatch("setVendors", response.data);
        } finally {
          this.$store.dispatch("finishLoadingVendors");
        }
      }
    },

    setCurrentVendor(vendor) {
      this.$store.dispatch("setCurrentVendor", null);
      this.$store.dispatch("setCurrentVendor", vendor);
    }
  },

  watch: {
    currentShopId() {
      this.loadVendors();
    },

    vendors() {
      this.setCurrentVendor(this.vendors[0]);
    }
  },

  mounted() {
    if (this.currentShop && !this.currentVendor) this.loadVendors();
  }
};
