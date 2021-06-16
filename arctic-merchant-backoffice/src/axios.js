import axios from "axios";
import store from "@/store";
import Qs from "qs";

// Global axios defaults
axios.defaults.baseURL = process.env.VUE_APP_API_BASE_URL;

// If we have the Authorization header in the $store, use it
axios.defaults.headers.common["Authorization"] =
  "Bearer " + store.getters.accessToken;

// Only send and accept javascript
axios.defaults.headers.common["Accept"] = "application/json";
axios.defaults.headers.common["Content-Type"] = "application/json";

// Format nested params correctly
axios.interceptors.request.use(config => {
  config.paramsSerializer = params => {
    return Qs.stringify(params, {
      arrayFormat: "brackets",
      encode: false
    });
  };

  return config;
});

// const extractErrorMessage = (error, msg) => {
//   if (!msg) msg = error.response.data.error;

//   if (error.response.headers["x-request-id"]) {
//     msg = msg.concat(`<br>Error ID: ${error.response.headers["x-request-id"]}`);
//   }

//   return msg;
// };

const displayNotification = () => {
  // const defaultOptions = {
  //   title: "Error",
  //   message: extractErrorMessage(error, msg),
  //   type: "error",
  //   dangerouslyUseHTMLString: true
  // };
  // const newOptions = Object.assign(defaultOptions, options);
  // Notification(newOptions);
};

axios.interceptors.response.use(undefined, error => {
  window.console.error("Axios request error:", error.response.data.error);

  if (401 === error.response.status) window.globalLogout();

  if (403 === error.response.status) {
    displayNotification(error);
  }

  if (400 === error.response.status) {
    const regex = /Validation [^:]+: /gi;
    const msg = error.response.data.error.replace(regex, "");
    displayNotification(error, msg);
  }

  if (500 === error.response.status) {
    displayNotification(error, null, {
      duration: 0
    });
  }

  return Promise.reject(error);
});

export default axios;
