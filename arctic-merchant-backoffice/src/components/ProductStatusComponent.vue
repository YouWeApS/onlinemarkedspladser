<template>
  <i
    class="has-tooltip fal"
    :class="iconClass"
    data-tooltip
    :title="message" />
</template>

<script>
export default {
  name: "ProductStatusComponent",

  props: {
    product: {
      type: Object,
      required: true
    }
  },

  computed: {
    message() {
      switch (this.state) {
        case "pending":
          return "This product is pending dispersal";

        case "failed":
          var msg = "This product failed to disperse correctly.";
          if (this.failed) msg = `${msg} Please review errors.`;
          return msg;

        case "inprogress":
          return "This product is currently being dispersed";

        case "completed":
          return "This product is in-sync";

        case "missmatched":
          return "This product doesn't match marketplace specifications. Please review.";

        case "deleted":
          return "This product has been deleted. It will not be synchronized.";
      }

      return null;
    },

    iconClass() {
      switch (this.state) {
        case "pending":
          return "fa-hourglass-half";

        case "inprogress":
          return "fa-spinner fa-spin";

        case "missmatched":
          return "fa-exclamation-triangle text-warning";

        case "failed":
          return "fa-exclamation-triangle text-error";

        case "deleted":
          return "fa-trash text-error";
      }

      return null;
    },

    state() {
      var state = this.product.dispersal_state;
      if (this.missmatched) state = "missmatched";
      if (this.failed) state = "failed";
      if (!state) state = "pending";
      if (this.product.deleted_at) state = "deleted";
      return state;
    },

    missmatched() {
      return (
        this.product.missmatched ||
        (this.product.match_errors && this.product.match_errors.length > 0)
      );
    },

    failed() {
      return (
        this.product.erroneous ||
        (this.product.errors && this.product.errors.length > 0)
      );
    }
  }
};
</script>

<style scoped lang="scss">
.has-tooltip {
  border: none;
}
</style>
