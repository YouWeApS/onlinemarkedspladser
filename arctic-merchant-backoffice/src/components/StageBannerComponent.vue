<template>
  <div class="stage-banner" v-if="show">
    <div class="stage-banner-content">
      <p class="stage-banner-text">{{ environment }}</p>
      <img
        class="corner"
        src="@/assets/corner.png" />
    </div>
  </div>
</template>

<script>
export default {
  name: "stageBanner",

  computed: {
    environment() {
      return process.env.NODE_ENV;
    },

    show() {
      return this.environment !== "production";
    }
  }
};
</script>

<style lang="scss" scoped>
.stage-banner {
  pointer-events: none;
  position: absolute;
  top: -20px;
  left: -20px;
  height: 200px;
  width: 200px;
  z-index: 1000;
}

.stage-banner-content {
  position: relative;
}

.stage-banner-text {
  -webkit-transform: rotate(-45deg);
  -moz-transform: rotate(-45deg);
  -ms-transform: rotate(-45deg);
  -o-transform: rotate(-45deg);
  filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
  position: absolute;
  margin-top: 62px;
  margin-left: 10px;
  font-weight: bold;
  color: #fff;
  letter-spacing: 1px;
  font-size: 20px;
}

.corner {
  top: 0;
  left: 0;
}
</style>
