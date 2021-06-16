<template>
  <div class="top-bar">
    <stage-banner-component />

    <div class="top-bar-left">
      <ul class="menu">
        <li>
          <a href="/">
            <img class="logo" src="@/assets/logo.png" />
          </a>
        </li>
      </ul>
    </div>

    <div class="top-bar-right">
      <ul class="menu right">
        <li>
          <vendor-selector-component />
        </li>

        <li>
          <shop-selector-component />
        </li>

        <li>
          <account-selector-component />
        </li>

        <li class="profile-menu">
          <ul class="dropdown menu" data-dropdown-menu>
            <li>
              <span class="blue-bold-text">
                {{ currentUser.name || currentUser.email }}
              </span>

              <img
                :src="currentUser.avatar_url"
                class="thumbnail"
                v-if="currentUser.avatar_url"/>
              <img
                src="@/assets/person-icon.png"
                class="thumbnail"
                v-else />

              <ul class="menu vertical">
                <li>
                  <router-link to="/profile">
                    <i class="fal fa-user-cog" />
                    My profile
                  </router-link>
                </li>

                <li>
                  <logout-button-component />
                </li>
              </ul>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import LogoutButtonComponent from "@/components/LogoutButtonComponent";
import AccountSelectorComponent from "@/components/AccountSelectorComponent";
import ShopSelectorComponent from "@/components/ShopSelectorComponent";
import VendorSelectorComponent from "@/components/VendorSelectorComponent";
import StageBannerComponent from "@/components/StageBannerComponent";
import AuthenticationMixin from "@/mixins/AuthenticationMixin";
import FoundationMixin from "@/mixins/FoundationMixin";

export default {
  name: "TopNavComponent",

  mixins: [AuthenticationMixin, FoundationMixin],

  components: {
    AccountSelectorComponent,
    ShopSelectorComponent,
    LogoutButtonComponent,
    VendorSelectorComponent,
    StageBannerComponent
  }
};
</script>

<style lang="scss" scoped>
@import "../../node_modules/foundation-sites/scss/foundation";

.top-bar {
  background: transparent;
  @include breakpoint(large) {
    justify-content: flex-start;
    max-width: 93%;

    margin: 0px;
    padding: 0px;
  }

  .top-bar-left {
    @include breakpoint(large) {
      background-color: #fff;
      height: 100px;
      max-width: 230px;
    }

    @include breakpoint(medium down) {
      float: left;
      max-width: 20%;
    }
  }

  .top-bar-right {
    @include breakpoint(large) {
      padding: 10px;
    }
    @include breakpoint(medium down) {
      float: left;
      max-width: 80%;
      padding-top: 10px;
      padding-left: 0px;

      .menu.right {
        li.profile-menu {
          text-align: right;
          padding-right: 10px;
          /*width: 100%;*/

          .menu.dropdown {
            li {
              text-align: right;
              width: 100%;
            }
          }

          .menu.submenu {
            li {
              width: 100%;
              text-align: left;
            }
          }
        }
      }
    }
  }
}

.menu {
  background: transparent;
  line-height: 60px; // vertically align with avatar image

  li {
    margin-left: 10px;
  }
}

.submenu {
  background: #fff;

  li {
    margin-left: 0;
  }
}

.thumbnail {
  border-radius: 50%;
  height: 50px;
  width: 50px;
  object-fit: cover;
  border: 1px solid #fefefe;
}

i {
  margin-right: 10px;
}

.logo {
  @include breakpoint(large) {
    max-height: 170px;
    max-width: 170px;
    padding: 20px;
  }

  @include breakpoint(medium down) {
    max-height: 50px;
    max-width: 50px;
  }
}
</style>
