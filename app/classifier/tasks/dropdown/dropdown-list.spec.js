/* eslint-disable func-names, prefer-arrow-callback */
/* global describe, it, beforeEach */

import React from 'react';
import assert from 'assert';
import { mount } from 'enzyme';
import sinon from 'sinon';
import DropdownList from './dropdown-list';
import { workflow } from '../../../pages/dev-classifier/mock-data';

const singleSelect = {
  instruction: 'Is there something here?',
  selects: [{
    id: 'numbers123',
    title: 'Numbers',
    options: {
      '*': [
        { label: 'One', value: 1 },
        { label: 'Two', value: 2 },
        { label: 'Three', value: 3 }
      ]
    }
  }]
};

const multiSelects = workflow.tasks.dropdown;

// multiSelects:
//   1 - Country (required:true)
//   2 - State (condition:Country, required:true, allowCreate:false)
//   3 - County (condition:State, allowCreate:true)
//   4 - City (condition:County, allowCreate:false)
//   5 - Best State Team (condition:State, allowCreate:true)

describe('DropdownList', function () {
  let wrapper;
  let onReorderSpy;
  let editDropdownSpy;
  let deleteDropdownSpy;

  beforeEach(function () {
    onReorderSpy = sinon.spy();
    editDropdownSpy = sinon.spy();
    deleteDropdownSpy = sinon.spy();

    wrapper = mount(
      <DropdownList
        selects={singleSelect.selects}
        onReorder={onReorderSpy}
        editDropdown={editDropdownSpy}
        deleteDropdown={deleteDropdownSpy}
      />);
  });

  it('should render without crashing', function () {
    // beforeEach render of DropdownList
  });

  it('should render DragReorderable', function () {
    assert.equal(wrapper.find('DragReorderable').length, 1);
  });

  it('should render single select', function () {
    const selects = wrapper.find('li');
    assert.equal(selects.length, 1);
  });

  it('should render multiple selects', function () {
    wrapper.setProps({ selects: multiSelects.selects });
    const selects = wrapper.find('li');
    assert.equal(selects.length, 5);
  });

  it('should call editDropdown prop on pencil icon click', function () {
    wrapper.find('.dropdown-task-list-item-edit-button').simulate('click');
    sinon.assert.calledOnce(editDropdownSpy);
  });

  it('should call deleteDropdown prop on trash icon click', function () {
    const confirmStub = sinon.stub(window, 'confirm');
    confirmStub.returns(true);

    wrapper.setProps({ selects: multiSelects.selects });
    // first select not deletable, simulate click on last select
    wrapper.find('.dropdown-task-list-item-reset-button').last().simulate('click');

    sinon.assert.calledOnce(deleteDropdownSpy);
    confirmStub.restore();
  });

  it('should show select\'s conditional select in select span', function () {
    wrapper.setProps({ selects: multiSelects.selects });
    assert.equal(wrapper.find('.dropdown-task-list-item-dependency').last().text(), '(dep. on State (conditional:Country,required:true,allowCreate:false))');
  });
});
