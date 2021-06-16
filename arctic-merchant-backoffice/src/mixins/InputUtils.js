import array from "ensure-array";

export default {
  methods: {
    resize(event) {
      event.target.style.height = "auto";
      event.target.style.height = event.target.scrollHeight + "px";
    },

    delayedResize(event) {
      window.setTimeout(this.resize, 0, event);
    },

    autoResize(textareas) {
      array(textareas).forEach(el => {
        el.addEventListener("change", this.resize, false);
        el.addEventListener("cut", this.delayedResize, false);
        el.addEventListener("paste", this.delayedResize, false);
        el.addEventListener("drop", this.delayedResize, false);
        el.addEventListener("keydown", this.delayedResize, false);
      });
    },

    recount(event) {
      const count = event.target.value.length;
      const target = document.querySelector(event.target.dataset.counter);
      if (target) target.innerHTML = event.target.maxLength - count;
    },

    delayedRecount(event) {
      window.setTimeout(this.recount, 0, event);
    },

    characterCounter(elements) {
      array(elements).forEach(el => {
        el.addEventListener("change", this.recount, false);
        el.addEventListener("cut", this.delayedRecount, false);
        el.addEventListener("paste", this.delayedRecount, false);
        el.addEventListener("drop", this.delayedRecount, false);
        el.addEventListener("keydown", this.delayedRecount, false);
        el.dispatchEvent(new Event("change"));
      });
    }
  }
};
