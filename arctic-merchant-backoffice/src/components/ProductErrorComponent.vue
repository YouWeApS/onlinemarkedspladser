<template>
  <div :class="{ visible: !!errors.length }" class="product-errors">
    <div v-if="errors.length">
      <h2>
        <i class="fa fa-fw fa-exclamation-triangle text-error" />
        Dispersal errors
      </h2>

      <p>
        We where unable to disperse the product because of the following errors.
        Please fix these in the source channel product information or in the form
        below.
      </p>
    </div>

    <p v-if="errors.length > 1">
      <button
        class="button primary"
        @click.prevent="resolveAllErrors"
        :disabled="loading">
        Close and resolve all errors
      </button>
    </p>

    <div
      class="callout alert"
      v-for="e in errors"
      :key="e.id">
      <div>{{ e.message }}</div>
      <pre>{{ e.details }}</pre>

      <div class="grid-x">
        <label class="cell shrink middle">
          <input type="checkbox" name="resolved" v-model="e.resolved">
          <span>I have resolved the problem</span>
        </label>
        <div class="cell shrink">
          <a
            v-if="e.resolved"
            class="button"
            @click="resolveError(e)"
            :disabled="loading">
            Close the error
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import AccountMixin from "@/mixins/AccountMixin";
import ShopMixin from "@/mixins/ShopMixin";
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "ProductErrorComponent",

  mixins: [AccountMixin, ShopMixin, VendorMixin],

  data() {
    return {
      loading: false
    };
  },

  props: {
    product: {
      type: Object,
      required: true
    },

    vendorId: {
      type: String,
      required: true
    }
  },

  methods: {
    async resolveError(error) {
      const options = {
        params: {
          id: error.id,
          vendor_id: this.vendorId
        }
      };

      try {
        this.loading = true;

        await this.axios.delete(
          `accounts/${this.currentAccountId}/shops/${
            this.currentShopId
          }/vendors/${this.currentVendorId}/products/${
            this.product.id
          }/errors/${error.id}`,
          options
        );
      } finally {
        this.loading = false;
      }

      this.$notify({
        title: "Error resolved",
        type: "success",
        group: "product"
      });
    },

    async resolveAllErrors() {
      const options = {
        params: {
          vendor_id: this.vendorId
        }
      };

      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products/${
        this.product.id
      }/errors/destroy_all`;

      try {
        this.loading = true;

        await this.axios.delete(url, options);
      } finally {
        this.loading = false;
      }

      this.$notify({
        title: "All errors resolved",
        type: "success",
        group: "product"
      });
    }
  },

  computed: {
    errors() {
      return this.product.errors;
    }
  }
};
</script>

<style lang="scss" scoped>
pre {
  margin-top: 10px;
  margin-bottom: 20px;
}

.callout {
  label {
    margin-right: 10px;
    cursor: pointer;
  }

  button {
    margin-bottom: 0;
  }

  .grid-x {
    height: 42px;
  }
}

.product-errors {
  visibility: hidden;
  opacity: 0;
  transition: visibility 0s linear 1s, opacity 1s linear;

  &.visible {
    visibility: visible;
    opacity: 1;
    transition-delay: 0s;
  }
}
</style>
