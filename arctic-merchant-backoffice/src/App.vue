<template>
  <div class="grid-y grid-frame">
    <header class="cell shrink">
      <top-nav-component v-if="isSignedIn" />
    </header>

    <div class="cell auto cell-block-container">
      <div class="grid-x hight-adaptive">
        <!-- Left-hand navigation -->
        <aside class="cell shrink left-side" v-if="isSignedIn">
          <img class="logo-bottom" src="@/assets/logo.svg"/>
          <side-nav-component />
        </aside>

        <!-- Main content -->
        <section class="cell auto cell-block-y">
          <notifications
            group="global"
            position="top center" />

          <router-view />
        </section>
      </div>
    </div>

    <footer>
      <cookie-law theme="dark-lime" />
    </footer>
  </div>
</template>

<script>
import SideNavComponent from "@/components/SideNavComponent";
import TopNavComponent from "@/components/TopNavComponent";
import AuthenticationMixin from "@/mixins/AuthenticationMixin";
import { loadProgressBar } from "axios-progress-bar";
import CookieLaw from "vue-cookie-law";

export default {
  name: "App",

  mixins: [AuthenticationMixin],

  components: {
    SideNavComponent,
    TopNavComponent,
    // eslint-disable-next-line vue/no-unused-components
    loadProgressBar,
    CookieLaw
  },

  mounted() {
    loadProgressBar();
  }
};
</script>

<style lang="scss">
// Use Nunito Sans and Source Code Pro as Foundation fonts
@import url("https://fonts.googleapis.com/css?family=Nunito+Sans|Source+Code+Pro");
$header-font-family: "Nunito Sans";
$body-font-family: "Nunito Sans";
$input-font-family: "Nunito Sans";
$font-family-monospace: "Source Code Pro";
$header-styles: (
  small: (
    "h1": (
      "font-size": 24
    ),
    "h2": (
      "font-size": 20
    ),
    "h3": (
      "font-size": 19
    ),
    "h4": (
      "font-size": 18
    ),
    "h5": (
      "font-size": 17
    ),
    "h6": (
      "font-size": 16
    )
  ),
  medium: (
    "h1": (
      "font-size": 30
    ),
    "h2": (
      "font-size": 22
    ),
    "h3": (
      "font-size": 18
    ),
    "h4": (
      "font-size": 25
    ),
    "h5": (
      "font-size": 20
    ),
    "h6": (
      "font-size": 16
    )
  )
);

// Set body background color
$body-background: rgb(244, 247, 250);

// Set top navigation background color
$topbar-submenu-background: $body-background;

// Setup card styles
$card-border-radius: 3px;

// Set global element radius
$global-radius: 5px;

/*
 * Import foundation
 */
@import "../node_modules/foundation-sites/scss/foundation";
@include foundation-everything(true, true); // flex and prototype true

@import "./assets/typography_helpers";
@import "./assets/datetime_picker";
@import "./assets/loading_spinner";

/*
 * Import top-of-page loading-bar style
 */
@import url("https://cdn.rawgit.com/rikmms/progress-bar-4-axios/0a3acf92/dist/nprogress.css");

@include breakpoint(large) {
  .hight-adaptive {
    height: 100%;
  }

  .left-side {
    width: 240px;
    margin-right: 60px;
    padding-left: 30px;
    padding-top: 50px;
    background-color: #fff;
  }
}

.logo-bottom {
  @include breakpoint(large) {
    position: absolute;
    max-width: 260px;
    bottom: -60px;
    left: -60px;
    opacity: 0.3;
  }

  @include breakpoint(medium down) {
    display: none;
  }
}

#nprogress .bar {
  background: #3f7eb8 !important;
}

#nprogress .peg {
  box-shadow: 0 0 10px #3f7eb8, 0 0 5px #3f7eb8 !important;
}

#nprogress .spinner-icon {
  display: none;
}

.json-editor-row {
  label {
    @include label;
    background-color: transparent;
    padding: 0;
    border: none;
    box-shadow: none;
    margin-top: 1rem;

    & > span {
      margin-bottom: 5px;
      display: block;
    }
  }
}

.sub-title {
  @extend h3;
  margin-top: 40px;
}

// form {
//   label:last-child {
//     margin-top: 20px;
//   }
// }

.vue-moments-ago {
  font-size: 1rem !important;
}

.tabs {
  border: none;
}

// Make vue notifications inline in the html, and not fixed to the border of the
// window.
.inline-notifications {
  position: initial !important;
  top: initial;
  right: initial;
}

.nowrap {
  white-space: nowrap;
}

.blue-bold-text {
  font-weight: bold;
  color: #1779ba;
  margin-right: 10px;
}

.pagination {
  li {
    a {
      outline: none;
    }

    &.disabled {
      cursor: not-allowed !important;
      pointer-events: none;
      opacity: 0.4;

      a {
        cursor: not-allowed !important;
        pointer-events: none;
      }
    }

    &.active {
      a {
        background-color: #1779ba;
        color: #fff;
      }
    }
  }
}
</style>
