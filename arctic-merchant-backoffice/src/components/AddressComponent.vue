<template>
  <div v-if="address">
    {{ address.name }}
    <br>
    {{ address.address1 }}
    <br>
    {{ address.city }}
    <br>
    {{ address.zip }}, {{ address.country }}
    <br>
    Phone: {{ address.phone }}
  </div>
</template>

<script>
export default {
  name: "AddressComponent",

  props: {
    address: {
      type: Object,
      required: true
    }
  }
};
</script>
