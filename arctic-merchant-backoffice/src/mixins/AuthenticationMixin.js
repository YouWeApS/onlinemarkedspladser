export default {
  computed: {
    currentUser() {
      return this.$store.getters.currentUser;
    },

    accessToken() {
      return this.$store.getters.accessToken;
    },

    isSignedIn() {
      return !!this.currentUser;
    }
  },

  methods: {
    // TODO: Find a way to prevent race conditions between multiple components
    //       implementing this mixin. They potentially call the /me endpoint
    //       one time each because the code is executed async which means the
    //       currentUser isn't set when they call the currentUser object.
    async getCurrentUser() {
      try {
        const response = await this.axios.get("me");
        this.$store.dispatch("setCurrentUser", response.data);
        window.signedOut = false;
      } catch (e) {
        console.log("getCurrentUser ERROR", e);
        // Handlex by @/axios
      }
    }
  },

  watch: {
    accessToken() {
      this.getCurrentUser();

      this.axios.defaults.headers.common["Authorization"] =
        "Bearer " + this.$store.getters.accessToken;
    }
  },

  async beforeRouteEnter(to, from, next) {
    if (to.meta && to.meta.requiresAuthentication) {
      // window.console.log('Transition to', to);
      // window.console.log('Transition from', from);
      next(async vm => await vm.getCurrentUser());
    } else {
      next();
    }
  },

  async beforeRouteUpdate(to, from, next) {
    if (to.meta && to.meta.requiresAuthentication) {
      // window.console.log('Transition to', to);
      // window.console.log('Transition from', from);
      // await this.getCurrentUser();
    }
    next();
  }
};
