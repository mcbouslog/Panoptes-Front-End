/* eslint prefer-arrow-callback: 0, func-names: 0, 'react/jsx-boolean-value': ['error', 'always'] */
/* global describe, it, beforeEach */

import React from 'react';
import assert from 'assert';
import { shallow } from 'enzyme';

import OrganizationStatsController from './index';

describe('OrganizationStatsController', function () {
  it('should render without crashing', function () {
    shallow(<OrganizationStatsController />);
  });

  it('should render the org nav bar', function () {
    const wrapper = shallow(<OrganizationStatsController />);
    const navElement = wrapper.find('ProjectNavbar');
    assert.equal(navElement.length, 1);
  });
});
