import AccountMixin from "@/mixins/AccountMixin";

export default {
  mixins: [AccountMixin],

  computed: {
    currentShopId() {
      if (this.currentShop) return this.currentShop.id;
      else return null;
    },

    currentShop() {
      return this.$store.getters.currentShop;
    },

    shops() {
      return this.$store.getters.shops;
    }
  },

  methods: {
    async loadShops(page) {
      if (!this.$store.getters.loadingShops) {
        try {
          this.$store.dispatch("startLoadingShops");

          if (!page) page = 1;

          const url =
            process.env.VUE_APP_API_BASE_URL +
            "/accounts/" +
            this.currentAccount.id +
            "/shops";

          const params = {
            page
          };

          const response = await this.axios.get(url, params);
          this.$store.dispatch("setShops", response.data);
        } finally {
          this.$store.dispatch("finishedLoadingShops");
        }
      }
    },

    setCurrentShop(shop) {
      this.$store.dispatch("setCurrentShop", null);
      this.$store.dispatch("setCurrentShop", shop);
    }
  },

  watch: {
    currentAccount() {
      if (this.currentAccount) this.loadShops();
    },

    shops() {
      this.setCurrentShop(this.shops[0]);
    }
  },

  mounted() {
    if (this.currentAccount && !this.currentShop) this.loadShops();
  }
};
