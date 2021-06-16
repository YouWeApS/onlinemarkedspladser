<template>
  <span>
    <input type="checkbox"
           :id="`${disabled_product}-${disabled_vendor}`"
           v-model=current_value
           @click.prevent.stop="revealPopup = true"
           class="cell shrink">
    <popup-component
            v-if="current_value"
            :reveal="revealPopup"
            @confirm="destroy"
            @close="reset">

      <h1>Do you really want to disable the product?</h1>

      <ul>
        <li>
          Changes can take up to one hour to propagate
        </li>

        <li>
          Updating the product later will reactivate it
        </li>
      </ul>

      <div class="button-group">
        <button
                @click="destroy"
                class="button alert">
          Confirm
        </button>
        <button
                @click="reset"
                class="button secondary">
          Cancel
        </button>
      </div>
    </popup-component>
    <popup-component
            v-else
            :reveal="revealPopup"
            @confirm="update"
            @close="reset">

      <h1>Do you want to enable the product?</h1>

      <div class="button-group">
        <button
                @click="update"
                class="button primary">
          Restore
        </button>
        <button
                @click="reset"
                class="button secondary">
          Cancel
        </button>
      </div>
    </popup-component>

  </span>
</template>

<script>
import PopupComponent from "@/components/PopupComponent";
import VendorMixin from "@/mixins/VendorMixin";
export default {
  name: "DeleteProductCheckboxComponent",
  mixins: [VendorMixin],
  components: {
    PopupComponent
  },
  props: {
    product: {
      type: Object,
      required: true
    },
    disabled_vendor: {
      type: String,
      required: true
    },
    disabled_value: {
      type: Boolean,
      default: false
    },
    disabled_product: {
      type: String,
      required: true
    }
  },

  data() {
    return {
      revealPopup: false,
      current_value: this.disabled_value
    };
  },
  methods: {
    reset() {
      this.revealPopup = false;
    },
    async update() {
      const update_url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.disabled_vendor}/products/${this.disabled_product}`;
      this.product.enabled = true;
      await this.axios.patch(update_url, this.product);
      this.current_value = true;
      if (this.product.master_sku == null) {
        this.$emit("enabled", true);
      }
      this.$notify({
        title: "Saved",
        type: "success",
        group: "product"
      });
      this.reset();
    },
    async destroy() {
      const url = `/accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.disabled_vendor}/products/${this.disabled_product}`;
      this.product.enabled = false;
      await this.axios.patch(url, this.product);
      this.current_value = false;
      if (this.product.master_sku == null) {
        this.$emit("enabled", false);
      }

      this.reset();
    }
  }
};
</script>
