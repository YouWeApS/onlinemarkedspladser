<template>
  <ul
    class="vertical menu"
    data-responsive-menu="drilldown medium-accordion">

    <li>
      <router-link to="/products">
        <i class="fal fa-fw fa-barcode-read" />
        <span>Products</span>
      </router-link>
    </li>

    <li>
      <router-link to="/products_vendors">
        <i class="fal fa-fw fa-check-square" />
        <span>Products activation</span>
      </router-link>
    </li>

    <li>
      <router-link to="/orders">
        <i class="fal fa-fw fa-shopping-cart" />
        <span>Orders</span>
      </router-link>
    </li>

    <li>
      <router-link to="/categories">
        <i class="fal fa-fw fa-layer-group" />
        <span>Categories</span>
      </router-link>
    </li>

    <li>
      <router-link to="/configure">
        <i class="fal fa-fw fa-cog" />
        <span>Settings</span>
      </router-link>
    </li>

    <li class="fix-to-bottom">
      <a
        href="http://status.yourdomain.com"
        target="_blank"
        data-tooltip
        title="Experiencing any problems? Check the system status here!">
        <i class="fal fa-fw fa-shield" />
        <span>Status</span>
      </a>
    </li>
  </ul>
</template>

<script>
import FoundationMixin from "@/mixins/FoundationMixin";

export default {
  name: "SideNav",

  mixins: [FoundationMixin],

  computed: {
    selectedMenuItem() {
      return this.$route.path;
    }
  }
};
</script>

<style scoped lang="scss">
@import "../../node_modules/foundation-sites/scss/foundation";

.vertical.menu {
  width: 200px;

  @include breakpoint(medium down) {
    width: 60px;
  }
}

i {
  margin-right: 10px;
  text-align: right;
}

.fa-fw {
  @include breakpoint(large) {
    display: none;
  }
}

a {
  color: #333;

  &.router-link-active {
    @include breakpoint(medium down) {
      background-color: #1779ba;

      i {
        color: #fff;
      }
    }

    color: #1779ba;
    font-weight: bold;

    span {
      border-bottom: solid 1px #333;
    }
  }

  span {
    @include breakpoint(medium down) {
      display: none;
    }
  }
}

li.fix-to-bottom {
  position: fixed;
  bottom: 0;
  left: 0;
  width: 200px;

  @include breakpoint(medium down) {
    width: 60px;
  }

  a {
    background-color: transparent;
  }

  .has-tip {
    cursor: pointer;
  }
}
</style>
