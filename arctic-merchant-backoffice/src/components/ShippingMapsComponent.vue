<template>
  <div>
    <h2>Shipping mappings</h2>

    <p>Normalize the shipping carriers and methods. For the vendor part of the mapping the most important part is 'Vendor method value'. Therefore in case only one value is used you should fill in this one.
      For more information on mapping for a specific vendor/channel please see <a href="#">here</a>
    </p>

    <p>
      <a class="button" @click.prevent="revealNewMap()">Add a new map</a>
    </p>

    <div>
      <table class="hover stack">
        <thead>
          <tr>
            <th>Vendor carrier</th>
            <th>Vendor method</th>
            <th>Shipping carrier</th>
            <th>Shipping method</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="map in maps" :key="map.id">
            <td>{{ map.vendor_carrier }}</td>
            <td>{{ map.vendor_method }}</td>
            <td>{{ map.shipping_carrier_name }}</td>
            <td>{{ map.shipping_method_name }}</td>
            <td>
              <a @click="deleteMap(map)">
                 <i class="fa fa-minus-circle text-error" />
              </a>
            </td>
          </tr>
        
        </tbody>
      </table>
    </div>

    <p></p>

    <popup-component
      :reveal="revealPopup"
      @close="hideNewMap">
      <h2>Add a new import map</h2>

      <form @submit.prevent="createMap">
        <p>
          <label for="vendor_method">Vendor method value</label>
          <input type="text" name="vendor_method" v-model="newMap.vendor_method" />
        </p>

        <p>
          <label for="vendor_carrier">Vendor carrier value</label>
          <input type="text" name="vendor_carrier" v-model="newMap.vendor_carrier" />
        </p>

        <p>
          <label for="shipping_carrier_id">Carrier</label>
          <select v-model="newMap.shipping_carrier_id" name="shipping_carrier_id" id="shipping_carrier_id">
            <option
              v-for="c in shipping_carriers"
              :key="c.id"
              :value="c.id">
              {{ c.name }}
            </option>
          </select>
        </p>

        <p>
          <label for="shipping_method_id">Method</label>
          <select v-model="newMap.shipping_method_id" name="shipping_method_id" id="shipping_method_id">
            <option
              v-for="m in shipping_methods"
              :key="m.id"
              :value="m.id">
              {{ m.name }}
            </option>
          </select>
        </p>

        <p>
          <button type="submit" class="button primary">Save</button>
        </p>
      </form>
    </popup-component>
  </div>
</template>

<script>
import _ from "underscore";
import VendorMixin from "@/mixins/VendorMixin";
import PopupComponent from "@/components/PopupComponent";

export default {
  name: "ShippingMapsComponent",

  mixins: [VendorMixin],

  components: {
    PopupComponent
  },

  data() {
    return {
      revealPopup: false,
      newMap: {},
      maps: [],
      shipping_carriers: [],
      shipping_methods: []
    };
  },

  methods: {
    async createMap() {
      console.log("Creating shipping map", this.newMap);

      const response = await this.axios.post(
        this.mapUrl(this.newMap),
        this.newMap
      );

      this.revealPopup = false;

      this.setMaps(response);

      this.$notify({
        title: "New shipping map added",
        type: "success",
        group: "global"
      });
    },

    async deleteMap(map) {
      console.log("Deleting shipping map", map);

      const response = await this.axios.delete(this.mapUrl(map));

      this.setMaps(response);

      this.$notify({
        title: "Shipping map deleted",
        type: "success",
        group: "global"
      });
    },

    mapUrl(map) {
      var url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/shipping_configurations`;

      if (map.id) {
        url = `${url}/${map.id}`;
      }

      return url;
    },

    revealNewMap() {
      this.revealPopup = true;
    },

    hideNewMap() {
      this.revealPopup = false;
    },

    async setMaps(response) {
      if (response) {
        await this.loadVendors();
        this.setCurrentVendor(response.data);
      }

      this.maps = this.currentVendor.config.shipping_mappings;
      console.log(this.currentVendor.config);
    }
  },

  async mounted() {
    this.setMaps();
    const carriers_response = await this.axios.get("shipping_carriers");
    this.shipping_carriers = carriers_response.data;
    const methods_response = await this.axios.get("shipping_methods");
    this.shipping_methods = methods_response.data;
  }
};
</script>

<style scoped lang="scss">
input {
  margin-bottom: 0;
}

ul {
  list-style: none;
  padding: 0;
  margin: 0;
  margin-bottom: 2rem;
}

.options {
  padding-left: 1rem;

  a {
    display: inline-block;
    line-height: 2.4rem;
  }
}
</style>
