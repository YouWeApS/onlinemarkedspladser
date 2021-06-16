<template>
  <div class="product-preview grid-x grid-margin-x">
    <div v-for="(items, locale) in product.texts.texts">
      <h2>{{ locale }}</h2>
      <table class="hover stack">
        <thead>
          <tr>
            <th>String type</th>
            <th>Body</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, key) in items">
            <td>{{ key }}</td>
            <td>{{ item }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import FoundationMixin from "@/mixins/FoundationMixin";
import draggable from "vuedraggable";
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "ProductTextsComponent",

  props: {
    product: {
      type: Object,
      required: true
    }
  },

  mixins: [FoundationMixin, VendorMixin]
};
</script>

