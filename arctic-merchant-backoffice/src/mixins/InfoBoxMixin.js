export default {
  methods: {
    shouldSeeInfoBox(name) {
      return !this.$cookies.get(name);
    },

    dontSeeInfoBox(name) {
      this.$cookies.set(name, 1, -1);
    }
  }
};
