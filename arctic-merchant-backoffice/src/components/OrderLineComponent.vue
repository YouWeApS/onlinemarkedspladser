<template>
  <tr>
    <td>{{ line.line_id }}</td>
    <td>{{ line.status }}</td>
    <td>{{ line.sku }}</td>
    <td>{{ line.quantity }}</td>

    <td>
      {{ line.total }}
      <br>
      <small>{{ line.total_without_vat }}</small>
    </td>
  </tr>
</template>

<script>
export default {
  name: "OrderLineComponent",

  props: {
    line: {
      type: Object,
      required: true
    }
  }
};
</script>
