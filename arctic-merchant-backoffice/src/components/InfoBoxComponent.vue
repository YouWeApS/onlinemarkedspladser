<template>
  <div :class="classString" v-if="display">
    <button class="close-button" aria-label="Dismiss alert" type="button" @click="close">
      <span aria-hidden="true">&times;</span>
    </button>
    <slot />
  </div>
</template>

<script>
import InfoBoxMixin from "@/mixins/InfoBoxMixin";

export default {
  name: "InfoBoxComponent",

  mixins: [InfoBoxMixin],

  data() {
    return {
      hide: false
    };
  },

  props: {
    id: {
      type: String,
      required: true
    },

    classNames: {
      type: String,
      required: false,
      default: "primary"
    }
  },

  computed: {
    classString() {
      return `callout ${this.classNames}`;
    },

    display() {
      return !this.hide && this.shouldSeeInfoBox(this.id);
    }
  },

  methods: {
    close() {
      this.dontSeeInfoBox(this.id);
      this.hide = true;
    }
  }
};
</script>
