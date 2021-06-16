import Vue from "vue";
import Vuex from "vuex";
import createPersistedState from "vuex-persistedstate";

import AccessTokenStore from "@/stores/AccessTokenStore";
import CurrentUserStore from "@/stores/CurrentUserStore";
import AccountStore from "@/stores/AccountStore";
import ShopStore from "@/stores/ShopStore";
import VendorStore from "@/stores/VendorStore";

Vue.use(Vuex);

export default new Vuex.Store({
  plugins: [createPersistedState()],

  modules: {
    AccessTokenStore,
    CurrentUserStore,
    AccountStore,
    ShopStore,
    VendorStore
  },

  state: {},

  mutations: {},

  getters: {},

  actions: {
    resetState({ commit }) {
      commit("RESET_ACTION_TOKEN_STORE");
      commit("RESET_ACCOUNT_STORE");
      commit("RESET_CURRENT_USER_STORE");
      commit("RESET_SHOP_STORE");
      commit("RESET_VENDOR_STORE");
    }
  }
});
