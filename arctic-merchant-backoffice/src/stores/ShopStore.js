export default {
  state: {
    shops: [],
    currentShop: null,
    loadingShops: false
  },

  mutations: {
    START_LODING_SHOPS(state) {
      state.loadingShops = true;
    },

    FINISHED_LOADING_SHOPS(state) {
      state.loadingShops = false;
    },

    SET_CURRENT_SHOP(state, shop) {
      state.currentShop = shop;
    },

    SET_SHOPS(state, shops) {
      state.shops = shops;
    },

    RESET_SHOP_STORE(state) {
      state.shops = [];
      state.currentShop = null;
    }
  },

  getters: {
    currentShop(state) {
      return state.currentShop;
    },

    loadingShops(state) {
      return state.loadingShops;
    },

    shops(state) {
      return state.shops;
    }
  },

  actions: {
    startLoadingShops({ commit }) {
      commit("START_LODING_SHOPS");
    },

    finishedLoadingShops({ commit }) {
      commit("FINISHED_LOADING_SHOPS");
    },

    setCurrentShop({ commit }, shop) {
      commit("SET_CURRENT_SHOP", shop);
    },

    setShops({ commit }, shops) {
      commit("SET_SHOPS", shops);
    }
  }
};
