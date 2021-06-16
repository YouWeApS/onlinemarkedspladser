export default {
  state: {
    accounts: [],
    currentAccount: null,
    loadingAccounts: false
  },

  mutations: {
    START_LOADING_ACCOUNTS(state) {
      state.loadingAccounts = true;
    },

    FINISH_LOADING_ACCOUNTS(state) {
      state.loadingAccounts = true;
    },

    SET_CURRENT_ACCOUNT(state, account) {
      state.currentAccount = account;
    },

    SET_ACCOUNTS(state, accounts) {
      state.accounts = accounts;
    },

    RESET_ACCOUNT_STORE(state) {
      state.accounts = [];
      state.currentAccount = null;
    }
  },

  getters: {
    loadingAccounts(state) {
      return state.loadingAccounts;
    },

    currentAccount(state) {
      return state.currentAccount;
    },

    accounts(state) {
      return state.accounts;
    }
  },

  actions: {
    startLoadingAccounts({ commit }) {
      commit("START_LOADING_ACCOUNTS");
    },

    finishLoadingAccounts({ commit }) {
      commit("FINISH_LOADING_ACCOUNTS");
    },

    setCurrentAccount({ commit }, account) {
      commit("SET_CURRENT_ACCOUNT", account);
    },

    setAccounts({ commit }, accounts) {
      commit("SET_ACCOUNTS", accounts);
    }
  }
};
