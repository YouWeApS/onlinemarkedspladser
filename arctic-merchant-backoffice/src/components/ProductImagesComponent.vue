<template>
  <div>
    <p>Drag images to rearrange. First image will be the primary product image.</p>

    <draggable
      v-model="images"
      @change="updateImage"
      class="grid-x images">
        <a
          class="cell small-12 medium-6 large-2 image"
          v-for="img in images"
          :key="img.id"
          :href="img.url"
          target="_blank">
          <img :src="img.url" />
        </a>
    </draggable>
  </div>
</template>

<script>
import FoundationMixin from "@/mixins/FoundationMixin";
import draggable from "vuedraggable";
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "ProductImagesComponent",

  mixins: [FoundationMixin, VendorMixin],

  components: {
    draggable
  },

  data() {
    return {
      images: []
    };
  },

  props: {
    product: {
      type: Object,
      required: true
    }
  },

  methods: {
    updateImage(obj) {
      if (obj.moved) {
        const params = {
          position: obj.moved.newIndex + 1
        };

        this.axios.patch(this.url(obj.moved.element), params);
      }
    },

    url(image) {
      return `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/products/${this.product.id}/images/${
        image.id
      }`;
    }
  },

  mounted() {
    this.images = this.product.preview.images;
  }
};
</script>

<style lang="scss" scoped>
a {
  cursor: move;
}

.images {
  img {
    border-radius: 3px;
  }

  .image {
    padding: 5px;
    border: solid 1px transparent;
  }

  .image:first-child {
    background-color: #c3f5c1;
    border-color: #b8eaba;
  }
}
</style>
