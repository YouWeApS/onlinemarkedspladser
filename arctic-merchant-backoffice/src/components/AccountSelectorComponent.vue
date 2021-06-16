<template>
  <select
    v-if="accounts.length > 1"
    v-model="selectedAccountId">
    <option
     v-for="account in accounts"
     :key="account.id"
     :value="account.id">
     {{ account.name }}
    </option>
  </select>

  <div v-else>
    {{ accounts[0].name }}
  </div>
</template>

<script>
import AccountMixin from "@/mixins/AccountMixin";

export default {
  name: "AccountSelectorComponent",

  mixins: [AccountMixin],

  data() {
    return {
      selectedAccountId: this.currentAccount
    };
  },

  watch: {
    currentAccount() {
      if (this.currentAccount) {
        this.selectedAccountId = this.currentAccount.id;
      }
    },

    selectedAccountId() {
      const acc = this.accounts.filter(a => a.id === this.selectedAccountId)[0];
      this.setCurrentAccount(acc);
    }
  },

  mounted() {
    if (this.currentAccount) this.selectedAccountId = this.currentAccount.id;
  }
};
</script>
