<template>
  <select
    v-if="shops.length > 1"
    v-model="selectedShopId">
    <option
     v-for="shop in shops"
     :key="shop.id"
     :value="shop.id">
     {{ shop.name }}
    </option>
  </select>

  <div v-else>
    {{ shops[0].name }}
  </div>
</template>

<script>
import ShopMixin from "@/mixins/ShopMixin";

export default {
  name: "ShopSelectorComponent",

  mixins: [ShopMixin],

  data() {
    return {
      selectedShopId: null
    };
  },

  watch: {
    currentShop() {
      if (this.currentShop) this.selectedShopId = this.currentShop.id;
    },

    selectedShopId() {
      const shop = this.shops.filter(s => s.id === this.selectedShopId)[0];
      this.setCurrentShop(shop);
    }
  },

  mounted() {
    if (this.currentShop) this.selectedShopId = this.currentShop.id;
  }
};
</script>
