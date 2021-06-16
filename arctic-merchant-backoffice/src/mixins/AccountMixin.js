import AuthenticationMixin from "@/mixins/AuthenticationMixin";

export default {
  mixins: [AuthenticationMixin],

  computed: {
    currentAccountId() {
      if (this.currentAccount) return this.currentAccount.id;
      else return null;
    },

    currentAccount() {
      return this.$store.getters.currentAccount;
    },

    accounts() {
      return this.$store.getters.accounts;
    }
  },

  methods: {
    async loadAccounts() {
      if (!this.$store.getters.loadingAcccounts) {
        this.$store.dispatch("startLoadingAccounts");

        try {
          const response = await this.axios.get("accounts");
          this.$store.dispatch("setAccounts", response.data);
        } finally {
          this.$store.dispatch("finishLoadingAccounts");
        }
      }
    },

    setCurrentAccount(account) {
      window.console.log("Setting current acount", account);
      this.$store.dispatch("setCurrentAccount", account);
    }
  },

  watch: {
    accounts() {
      this.setCurrentAccount(this.accounts[0]);
    }
  },

  mounted() {
    if (!this.currentAccount && !this.accounts.length) {
      this.loadAccounts();
    }
  }
};
