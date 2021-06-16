<template>
  <div :class="subClass">
    <h2>Variants</h2>

    <ul class="menu vertical">
      <li
        v-for="(sku, id) in product.variants"
        :key="id"
        :class="{ 'is-active': id === product.id }">
        <router-link :to="`/products/${id}`">
          {{ sku }}
        </router-link>
      </li>
    </ul>
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  mixins: [VendorMixin],

  props: {
    subClass: {
      type: String,
      required: false,
      default: "cell small-12 medium-3 large-3 xlarge-3"
    },

    product: {
      type: Object,
      required: true
    }
  }
};
</script>

<style lang="scss" scoped>
li {
  a {
    a.product-status {
      display: inline-block;
    }
  }
}
</style>
