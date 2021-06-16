<template>
  <form
    @submit.prevent="submit">

    <info-box-component
      class-names="primary"
      id="product-edit-info">

      <p>
        You're currently editing this product in the context of the selected
        vendor. The changes will only be reflected for this product in that
        channel. All other channels will be unaffected.
      </p>

      <p>
        If you want to change products en-mass consider updating your products in
        your source-channel.
      </p>
    </info-box-component>

    <info-box-component
      class-names="primary"
      id="product-preview-info">
      <p>
        Preview information is indicated under each of the fields. This displays what information will be distributed to {{ vendor.name }}.
      </p>
    </info-box-component>

    <ul class="tabs" data-tabs id="product-tabs">
      <li class="tabs-title is-active"><a data-tabs-target="preview" href="#preview">Preview</a></li>
      <li class="tabs-title"><a href="#identification" aria-selected="true">Identification</a></li>
      <li class="tabs-title"><a data-tabs-target="characteristics" href="#characteristics">Characteristics</a></li>
      <li class="tabs-title"><a data-tabs-target="prices" href="#prices">Prices</a></li>
      <li class="tabs-title"><a data-tabs-target="images" href="#images">Images</a></li>
      <li class="tabs-title"><a data-tabs-target="texts" href="#texts">Texts</a></li>
    </ul>

    <div class="tabs-content" data-tabs-content="product-tabs">
      <div class="tabs-panel is-active" id="preview">
        <product-preview-component :product="product.preview" />
      </div>

      <div class="tabs-panel" id="identification">
        <h3>
          <i class="fal fa-fw fa-pencil" />
          Edit identification information
        </h3>

        <label>
          SKU
          <input
            type="text"
            name="sku"
            id="sku"
            v-model="product.sku"
            placeholder="Custom product SKU" />
        </label>
        <p class="help-text">
          Preview: {{ product.sku || preview.sku || 'No SKU' }}
        </p>

        <label>
          EAN
          <input
            maxlength="256"
            type="text"
            name="ean"
            v-model="product.ean"
            placeholder="Custom product ean" />
        </label>
        <p class="help-text">
          Preview: {{ product.ean || preview.ean || 'No EAN' }} - Read more <a target="_blank" href="https://www.amazon.com/gp/seller/asin-upc-isbn-info.html">about EAN numbers</a>
        </p>

        <label>
          Category
          <select
            v-model="product.categories[0]">
            <option :value="null"></option>
            <option
              v-for="cat in categories"
              :key="cat.id"
              :value="cat.source">
              {{ cat.name || cat.source }}
            </option>
          </select>
        </label>
        <p class="help-text">
          Preview: {{ currentCategory || preview.categories[0] || 'No categories' }}
        </p>

        <button class="button primary">
          Update identification
        </button>

        <delete-product-button-component
          v-if="!product.deleted_at"
          :product="product" />
      </div>

      <div class="tabs-panel" id="characteristics">
        <h3>
          <i class="fal fa-fw fa-pencil" />
          Edit product characteristics
        </h3>

        <info-box-component
          class-names="primary"
          id="product-characteristics-info">
          <p>
            Characteristics that's not indicated as required by preparation errors are optional and can be left unaltered.
          </p>
        </info-box-component>

        <label>
          Name
          <input
            maxlength="256"
            type="text"
            name="name"
            v-model="product.name"
            placeholder="Custom product name" />
        </label>
        <p class="help-text">
          Preview: {{ product.name || preview.name || 'Unnamed' }}
        </p>

        <label>
          Description
          <textarea
            maxlength="2000"
            rows="3"
            v-model="product.description"
            placeholder="Custom product description"
            ref="description"
            data-counter="#description-characters-left" />
          <div class="character-counter">
            <span id="description-characters-left" />
            characters left
          </div>
        </label>
        <p class="help-text">
          Preview: {{ product.description || preview.description || 'Undescribed' }}
        </p>

        <label>
          Color
          <input
            maxlength="256"
            type="text"
            name="color"
            v-model="product.color"
            placeholder="Custom product color" />
        </label>
        <p class="help-text">
          Preview: {{ product.color || preview.color || 'No color' }}
        </p>

        <label>
          Brand
          <input
            maxlength="256"
            type="text"
            name="brand"
            v-model="product.brand"
            placeholder="Custom product brand" />
        </label>
        <p class="help-text">
          Preview: {{ product.brand || preview.brand || 'No brand' }}
        </p>

        <label>
          Manufacturer
          <input
            maxlength="256"
            type="text"
            name="manufacturer"
            v-model="product.manufacturer"
            placeholder="Custom product manufacturer" />
        </label>
        <p class="help-text">
          Preview: {{ product.manufacturer || preview.manufacturer || 'No manufacturer' }}
        </p>

        <label>
          Material
          <input
            maxlength="256"
            type="text"
            name="material"
            v-model="product.material"
            placeholder="Custom product material" />
        </label>
        <p class="help-text">
          Preview: {{ product.material || preview.material || 'No material' }}
        </p>

        <label>
          Size
          <input
            maxlength="256"
            type="text"
            name="size"
            v-model="product.size"
            placeholder="Custom product size" />
        </label>
        <p class="help-text">
          Preview: {{ product.size || preview.size || 'No size' }}
        </p>

        <label>
          Target gender
          <input
            maxlength="256"
            type="text"
            name="gender"
            v-model="product.gender"
            placeholder="male or female" />
        </label>
        <p class="help-text">
          Preview: {{ product.gender || preview.gender || 'No target gender' }}
        </p>

        <label>
          Scent
          <input
            maxlength="256"
            type="text"
            name="scent"
            v-model="product.scent"
            placeholder="Is the product scentet" />
        </label>
        <p class="help-text">
          Preview: {{ product.scent || preview.scent || 'No scent' }}
        </p>

        <label>
          Count
          <input
            maxlength="256"
            type="number"
            name="count"
            v-model="product.count"
            placeholder="Number of items in packaging" />
        </label>
        <p class="help-text">
          Preview: {{ product.count || preview.count || 'No count' }}
        </p>

        <h3>Amazon specific fields.</h3>

        <label>
          Legal Disclaimer
          <i class="fa fa-info-circle" aria-hidden="true" >
            <span class="info-title">An alphanumeric string; 1 character minimum in length and 500 characters maximum in length.</span>
          </i>
          <input
            maxlength="500"
            type="text"
            name="legal_disclaimer"
            v-model="product.legal_disclaimer"
            placeholder="Ex: For residents of NJ, VT, MA, and MI, must be at least 18 & over to purchase" />
        </label>
        <p class="help-text">
          Preview: {{ product.legal_disclaimer || preview.legal_disclaimer || 'No Legal Disclaimer' }}
        </p>

        <label>
          Search Terms
          <i class="fa fa-info-circle" aria-hidden="true">
            <span class="info-title">Search terms that describe your product: no repetition, no competitor brand names or ASINs.</span>
          </i>
          <input
            maxlength="500"
            type="text"
            name="search_terms"
            v-model="product.search_terms"
            placeholder="Ex: Electric" />
        </label>
        <p class="help-text">
          Preview: {{ product.search_terms || preview.search_terms || 'No Search Terms' }}
        </p>


      <json-input-component
              :input_json="product.key_features"
              :flag_active_component="5"
              :title="'An alphanumeric string; 500 characters maximum length per bullet point. Please do not include an actual bullet point object, just the text used to describe your product. Note: Type 1 High ASCII characters (®, ©, ™, etc.) or other special characters are not supported.'"
              :max_length= "500"
      >
        <template>
          <label for="new_item">Key Product Features:</label>
        </template>
      </json-input-component>


      <json-input-component
              :input_json="product.platinum_keywords"
              :flag_active_component="20"
              :title="'An alphanumeric string; 1 character minimum in length and 50 character maximum in length.'"
              :max_length= "50"
      >
        <template>
          <label for="new_item">Platinum Keywords:</label>
        </template>
      </json-input-component>





        <button class="button primary">
          Update characteristics
        </button>
      </div>

      <div class="tabs-panel" id="prices">
        <h3>
          <i class="fal fa-fw fa-pencil" />
          Edit price information
        </h3>

        <price-form-component :product="product" />
        <price-form-component :product="product" type="offer_price" />

        <button class="button primary">
          Update price
        </button>
      </div>

      <div class="tabs-panel" id="images">
        <h3>
          <i class="fal fa-fw fa-pencil" />
          Edit product images
        </h3>

        <product-images-component :product="product" />
      </div>
      <div class="tabs-panel" id="texts">
        <h3>
          <i class="fal fa-fw fa-pencil" />
          Edit texts
        </h3>

        <product-texts-component :product="product" />
      </div>
    </div>
  </form>
