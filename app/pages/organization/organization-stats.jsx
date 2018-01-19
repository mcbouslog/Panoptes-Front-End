import React from 'react';
import ProjectNavbar from '../project/project-navbar';
import StatsController from '../../components/stats';
import getWorkflowsInOrder from '../../lib/get-workflows-in-order.coffee';

class OrganizationStats extends React.Component {
  constructor() {
    super();

    this.state = {
      workflowList: []
    };
  }

  componentDidMount() {
    if (this.props.organizationProjects && this.props.organizationProjects.length > 0) {
      this.getWorkflows(this.props.organizationProjects);
    }
  }

  componentWillReceiveProps(nextProps) {
    if (this.props.organizationProjects !== nextProps.organizationProjects &&
      nextProps.organizationProjects &&
      nextProps.organizationProjects.length > 0) {
      this.getWorkflows(nextProps.organizationProjects);
    }
  }

  getWorkflows(organizationProjects) {
    const fields = [
      'active',
      'classifications_count',
      'completeness',
      'configuration',
      'display_name',
      'retired_set_member_subjects_count',
      'retirement,subjects_count'
    ];

    organizationProjects.map((project) => {
      const query = {
        fields: fields.join(','),
        page_size: project.links.workflows.length
      };

      getWorkflowsInOrder(project, query)
        .then((workflows) => {
          const workflowsSetToBeVisible =
            workflows.filter((workflow) => {
              let statsVisible = workflow.active;
              if (workflow.configuration.stats_hidden !== undefined) {
                statsVisible = !workflow.configuration.stats_hidden;
              }
              return (statsVisible ? workflow : null);
            });
          const workflowList = this.state.workflowList.concat(workflowsSetToBeVisible);
          this.setState({ workflowList });
        });
    });
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

    return (
      <div className="project-page project-background" style={backgroundStyle}>
        <ProjectNavbar
          project={this.props.organization}
          projectAvatar={this.props.organizationAvatar}
        />
        <StatsController
          id="1735"
          totalVolunteers={12345}
          currentClassifications={6789}
          workflowList={this.state.workflowList}
          startDate="2017-09-13T17:11:22.265Z"
          talk={false}
        />
      </div>);
  }
}

OrganizationStats.propTypes = {
  organization: React.PropTypes.shape({
    display_name: React.PropTypes.string,
    id: React.PropTypes.string,
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
  organizationProjects: React.PropTypes.arrayOf(
    React.PropTypes.shape({
      id: React.PropTypes.string,
      display_name: React.PropTypes.string
    })
  )
};

export default OrganizationStats;
