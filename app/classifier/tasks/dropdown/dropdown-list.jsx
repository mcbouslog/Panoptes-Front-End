import PropTypes from 'prop-types';
import React from 'react';
import DragReorderable from 'drag-reorderable';

const DropdownList = ({ deleteDropdown, editDropdown, onReorder, selects }) => {
  function editSelect(index) {
    editDropdown(index);
  }

  function deleteSelect(index) {
    if (window.confirm(
      'Are you sure that you would like to delete this dropdown AND all dropdowns conditional to it?'
    )) {
      deleteDropdown(index);
    }
  }

  function getDependent(select) {
    if (!select.condition) {
      return '';
    }
    const condition = selects.filter(dropdown => dropdown.id === select.condition);
    const conditionTitle = condition[0].title;
    return `(dep. on ${conditionTitle})`;
  }

  function renderDropdown(select, i) {
    return (
      <li key={select.id} className="dropdown-task-list-item-container">
        <span className="dropdown-task-list-item-title">{select.title}</span>
        <span className="dropdown-task-list-item-dependency">
          {getDependent(select)}
        </span>
        <button type="button" className="dropdown-task-list-item-edit-button" onClick={() => editSelect(i)}>
          <i className="fa fa-pencil fa-fw" />
        </button>
        {(i !== 0) &&
          <button type="button" className="dropdown-task-list-item-reset-button" onClick={() => deleteSelect(i)}>
            <i className="fa fa-trash-o fa-fw" />
          </button>}
      </li>
    );
  }

  return (
    <DragReorderable
      tag="ul"
      className="dropdown-task-list"
      items={selects}
      render={renderDropdown}
      onChange={onReorder}
    />);
};

DropdownList.defaultProps = {
  deleteDropdown: () => {},
  editDropdown: () => {},
  onReorder: () => {},
  selects: []
};

DropdownList.propTypes = {
  deleteDropdown: PropTypes.func,
  editDropdown: PropTypes.func,
  onReorder: PropTypes.func,
  selects: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string
    })
  )
};

export default DropdownList;
