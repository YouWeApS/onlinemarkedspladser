<template>
  <div v-if="currentVendorId">
    <notifications
      group="channel"
      position="top center" />

    <div class="grid-x">
      <div class="cell small-11">
        <h1>Configure
          <span class="blue-bold-text">{{ currentVendor.name }}</span>
        </h1>

        <vendor-enable-toggle-component />

        <ul
          class="tabs"
          data-tabs
          id="config-tabs">
          <li class="tabs-title is-active">
            <a data-tabs-target="auth-config" aria-selected="true">
              Authentication
            </a>
          </li>

          <li class="tabs-title">
            <a data-tabs-target="product-config">
              Data mapping
            </a>
          </li>

          <li class="tabs-title">
            <a data-tabs-target="shipping-config">
              Shipping mapping
            </a>
          </li>

          <li class="tabs-title">
            <a data-tabs-target="product-pricing">
              Pricing
            </a>
          </li>

          <li class="tabs-title">
            <a data-tabs-target="export-import">
              Export/import
            </a>
          </li>

          <li class="tabs-title">
            <a data-tabs-target="webhooks">
              Webhooks
            </a>
          </li>
        </ul>

        <div
          class="tabs-content"
          data-tabs-content="config-tabs">

          <div class="tabs-panel" id="export-import">
            <vendor-product-data-export />
            <hr>
            <vendor-product-data-import />
          </div>

          <div class="tabs-panel is-active" id="auth-config">
            <vendor-auth-config-form-component />
            <vendor-config-form-component />
          </div>

          <div class="tabs-panel" id="product-config">
            <vendor-product-config-component />
          </div>

          <div class="tabs-panel" id="shipping-config">
            <vendor-shipping-config-component />
          </div>

          <div class="tabs-panel" id="product-pricing">
            <h2>Pricing and currency</h2>
            <vendor-product-price-adjustment-component :vendor="currentVendor" />
            <vendor-product-currency-component />
          </div>

          <div class="tabs-panel" id="webhooks">
            <h2>Webhooks</h2>
            <p>We will make a <code>POST</code> request to the webhook URL.</p>
            <webhooks-component />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import VendorMixin from "@/mixins/VendorMixin";
import FoundationMixin from "@/mixins/FoundationMixin";
import VendorAuthConfigFormComponent from "@/components/VendorAuthConfigFormComponent";
import VendorConfigFormComponent from "@/components/VendorConfigFormComponent";
import VendorProductConfigComponent from "@/components/VendorProductConfigComponent";
import VendorShippingConfigComponent from "@/components/VendorShippingConfigComponent";
import VendorProductPriceAdjustmentComponent from "@/components/VendorProductPriceAdjustmentComponent";
import VendorEnableToggleComponent from "@/components/VendorEnableToggleComponent";
import VendorProductDataExport from "@/components/VendorProductDataExport";
import VendorProductDataImport from "@/components/VendorProductDataImport";
import VendorProductCurrencyComponent from "@/components/VendorProductCurrencyComponent";
import WebhooksComponent from "@/components/WebhooksComponent";

export default {
  name: "ConfigurationEditView",

  mixins: [VendorMixin, FoundationMixin],

  components: {
    VendorAuthConfigFormComponent,
    VendorProductConfigComponent,
    VendorShippingConfigComponent,
    VendorProductPriceAdjustmentComponent,
    VendorConfigFormComponent,
    VendorEnableToggleComponent,
    VendorProductDataExport,
    VendorProductDataImport,
    VendorProductCurrencyComponent,
    WebhooksComponent
  }
};
</script>
