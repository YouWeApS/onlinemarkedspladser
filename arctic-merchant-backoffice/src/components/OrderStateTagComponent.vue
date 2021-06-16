<template>
  <span v-if="order">
    <span
      v-for="(status, i) in statuses"
      :key="i">

      <tag-component
        :value="status_value(status)"
        :title="status_explenation(status)"
        :additionalClasses="status_class(status)" />
    </span>
  </span>
</template>

<script>
import TagComponent from "@/components/TagComponent";

export default {
  name: "OrderStateTagComponent",

  components: {
    TagComponent
  },

  props: {
    order: {
      type: Object,
      required: true
    },

    showOnly: {
      type: String,
      default: "all"
    }
  },

  computed: {
    statuses() {
      if (this.partial) {
        return [this.order.status[0]];
      } else {
        return this.order.status;
      }
    },

    partial() {
      return (
        this.showOnly === "leastSignificant" && this.order.status.length > 1
      );
    }
  },

  methods: {
    status_explenation(status) {
      switch (status) {
        case "partial":
          return "Some of the order has been processed. But not all of the order is in the same state.";

        case "created":
          return "The order has been received but not shipped";

        case "shipped":
          return "The order has been shipped and we're awaiting payment";

        case "invoiced":
          return "The order has been invoiced";

        case "completed":
          return "Payment has been received and the order is completed";
      }
    },

    status_class(status) {
      if (this.partial) return "warning";

      switch (status) {
        case "created":
          return "secondary";

        case "shipped":
          return "primary";

        case "invoiced":
        case "completed":
          return "success";
      }
    },

    status_value(status) {
      if (this.showOnly === "leastSignificant") return `partially ${status}`;
      return status;
    }
  }
};
</script>
