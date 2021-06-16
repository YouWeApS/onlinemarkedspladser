<template>
  <div>
    <h3>
      <router-link :to="`/channels/${vendor.id}/configure`">
        {{ vendor.name }}
      </router-link>

      <small
        data-tooltip
        :title="last_synced_at"
        class="top">

        <time-ago
          v-if="last_synced_at"
          :prefix="`last ${synced_text}`"
          suffix="ago"
          :date="last_synced_at" />

        <span v-else>
          last {{ synced_text }} Never
        </span>
      </small>
    </h3>
  </div>
</template>

<script>
import FoundationMixin from "@/mixins/FoundationMixin";

export default {
  name: "VendorListItemComponent",

  vendors: [FoundationMixin],

  props: {
    vendor: {
      type: Object,
      required: true
    },

    type: {
      type: String,
      required: true
    }
  },

  computed: {
    synced_at_ago() {
      if (this.vendor.last_synced_at) {
        return this.$moment(this.vendor.last_synced_at).fromNow();
      } else {
        return "Never";
      }
    },

    synced_text() {
      switch (this.type) {
        case "dispersal":
          return "dispersed";
        case "collection":
          return "collected";
      }
    },

    last_synced_at() {
      if (this.vendor.last_synced_at) {
        return this.$moment(this.vendor.last_synced_at)
          .local()
          .format("ddd, DD MMM YYYY HH:mm:ss zz");
      } else {
        return null;
      }
    }
  }
};
</script>
