<template>
  <div>
    <h2>Product import mappings</h2>

    <p>A prioritized list of places to look for information about a product characteristic in the source JSON from the collection vendor.</p>

    <p>
      <a class="button" @click.prevent="revealNewMap()">Add a new map</a>
    </p>

    <div v-for="(maps, group) in groups" :key="group">
      <p><strong>{{ group }}</strong></p>

      <ul>
        <li v-for="map in maps" :key="map.id">
          <div class="grid-x">
            <div class="cell small-10 medium-10 large-10">
              <form @submit.prevent="update(map)">
                <input
                  type="text"
                  name="from"
                  v-model="map.from" />
              </form>
            </div>
            <div class="cell small-2 medium-2 large-2 options">
              <a @click="deleteMap(map)">
                 <i class="fa fa-minus-circle text-error" />
              </a>
            </div>
          </div>
        </li>
      </ul>
    </div>

    <p></p>

    <popup-component
      :reveal="revealPopup"
      @close="hideNewMap">
      <h2>Add a new import map</h2>

      <form @submit.prevent="createMap">
        <p>
          <label for="from">Group</label>
          <select v-model="newMap.to" name="from" id="from">
            <option value="brand">Brand</option>
            <option value="color">Color</option>
            <option value="count">Count</option>
            <option value="description">Description</option>
            <option value="ean">EAN</option>
            <option value="sku">SKU</option>
            <option value="gender">Gender</option>
            <option value="manufacturer">Manufacturer</option>
            <option value="material">Material</option>
            <option value="name">Product name</option>
            <option value="scent">Scent</option>
            <option value="size">Size</option>
          </select>
        </p>

        <p>
          <label for="from">From</label>
          <input type="text" name="from" v-model="newMap.from" />
        </p>

        <p>
          <label for="from">Default</label>
          <input type="text" name="default" v-model="newMap.default" />
        </p>

        <p>
          <label for="from">Regex</label>
          <input type="text" name="regex" v-model="newMap.regex" />
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
  name: "ImportMapsComponent",

  mixins: [VendorMixin],

  components: {
    PopupComponent
  },

  data() {
    return {
      revealPopup: false,
      newMap: {},
      maps: []
    };
  },

  computed: {
    groups() {
      return _.groupBy(_.sortBy(this.maps, "position"), "to");
    }
  },

  methods: {
    async update(map) {
      console.log("Updating import map", map);

      const response = await this.axios.patch(this.mapUrl(map), map);

      this.setMaps(response);

      this.$notify({
        title: "Import map updated",
        type: "success",
        group: "global"
      });
    },

    async createMap() {
      console.log("Creating map", this.newMap);

      const response = await this.axios.post(
        this.mapUrl(this.newMap),
        this.newMap
      );

      this.revealPopup = false;

      this.setMaps(response);

      this.$notify({
        title: "New import map added",
        type: "success",
        group: "global"
      });
    },

    async deleteMap(map) {
      console.log("Deleting import map", map);

      const response = await this.axios.delete(this.mapUrl(map));

      this.setMaps(response);

      this.$notify({
        title: "Import map deleted",
        type: "success",
        group: "global"
      });
    },

    mapUrl(map) {
      var url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/import_maps`;

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

      this.maps = this.currentVendor.config.product_parse_config;
    }
  },

  mounted() {
    this.setMaps();
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
