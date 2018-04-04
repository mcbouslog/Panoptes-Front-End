/* eslint-disable func-names, prefer-arrow-callback */
/* global describe, it, beforeEach */

import React from 'react';
import assert from 'assert';
import { mount, shallow } from 'enzyme';
import sinon from 'sinon';
import DropdownDialog from './dropdown-dialog';
import { workflow } from '../../../pages/dev-classifier/mock-data';

const rootSelect = {
  instruction: 'Is there something here?',
  selects: [{
    id: 'numbers123',
    title: 'Numbers',
    required: true,
    allowCreate: false,
    options: {
      '*': [
        { label: 'One', value: 1 },
        { label: 'Two', value: 2 },
        { label: 'Three', value: 3 }
      ]
    }
  }]
};

const multiSelects = JSON.parse(JSON.stringify(workflow.tasks.dropdown));

// multiSelects:
//   1 - Country (required:true)
//   2 - State (condition:Country, required:true, allowCreate:false)
//   3 - County (condition:State, allowCreate:true)
//   4 - City (condition:County, allowCreate:false)
//   5 - Best State Team (condition:State, allowCreate:true)

describe.only('DropdownDialog', function () {
  describe('with root select', function () {
    let wrapper;

    beforeEach(function () {
      wrapper = mount(
        <DropdownDialog
          selects={rootSelect.selects}
          initialSelect={rootSelect.selects[0]}
        />);
    });

    it('should render without crashing', function () {
      // beforeEach render of DropdownDialog
    });

    it('should have required checked', function () {
      const requiredInput = wrapper.find('#required')
        .filterWhere(item => item.prop('checked') === true);
      assert.equal(requiredInput.length, 1);
    });

    it('should have allowCreate unchecked', function () {
      const allowCreateInput = wrapper.find('#allowCreate')
        .filterWhere(item => item.prop('checked') === false);
      assert.equal(allowCreateInput.length, 1);
    });

    it('should not have selects for conditional selects', function () {
      // there should be only 1 select for presets
      assert.equal(wrapper.find('select').length, 1);
    });
  });

  describe('with dependent select', function () {
    let wrapper;
    multiSelects.selects[2].required = false;

    beforeEach(function () {
      wrapper = mount(
        <DropdownDialog
          selects={multiSelects.selects}
          initialSelect={multiSelects.selects[2]}
          related={[multiSelects.selects[3]]}
        />);
    });

    it('should render without crashing', function () {
      // beforeEach render of DropdownDialog
    });

    it('should have required unchecked', function () {
      const requiredInput = wrapper.find('#required')
        .filterWhere(item => item.prop('checked') === false);
      assert.equal(requiredInput.length, 1);
    });

    it('should have allowCreate checked', function () {
      const allowCreateInput = wrapper.find('#allowCreate')
        .filterWhere(item => item.prop('checked') === true);
      assert.equal(allowCreateInput.length, 1);
    });

    it('should have selects for conditional selects', function () {
      // there should be 3 selects, 1 for Country, 1 for State and 1 for presets
      assert.equal(wrapper.find('select').length, 3);
    });
  });

  /*

  root select
    lists options
    reorder option
    delete option
    add single option via textarea
    add list of options via textarea
    apply range of numbers preset
    apply other preset

  dependent select
    lists appropriate options

  */
});