</template>

<script>
import InfoBoxMixin from "@/mixins/InfoBoxMixin";
import ShopMixin from "@/mixins/ShopMixin";
import AccountMixin from "@/mixins/AccountMixin";
import ProductPreviewMixin from "@/mixins/ProductPreviewMixin";
import ProductImagesComponent from "@/components/ProductImagesComponent";
import ProductTextsComponent from "@/components/ProductTextsComponent";
import InfoBoxComponent from "@/components/InfoBoxComponent";
import FoundationMixin from "@/mixins/FoundationMixin";
import ProductPreviewComponent from "@/components/ProductPreviewComponent";
import DeleteProductButtonComponent from "@/components/DeleteProductButtonComponent";
import InputUtils from "@/mixins/InputUtils";
import PriceFormComponent from "@/components/PriceFormComponent";
import JsonInputComponent from "@/components/JsonInputComponent";

export default {
  name: "ProductShadowFormComponent",

  mixins: [
    InfoBoxMixin,
    ShopMixin,
    AccountMixin,
    ProductPreviewMixin,
    FoundationMixin,
    InputUtils
  ],

  components: {
    ProductImagesComponent,
    ProductTextsComponent,
    InfoBoxComponent,
    ProductPreviewComponent,
    DeleteProductButtonComponent,
    PriceFormComponent,
    JsonInputComponent
  },

  props: {
    product: {
      type: Object,
      required: true
    },

    vendor: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      categories: [],
      currencies: []
    };
  },

  computed: {
    preview() {
      return this.product.preview;
    },

    currentCategory() {
      try {
        return this.categories.filter(
          c => c.source === this.product.categories[0]
        )[0].value;
      } catch (e) {
        return null;
      }
    }
  },

  methods: {
    async loadCategories() {
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.vendor.id}/categories`;

      const response = await this.axios.get(url);

      this.categories = response.data;
    },

    async submit() {
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.vendor.id}/products/${this.product.id}`;

      await this.axios.patch(url, this.product);

      this.$notify({
        title: "Saved",
        type: "success",
        group: "product"
      });
    }
  },

  mounted() {
    this.loadCategories();
    this.autoResize(this.$refs.description);
    this.characterCounter(this.$refs.description);
  }
};
</script>

<style scoped lang="scss">
.close-button {
  font-size: 1.2rem;
}

.character-counter {
  margin-top: -17px;
  font-size: 0.7rem;
  float: right;
}
.fa {
  font-weight: normal;
  position: relative;
  width: 15px;
}
</style>

<style>
.info-title:after {
  content: "";
  visibility: hidden;
  position: absolute;
  bottom: -15px;
  display: inline-block;
  color: #fff;
  border: 8px solid transparent;
  border-top: 8px solid #000;
  transition: opacity 0.2s;
  opacity: 0;
  left: 6px;
}
.info-title {
  visibility: hidden;
  background-color: black;
  color: #fff;
  text-align: center;
  border-radius: 6px;
  padding: 3px 6px;
  position: absolute;
  bottom: 20px;
  left: -8px;
  opacity: 0;
  -webkit-transition: opacity 1s;
  transition: opacity 0.4s;
  word-wrap: break-word;
  height: auto;
  max-width: 400px;
  width: max-content;
}
.fa:hover .info-title,
.fa:hover .info-title:after {
  visibility: visible;
  opacity: 1;
}
</style>
