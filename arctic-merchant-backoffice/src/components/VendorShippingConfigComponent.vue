<template>
  <div>
    <div class="grid-x">
      <div class="cell small-12 medium-8">
        <shipping-maps-component />
      </div>
    </div>
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";
import ProductMixin from "@/mixins/ProductMixin";
import InfoBoxComponent from "@/components/InfoBoxComponent";
import ShippingMapsComponent from "@/components/ShippingMapsComponent";

export default {
  name: "VendorAuthConfigFormComponent",

  mixins: [VendorMixin, ProductMixin],

  components: {
    InfoBoxComponent,
    ShippingMapsComponent
  },

  data() {
    return {
      schema: null,
      config: null
    };
  },

  methods: {
    async forceImport() {
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/config`;

      const response = await this.axios.patch(url, {
        force_import: true
      });

      this.$notify({
        title: "We will sync your products soon",
        type: "success",
        group: "global"
      });

      await this.loadVendors();
      this.setCurrentVendor(response.data);
    },

    async submit(e) {
      e.preventDefault();
      e.stopPropagation();

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/config`;

      const response = await this.axios.patch(url, {
        product_parse_config: this.config
      });

      await this.loadVendors();
      this.setCurrentVendor(response.data);
    }
  }
};
</script>

<style lang="scss">
@import "../../node_modules/foundation-sites/scss/foundation";
@include foundation-xy-grid-classes();

.product-config-form {
  .sub {
    @extend .grid-x;
  }

  .sub-title {
    @extend .cell;
    @extend .small-12;
    @extend .medium-9;
    @extend .medium-offset-3;
  }

  .json-editor-row {
    @extend .cell;

    label {
      @extend .grid-x;

      span {
        line-height: 36px;
        text-align: right;
        padding-right: 5px;
        @extend .cell;
        @extend .small-12;
        @extend .medium-3;
      }

      input {
        @extend .cell;
        @extend .small-12;
        @extend .medium-9;
      }
    }
  }
}
</style>
