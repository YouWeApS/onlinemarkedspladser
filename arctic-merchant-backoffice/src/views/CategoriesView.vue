<template>
  <div v-if="currentVendor">
    <notifications
      group="category"
      position="top center" />

    <h1>Categories</h1>

    <p>
      <a class="button" @click.prevent="showPopup">Add category</a>
    </p>

    <info-box-component
      class-names="primary"
      id="categories-info">

      <p>
        When your products are imported the most unique category indicator is
        stored on product (usually the category ID). You can then determine on a
        per-channel basis how this category should be distributed.
      </p>
    </info-box-component>

    <popup-component
      :reveal="popupVisible"
      @close="hidePopup">
      <h2>Add a new category</h2>

      <json-editor
        :schema="schema"
        v-model="newCategory.value"
        auto-complete="off"
        input-wrapping-class="json-editor-row"
        @submit.prevent="createCategory">

        <div class="json-editor-row">
          <label type="text" schematype="string" label="Name" description="" required="required" name="browser_node">
            <span data-required-field="true">Common name</span>
            <input type="text" value="" schematype="string" label="Name" description="" required="required" name="browser_node" v-model="newCategory.name" placeholder="Rain coats">
          </label>
        </div>

        <div class="json-editor-row">
          <label type="text" schematype="string" label="Category ID" description="" required="required" name="browser_node">
            <span data-required-field="true">Category ID</span>
            <input type="text" value="" schematype="string" label="Browser node ID" description="" required="required" name="browser_node" v-model="newCategory.source" placeholder="1">
          </label>
        </div>

        <div class="json-editor-row">
          <label type="text" schematype="string" label="Priority" description="" required="required" name="browser_node">
            <span data-required-field="true">Priority</span>
            <input type="text" value="" schematype="string" label="Browser node ID" description="" required="required" name="browser_node" v-model="newCategory.position" placeholder="1">
          </label>
        </div>

        <p style="margin-top: 2rem; margin-bottom: 0">
          <button class="button primary" type="submit">
            Create category
          </button>
        </p>
      </json-editor>
    </popup-component>

    <div v-for="(cats, source) in groups" :key="source">
      <h2>Source identifier: {{ source }}</h2>

      <div v-for="cat in cats" :key="cat.id">
        <p>{{ cat.name || "Unnamed" }}</p>
        <json-editor
          :schema="schema"
          v-model="cat.value"
          auto-complete="off"
          input-wrapping-class="json-editor-row"
          @submit.prevent="updateCategory(cat)">

          <div class="json-editor-row">
            <label type="text" schematype="string" label="Name" description="" required="required" name="browser_node">
              <span data-required-field="true">Common name</span>
              <input type="text" value="" schematype="string" label="Name" description="" required="required" name="browser_node" v-model="cat.name" placeholder="Rain coats">
            </label>
          </div>

          <div class="json-editor-row">
            <label type="text" schematype="string" label="Category ID" description="" required="required" name="browser_node">
              <span data-required-field="true">Category ID</span>
              <input type="text" value="" schematype="string" label="Browser node ID" description="" required="required" name="browser_node" v-model="cat.source" placeholder="1">
            </label>
          </div>

          <div class="json-editor-row">
            <label type="text" schematype="string" label="Priority" description="" required="required" name="browser_node">
              <span data-required-field="true">Priority</span>
              <input type="text" value="" schematype="string" label="Browser node ID" description="" required="required" name="browser_node" v-model="cat.position" placeholder="1">
            </label>
          </div>

          <p style="margin-top: 2rem; margin-bottom: 0; text-align: right">
            <button class="button primary" type="submit">
              Update
            </button>
          </p>
        </json-editor>
      </div>
    </div>
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";
import InfoBoxMixin from "@/mixins/InfoBoxMixin";
import FoundationMixin from "@/mixins/FoundationMixin";
import InfoBoxComponent from "@/components/InfoBoxComponent";
import PopupComponent from "@/components/PopupComponent";
import _ from "underscore";

export default {
  name: "CateogriesView",

  mixins: [VendorMixin, InfoBoxMixin, FoundationMixin],

  components: {
    InfoBoxComponent,
    PopupComponent
  },

  data() {
    return {
      categories: [],
      newCategory: {},
      popupVisible: false
    };
  },

  computed: {
    schema() {
      if (this.currentVendor)
        return this.currentVendor.channel.category_map_json_schema;
      return {};
    },

    groups() {
      return _.groupBy(_.sortBy(this.categories, "position"), "source");
    }
  },

  methods: {
    async loadCategories() {
      const response = await this.axios.get(this.url());
      this.categories = response.data;
    },

    async createCategory() {
      await this.axios.post(this.url(), this.newCategory);
      await this.loadCategories();
      this.resetNewCategory();
      this.hidePopup();

      this.$notify({
        title: "Category created",
        type: "success",
        group: "global"
      });
    },

    async updateCategory(cat) {
      await this.axios.patch(this.url(cat), cat);
      await this.loadCategories();

      this.$notify({
        title: "Category updated",
        type: "success",
        group: "global"
      });
    },

    url(category) {
      var url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/categories`;

      if (category) url = `${url}/${category.id}`;

      return url;
    },

    hidePopup() {
      this.popupVisible = false;
    },

    showPopup() {
      this.popupVisible = true;
    },

    resetNewCategory() {
      this.newCategory = {
        name: null,
        source: null,
        value: {},
        position: 0
      };
    }
  },

  mounted() {
    this.resetNewCategory();
    this.loadCategories();
  }
};
</script>
