<template>
  <div class="product-preview grid-x grid-margin-x">
    <div class="cell small-12 medium-3">
      <img :src="mainImageUrl" class="main">
    </div>

    <dl class="cell small-12 medium-9">
      <dd>
        <h2>{{ product.name || 'No name' }}</h2>
      </dd>

      <dt>Description</dt>
      <dd v-html="description"></dd>

      <dt>Price</dt>
      <dd>{{ product.currency || 'No currency' }} {{ product.price || 'No price' }}</dd>

      <dt>Color</dt>
      <dd>{{ product.color || 'No color' }}</dd>

      <dt>Material</dt>
      <dd>{{ product.material || 'No material' }}</dd>

      <dt>Manufacturer</dt>
      <dd>{{ product.manufacturer || 'No manufacturer' }}</dd>

      <dt>Brand</dt>
      <dd>{{ product.brand || 'No brand' }}</dd>

      <dt>Size</dt>
      <dd>{{ product.size || 'No size' }}</dd>

      <dt>Count</dt>
      <dd>{{ product.count || 'No item count' }}</dd>

      <dt>Target gender</dt>
      <dd>{{ product.gender || 'No target gender' }}</dd>

      <dt>Scent</dt>
      <dd>{{ product.scent || 'No scent' }}</dd>

      <dt>Category</dt>
      <dd><pre>{{ primaryCategory }}</pre></dd>
    </dl>
  </div>
</template>

<script>
import _ from "underscore";

export default {
  name: "ProductPreviewComponent",

  props: {
    product: {
      type: Object,
      required: true
    }
  },

  computed: {
    mainImageUrl() {
      if (this.images[0]) return this.images[0].url;
      return null;
    },

    images() {
      return _.sortBy(this.product.images, "position");
    },

    description() {
      return this.product.description || "No description";
    },

    primaryCategory() {
      return this.product.categories[0];
    }
  }
};
</script>

<style lang="scss" scoped>
img.main {
  max-width: 100%;
  float: left;
}

.product-preview {
  &:after {
    content: "";
    clear: both;
    display: table;
  }
}

dt {
  margin-top: 10px;
}
</style>
