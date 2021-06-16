import Vue from "vue";
import Router from "vue-router";
import ProductsListView from "@/views/ProductsListView";
import ProductView from "@/views/ProductView";
import ProductsVendorsListView from "@/views/ProductsVendorsListView";
import LoginView from "@/views/LoginView";
import ProfileView from "@/views/ProfileView";
import OrdersView from "@/views/OrdersView";
import OrderView from "@/views/OrderView";
import CategoriesView from "@/views/CategoriesView";
import ConfigurationEditView from "@/views/ConfigurationEditView";
import RecoverPasswordView from "@/views/RecoverPasswordView";
import ResetPasswordView from "@/views/ResetPasswordView";

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: "/",
      component: ProductsListView,
      meta: {
        requiresAuthentication: true
      }
    },
    {
      path: "/products",
      component: ProductsListView,
      meta: {
        requiresAuthentication: true
      }
    },

    {
      path: "/products/:sku",
      component: ProductView,
      meta: {
        requiresAuthentication: true
      }
    },
    {
      path: "/products_vendors",
      component: ProductsVendorsListView,
      meta: {
        requiresAuthentication: true
      }
    },

    {
      path: "/profile",
      component: ProfileView,
      meta: {
        requiresAuthentication: true
      }
    },

    {
      path: "/categories",
      component: CategoriesView,
      meta: {
        requiresAuthentication: true
      }
    },

    {
      path: "/orders",
      component: OrdersView,
      meta: {
        requiresAuthentication: true
      }
    },

    {
      path: "/orders/:id",
      component: OrderView,
      meta: {
        requiresAuthentication: true
      }
    },

    {
      path: "/configure",
      component: ConfigurationEditView,
      meta: {
        requiresAuthentication: true
      }
    },

    {
      path: "/login",
      component: LoginView,
      meta: {
        storeRedirectLocation: false
      }
    },

    {
      path: "/recover-password",
      component: RecoverPasswordView,
      meta: {
        storeRedirectLocation: false
      }
    },

    {
      path: "/reset-password",
      component: ResetPasswordView,
      meta: {
        storeRedirectLocation: false
      }
    }
  ]
});
