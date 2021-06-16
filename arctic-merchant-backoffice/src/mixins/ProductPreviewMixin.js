export default {
  methods: {
    async productPreview(vendorId, sku) {
      const response = await this.axios.get(
        `vendors/${vendorId}/products/${sku}/preview`
      );
      return response.data;
    }
  }
};
