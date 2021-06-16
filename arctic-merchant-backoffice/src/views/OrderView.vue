<template>
  <div v-if="order">
    <h1>
      {{ order.order_id }}

      <order-state-tag-component
        :order="order"
        showOnly="leastSignificant" />
    </h1>

    <div class="grid-x">
      <div class="cell small-11">
        <div class="card">
          <div class="card-section">
            <!-- Timestamp information -->
            <div class="grid-x">
              <div class="cell small-12 medium-6 large-6">
                <dl>
                  <dt>Payment reference</dt>
                  <dd>{{ order.payment_reference }}</dd>

                  <dt>Order reciept</dt>
                  <dd>{{ order.receipt_id }}</dd>

                  <dt>Purchased at</dt>
                  <dd>
                    <time-ago
                      data-tooltip
                      :title="order.purchased_at"
                      prefix=""
                      :date="order.purchased_at" />
                  </dd>

                  <dt>Last updated</dt>
                  <dd>
                    <time-ago
                      data-tooltip
                      :title="order.updated_at"
                      prefix=""
                      :date="order.updated_at" />
                  </dd>

                  <dt>Order total</dt>
                  <dd>
                    {{ order.total }}
                    <br>
                    <small>Without VAT: {{ order.total_without_vat }}</small>
                  </dd>

                  <dt>Payment fee</dt>
                  <dd>{{ order.payment_fee }}</dd>

                  <dt>Shipping fee</dt>
                  <dd>{{ order.shipping_fee }}</dd>

                  <dt>Shipping carrier</dt>
                  <dd>{{ order.shipping_carrier.name }}</dd>

                  <dt>Shipping method</dt>
                  <dd>{{ order.shipping_method.name }}</dd>
                </dl>
              </div>
              <div class="cell small-12 medium-6 large-6">
                <dl>
                  <dt>Delivery address</dt>
                  <dd>
                    <address-component :address="order.shipping_address" />
                  </dd>

                  <dt>Billing address</dt>
                  <dd>
                    <address-component :address="order.billing_address" />
                  </dd>
                </dl>
              </div>
            </div>

            <h2>Order lines</h2>
            <info-box-component
              class-names="primary"
              id="order-line-info">
              <p>
                Because we support partial delivery / invoicing / return of the order line items each have an individual status
              </p>
            </info-box-component>

            <table>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Status</th>
                  <th>Product</th>
                  <th>Quantity</th>
                  <th>
                    Total
                    <br>
                    <small>Without VAT</small>
                  </th>
                </tr>
              </thead>

              <tbody>
                <order-line-component
                  v-for="line in order.order_lines"
                  :key="line.id"
                  :line="line" />
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import OrderMixin from "@/mixins/OrderMixin";
import FoundationMixin from "@/mixins/FoundationMixin";
import OrderStateTagComponent from "@/components/OrderStateTagComponent";
import OrderLineComponent from "@/components/OrderLineComponent";
import InfoBoxComponent from "@/components/InfoBoxComponent";
import AddressComponent from "@/components/AddressComponent";

export default {
  name: "OrderView",

  mixins: [OrderMixin, FoundationMixin],

  components: {
    OrderStateTagComponent,
    OrderLineComponent,
    InfoBoxComponent,
    AddressComponent
  },

  watch: {
    order() {
      if (this.order) this.reflowFoundation("tooltip");
    }
  },

  mounted() {
    this.loadOrder(this.$route.params.id);
  }
};
</script>
