<template>
  <div class="reveal" data-reveal>
    <slot />
  </div>
</template>

<script>
import Foundation from "foundation-sites";
import jquery from "jquery";

export default {
  name: "ProductsMassActionDelete",

  props: {
    reveal: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      instance: null
    };
  },

  methods: {
    confirm() {
      this.$emit("confirm");
    },

    close() {
      this.$emit("close");
    },

    popup() {
      return jquery(this.$el);
    }
  },

  computed: {
    state() {
      return this.reveal ? "open" : "close";
    }
  },

  watch: {
    state() {
      this.popup().foundation(this.state);
    }
  },

  mounted() {
    this.instance = new Foundation.Reveal(this.popup());

    this.popup().on("closed.zf.reveal", () => {
      this.close();
    });
  },

  beforeDestroy() {
    this.popup().foundation("_destroy");
  }
};
</script>
