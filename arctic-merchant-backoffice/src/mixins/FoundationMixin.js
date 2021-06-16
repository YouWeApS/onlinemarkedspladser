import $ from "jquery";
import Foundation from "foundation-sites";

export default {
  methods: {
    reflowFoundation(type) {
      Foundation.reInit(type);
    }
  },

  mounted() {
    $(this.$el).foundation();
  }
};
