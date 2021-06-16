import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "OrderMixin",

  mixins: [VendorMixin],

  data() {
    return {
      orders: [],
      order: null
    };
  },

  watch: {
    currentVendorId() {
      this.loadOrders();
    }
  },

  methods: {
    async loadOrders(params) {
      if (this.currentShopId) {
        const url = `accounts/${this.currentAccountId}/shops/${
          this.currentShopId
        }/vendors/${this.currentVendorId}/orders`;

        const response = await this.axios.get(url, {
          params
        });
        this.orders = response.data;
      }
    },

    async loadOrder(id) {
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/orders/${id}`;

      const response = await this.axios.get(url);

      this.order = response.data;
    }
  }
};
