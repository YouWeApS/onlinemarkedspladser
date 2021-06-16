export default {
  state: {
    vendors: [],
    currentVendor: null,
    loadingVendors: false
  },

  mutations: {
    START_LOADING_VENDORS(state) {
      state.loadingVendors = true;
    },

    FINISH_LOADING_VENDORS(state) {
      state.loadingVendors = false;
    },

    SET_CURRENT_VENDOR(state, vendor) {
      state.currentVendor = vendor;
    },

    SET_VENDORS(state, vendors) {
      state.vendors = vendors;
    },

    RESET_VENDOR_STORE(state) {
      state.vendors = [];
      state.currentVendor = null;
    }
  },

  getters: {
    loadingVendors(state) {
      return state.loadingVendors;
    },

    currentVendor(state) {
      return state.currentVendor;
    },

    vendors(state) {
      return state.vendors;
    }
  },

  actions: {
    startLoadingVendors({ commit }) {
      commit("START_LOADING_VENDORS");
    },

    finishLoadingVendors({ commit }) {
      commit("FINISH_LOADING_VENDORS");
    },

    setCurrentVendor({ commit }, vendor) {
      commit("SET_CURRENT_VENDOR", vendor);
    },

    setVendors({ commit }, vendors) {
      commit("SET_VENDORS", vendors);
    }
  }
};
