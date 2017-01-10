import React from 'react';

const NavigationEditor = () => {
  return (
    <div>
      <span>TODO</span>
    </div>
  );
};

const PageEditor = () => {
  return (
    <div>
      <span>ALSO DO</span>
    </div>
  );
};

class PagesEditor extends React.Component {
  render() {
    return (
      <div>
        <div className="columns-container">
          <div>
            <div className="form-label">Navigation</div>
            <NavigationEditor />
          </div>
          <div>
            <div className="form-label">Content</div>
            <PageEditor />
          </div>
        </div>
      </div>
    );
  }
}

export default PagesEditor;
