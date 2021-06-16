<template>
  <div>
    <span
      v-for="(tt, i) in numbers"
      :key="i">
      <tag-component :value="tt" />
      <br>
    </span>
  </div>
</template>

<script>
import TagComponent from "@/components/TagComponent";

export default {
  name: "OrderTrackAndTraceComponent",

  components: {
    TagComponent
  },

  props: {
    order: {
      type: Object,
      required: true
    }
  },

  computed: {
    numbers() {
      return this.order.track_and_trace_reference;
    }
  }
};
</script>
