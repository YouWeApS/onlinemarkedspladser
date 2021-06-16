<template>
  <span>
    <button
      @click.prevent.stop="revealPopup = true"
      class="button alert">
      Disable product
    </button>

    <!-- Delete confirmation -->
    <popup-component
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
  </span>
</template>

<script>
import PopupComponent from "@/components/PopupComponent";
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "DeleteProductButtonComponent",

  mixins: [VendorMixin],

  components: {
    PopupComponent
  },

  props: {
    product: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      revealPopup: false
    };
  },

  methods: {
    reset() {
      this.revealPopup = false;
    },

    async destroy() {
      const url = `/accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products/${this.product.id}`;

      await this.axios.delete(url);
      this.product.deleted_at = new Date().toUTCString();
    }
  }
};
</script>
