// import { shallowMount } from "@vue/test-utils";

import { shallowMount } from "@vue/test-utils";
import Vue from "vue";
import AuthenticationMixin from "@/mixins/AuthenticationMixin";

describe('AuthenticationMixin', () => {
  const wrapper = shallowMount(AuthenticationMixin);
  const vm = wrapper.vm;

  jest.mock('AuthenticationMixin.$store', () => ({
    getters: jest.fn()
  }));

  it('renders the correct markup', () => {
    expect(vm.store).toContain('<span class="count">0</span>');
  });
});
