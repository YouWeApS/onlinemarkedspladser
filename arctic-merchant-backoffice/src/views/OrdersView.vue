<template>
  <div>
    <h1>Orders</h1>

    <div class="grid-x">
      <div class="cell small-11">
        <div class="card">
          <div class="card-section orders-container">
            <div class="grid-x grid-padding-x small-margin-collapse">
              <input
                class="cell shrink"
                type="search"
                v-model="filter.search"
                placeholder="Search orders" />

              <label class="cell shrink middle">
                with status
              </label>
              <select
                v-model="filter.state"
                class="cell shrink">
                <option
                  v-for="status in statuses"
                  :key="status"
                  :value="status">
                  {{ titleize(status) }}
                </option>
              </select>

              <label class="cell shrink middle align-right">
                between
              </label>
              <datepicker
                :use-utc="true"
                class="cell shrink"
                v-model="filter.start_date" />

              <label class="cell shrink middle align-right">
                and
              </label>
              <datepicker
                :use-utc="true"
                class="cell shrink"
                v-model="filter.end_date" />
            </div>

            <table>
              <thead>
                <tr>
                  <td>ID</td>
                  <td>Status</td>
                  <td>Last synchronized</td>
                  <td>Track & Trace</td>
                </tr>
              </thead>

              <tbody>
                <tr v-if="loading">
                  <td colspan="3">
                    <spinner />
                  </td>
                </tr>

                <tr v-else-if="!orders.length">
                  <td colspan="3">No orders</td>
                </tr>

                <tr
                  v-for="o in orders"
                  :key="o.order_id">
                  <td class="nowrap">
                    <router-link :to="`/orders/${o.id}`">
                      {{ o.order_id }}
                    </router-link>
                  </td>
                  <td>
                    <order-state-tag-component
                      :order="o"
                      show-only="leastSignificant" />
                  </td>
                  <td class="nowrap">
                      Last updated
                      <time-ago
                        data-tooltip
                        :title="o.updated_at"
                        prefix=""
                        :date="o.updated_at" />
                    <br>
                    <small>
                      <time-ago
                        data-tooltip
                        :title="o.purchased_at"
                        prefix=""
                        :date="o.purchased_at" />
                    </small>
                  </td>
                  <td>
                    <order-track-and-trace-component :order="o" />
                  </td>
                </tr>
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
import OrderTrackAndTraceComponent from "@/components/OrderTrackAndTraceComponent";
import _s from "underscore.string";

export default {
  name: "OrdersView",

  mixins: [OrderMixin, FoundationMixin],

  components: {
    OrderStateTagComponent,
    OrderTrackAndTraceComponent
  },

  data() {
    return {
      statuses: [],
      loading: false,
      filterTimeout: null,
      filter: {
        state: "created",
        start_date: new Date(Date.now()).toUTCString(),
        end_date: new Date(Date.now()).toUTCString(),
        search: null
      }
    };
  },

  methods: {
    async reloadOrders() {
      this.loading = true;
      await this.loadOrders(this.filter);
      this.loading = false;
    },

    titleize(string) {
      return _s.titleize(string);
    },

    async loadOrderStatuses() {
      const url = `accounts/${this.currentAccountId}/shops/${
        this.currentShopId
      }/vendors/${this.currentVendorId}/orders/statuses`;

      const response = await this.axios.get(url);

      this.statuses = response.data;
    }
  },

  watch: {
    filter: {
      handler() {
        if (this.filterTimeout) {
          clearTimeout(this.filterTimeout);
        }

        this.filterTimeout = setTimeout(() => {
          this.reloadOrders();
        }, 500);
      },
      deep: true
    }
  },

  async mounted() {
    this.loading = true;
    await this.loadOrders(this.filter);
    this.loadOrderStatuses();
    this.loading = false;
  }
};
</script>

<style scoped lang="scss">
select {
  padding-right: 25px !important;
}

.vdp-datepicker {
  padding: 0 !important;
}

.orders-container {
  min-height: 400px;
}
</style>
