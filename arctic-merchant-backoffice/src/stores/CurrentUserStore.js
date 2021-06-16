export default {
  state: {
    currentUser: null
  },

  getters: {
    currentUser(state) {
      return state.currentUser;
    }
  },

  mutations: {
    SET_CURRENT_USER(state, user) {
      state.currentUser = user;
    },

    RESET_CURRENT_USER_STORE(state) {
      state.currentUser = null;
    }
  },

  actions: {
    setCurrentUser({ commit }, user) {
      commit("SET_CURRENT_USER", user);
    }
  }
};
