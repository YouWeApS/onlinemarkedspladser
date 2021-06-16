<template>
  <span
    data-tooltip
    :title="title"
    :class="`tag callout ${additionalClasses}`">
    <slot />
    {{ value }}
  </span>
</template>

<script>
export default {
  name: "TagComponent",

  props: {
    value: {
      type: String
    },

    title: {
      type: String
    },

    additionalClasses: {
      type: String,
      default: "secondary"
    }
  }
};
</script>

<style lang="scss" scoped>
.tag {
  color: #333;
  font-size: 0.9rem;
  padding: 0 5px;
  border-radius: 3px;
  margin-left: 5px;
  text-align: center;
}
</style>
