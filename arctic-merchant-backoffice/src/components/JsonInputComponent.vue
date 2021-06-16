<template>
    <div >
        <form v-on:submit.prevent="addNewItem">
            <div>
                <slot>Add New:</slot>
                <i class="fa fa-info-circle" aria-hidden="true">
                    <span class="info-title">{{ title }}</span>
                </i>
            </div>
            <input
                v-model="newListText"
                id="new_item"
                type="text"
                :maxlength="max_length"
            >
            <button :disabled="activeInput">add new</button>
        </form>
        <ul>
            <li
                v-for="(item, index) in input_json"
                :key="index"
            >
                <div class="ul-text">{{ item }}</div>
                <button v-on:click.prevent="deleteItem(index)">delete</button>
            </li>
        </ul>
    </div>
</template>

<script>
export default {
  props: ["input_json", "flag_active_component", "title", "max_length"],
  data() {
    return {
      newListText: "",
      activeInput: this.ActiveItemLimit(),

      nextListId: Object.keys(this.input_json).length + 1
    };
  },
  methods: {
    addNewItem() {
      this.input_json[this.nextListId] = this.newListText;
      this.newListText = "";
      this.nextListId++;
      this.activeInput = this.ActiveItemLimit();
    },
    deleteItem(index) {
      this.$delete(this.input_json, index);
      this.activeInput = false;
    },
    ActiveItemLimit() {
      if (
        this.flag_active_component == 5 &&
        Object.keys(this.input_json).length >= 5
      ) {
        console.log(this.activeInput);
        return true;
      } else if (
        this.flag_active_component == 20 &&
        Object.keys(this.input_json).length >= 20
      ) {
        return true;
      } else return false;
    }
  }
};
</script>
<style scoped>
label {
  display: inline-block;
}
button:hover {
  background-color: #487b9e;
  cursor: pointer;
}
button {
  width: auto;
  height: auto;
  background: #5a8fb3;
  background-color: rgb(90, 143, 179);
  color: white;
  padding: 11px 5px;
  margin: 0;
  display: inline-block;
  float: right;
}
button[disabled] {
  background: #c3c3c3;
  cursor: default;
}
.fa {
  margin-left: 5px;
  font-weight: normal;
  position: relative;
  font-size: 14px;
  width: 15px;
}
#new_item {
  display: inline-block;
  width: calc(100% - 80px);
}
li {
  min-height: 40px;
  display: flex;
  align-items: center;
  margin-bottom: 5px;
}
li > button {
  float: inherit !important;
  margin-left: 5px;
}
.ul-text {
  background: #f6f6f6;
  border-radius: 5px;
  padding: 6px 10px;
  height: 38px;
  max-width: calc(100% - 67px);
  word-wrap: break-word;
  height: auto;
}
ul {
  margin-left: 0;
}
</style>
