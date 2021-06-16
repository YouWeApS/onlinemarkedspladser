<template>
  <select
    v-if="vendors.length > 1"
    v-model="selectedVendorId">
    <option
     v-for="vendor in vendors"
     :key="vendor.id"
     :value="vendor.id">
     {{ vendor.name }}
    </option>
  </select>

  <div v-else>
    {{ vendors[0].name }}
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";

export default {
  name: "VendorSelectorComponent",

  mixins: [VendorMixin],

  data() {
    return {
      selectedVendorId: null
    };
  },

  watch: {
    currentVendor() {
      if (this.currentVendor) this.selectedVendorId = this.currentVendor.id;
    },

    selectedVendorId() {
      const vendor = this.vendors.filter(
        s => s.id === this.selectedVendorId
      )[0];
      this.setCurrentVendor(vendor);
    }
  },

  mounted() {
    if (this.currentVendor) this.selectedVendorId = this.currentVendor.id;
  }
};
</script>
