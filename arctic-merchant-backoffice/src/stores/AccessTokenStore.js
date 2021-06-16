export default {
  state: {
    accessToken: null
  },

  mutations: {
    SET_ACCESS_TOKEN(state, token) {
      state.accessToken = token;
    },

    RESET_ACTION_TOKEN_STORE(state) {
      state.accessToken = null;
    }
  },

  getters: {
    accessToken(state) {
      return state.accessToken;
    }
  },

  actions: {
    setAccessToken({ commit }, token) {
      commit("SET_ACCESS_TOKEN", token);
    }
  }
};
