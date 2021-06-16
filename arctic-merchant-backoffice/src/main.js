import Vue from "vue";
import Toast from "vue-easy-toast";
import Paginate from "vuejs-paginate";
import Spinner from "vue-simple-spinner";
import VTooltip from "v-tooltip";
import Moment from "vue-moment";
import Cookies from "vue-cookies";
import Gravatar from "vue-gravatar";
import { Timeline } from "vue2vis";
import VueMomentsAgo from "vue-moments-ago";
import PictureInput from "vue-picture-input";
import Notifications from "vue-notification";
import Datepicker from "vuejs-datepicker";
import JsonSchemaEditor from "vue-json-ui-editor";

window.console.log("Process env", process.env);

import "@mdi/font/scss/materialdesignicons.scss";

import App from "@/App.vue";
import router from "@/router";
import store from "@/store";
import "@/registerServiceWorker";
import axios from "@/axios";
import VueAxios from "vue-axios";

const storeInstance = store;
const routerInstance = router;

Vue.use(Notifications);

Vue.component("timeline", Timeline);

Vue.component("datepicker", Datepicker);

Vue.component("gravatar", Gravatar);

Vue.component("time-ago", VueMomentsAgo);

Vue.component("picture-input", PictureInput);

Vue.component("json-editor", JsonSchemaEditor);

Vue.use(Cookies);

Vue.use(Moment);

Vue.use(VTooltip);

Vue.use(Toast);

// Use pagination component
Vue.component("paginate", Paginate);

Vue.component("spinner", Spinner);

window.signedOut = false;

window.getParameterByName = (name, url) => {
  if (!url) url = window.location.href;
  name = name.replace(/[[]]/g, "\\$&");
  var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
    results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return "";
  return decodeURIComponent(results[2].replace(/\+/g, ""));
};

// Expose a way to forcefully clear and reset the entire vuex/localStore cache
window.globalLogout = () => {
  if (!window.signedOut) {
    window.signedOut = true;

    routerInstance.push({ path: "/login" });

    if (storeInstance.getters.accessToken) {
      Vue.notify({
        title: "Signed out",
        text: "You have been signed out",
        type: "info",
        group: "global",
        clean: true
      });
    }

    storeInstance.dispatch("resetState");

    // window.location.href = "/#login";
  }
};

window.sleep = seconds => {
  return new Promise(resolve => setTimeout(resolve, seconds * 1000));
};

Vue.use(VueAxios, axios);

Vue.config.productionTip = false;

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount("#app");
