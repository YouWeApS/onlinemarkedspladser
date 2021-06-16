<template>
  <div :class="{ visible: !!errors.length }" class="product-errors">
    <div v-if="errors.length">
      <h2>
        <i class="fa fa-fw fa-exclamation text-warning" />
        Preparation errors
      </h2>

      <info-box-component class-names="primary" id="preparation-errors-info">
        <p>
          It can take a minute or two, before we can confirm if your changes has fixed the errors.
          If you have just changed something please check back in a couple of minutes.
        </p>
      </info-box-component>
    </div>

    <div
      class="callout alert"
      v-for="error in errors"
      :key="error.id">
      <pre
        v-for="(e, idx) in error.errors"
        :key="idx">{{ e }}</pre>
    </div>
  </div>
</template>

<script>
import InfoBoxComponent from "@/components/InfoBoxComponent";

export default {
  name: "ProductErrorComponent",

  components: {
    InfoBoxComponent
  },

  props: {
    errors: {
      type: Array,
      required: true
    }
  }
};
</script>

<style lang="scss" scoped>
.product-errors {
  visibility: hidden;
  opacity: 0;
  transition: visibility 0s linear 1s, opacity 1s linear;

  &.visible {
    visibility: visible;
    opacity: 1;
    transition-delay: 0s;
  }
}
</style>
