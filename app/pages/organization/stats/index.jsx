import React from 'react';
import ProjectNavbar from '../../project/project-navbar';

class OrganizationStatsController extends React.Component {
  constructor() {
    super();
  }

  componentDidMount() {
    console.log('Hello are you there?');
  }

  render() {
    let backgroundStyle = {};
    if (this.props.organizationBackground) {
      backgroundStyle = {
        backgroundImage: `
          radial-gradient(rgba(0, 0, 0, 0.2),
          rgba(0, 0, 0, 0.8)),
          url('${this.props.organizationBackground.src}')
        `
      };
    }

    const navbar = (
      <ProjectNavbar
        project={this.props.organization}
        projectAvatar={this.props.organizationAvatar}
      />);

    return (
      <div className="project-page project-background" style={backgroundStyle}>
        {navbar}
      </div>);
  }
}

OrganizationStatsController.propTypes = {
  organization: React.PropTypes.shape({
    categories: React.PropTypes.arrayOf(
      React.PropTypes.string
    ),
    description: React.PropTypes.string,
    display_name: React.PropTypes.string,
    id: React.PropTypes.string,
    introduction: React.PropTypes.string,
    urls: React.PropTypes.arrayOf(
      React.PropTypes.shape({
        url: React.PropTypes.string
      })
    )
  }),
  organizationAvatar: React.PropTypes.shape({
    src: React.PropTypes.string
  }),
  organizationBackground: React.PropTypes.shape({
    src: React.PropTypes.string
  }),
  params: React.PropTypes.object
};

export default OrganizationStatsController;
