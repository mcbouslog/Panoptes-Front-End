import React from 'react';
import qs from 'qs';
import ProjectNavbar from '../../project/project-navbar';
import { ProjectStatsPage } from '../../project/stats/stats.jsx';
import getWorkflowsInOrder from '../../../lib/get-workflows-in-order.coffee';

class OrganizationStatsController extends React.Component {
  constructor() {
    super();

    this.handleGraphChange = this.handleGraphChange.bind(this);
    this.handleWorkflowChange = this.handleWorkflowChange.bind(this);
    this.handleRangeChange = this.handleRangeChange.bind(this);
    this.getWorkflows = this.getWorkflows.bind(this);

    this.state = {
      workflowList: []
    };
  }

  componentDidMount() {
    this.getWorkflows(this.props.organization);
  }

  componentWillReceiveProps(nextProps) {
    if (this.props.organization !== nextProps.organization) {
      this.getWorkflows(nextProps.organization);
    }
  }

  getWorkflows(organization) {
    const fields = [
      'active',
      'classifications_count',
      'completeness',
      'configuration',
      'display_name',
      'retired_set_member_subjects_count',
      'retirement,subjects_count'
    ];

    organization.get('projects')
      .then((projects) => {
        projects.map((project) => {
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
      });
  }

  getQuery(which) {
    return qs.parse(location.search.slice(1))[which];
  }

  handleGraphChange(which, e) {
    const query = qs.parse(location.search.slice(1));
    query[which] = e.target.value;
    query[`${which}Range`] = undefined;
    const { owner, name } = this.props.params;
    this.context.router.replace({ pathname: `/projects/${owner}/${name}/stats/`, query });
  }

  handleWorkflowChange(which, e) {
    const query = qs.parse(location.search.slice(1));
    const [nameChange, value] = e.target.value.split('=');
    if (nameChange === 'workflow_id') {
      query[nameChange] = value;
    } else {
      query.workflow_id = undefined;
    }
    query[`${which}Range`] = undefined;
    const { owner, name } = this.props.params;
    this.context.router.replace({ pathname: `/projects/${owner}/${name}/stats/`, query });
  }

  handleRangeChange(which, range) {
    const query = qs.parse(location.search.slice(1));
    query[`${which}Range`] = range;
    const { owner, name } = this.props.params;
    this.context.router.replace({ pathname: `/projects/${owner}/${name}/stats/`, query });
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

    const queryProps = {
      handleGraphChange: this.handleGraphChange,
      handleRangeChange: this.handleRangeChange,
      handleWorkflowChange: this.handleWorkflowChange,
      classificationsBy: this.getQuery('classification') || 'day',
      classificationRange: this.getQuery('classificationRange'),
      commentsBy: this.getQuery('comment') || 'day',
      commentRange: this.getQuery('commentRange'),
      projectId: this.props.organization.id,
      workflowId: this.getQuery('workflow_id'),
      totalVolunteers: 123,
      currentClassifications: 456,
      workflows: this.state.workflowList,
      startDate: this.props.organization.listed_date
    };

    return (
      <div className="project-page project-background" style={backgroundStyle}>
        {navbar}
        <ProjectStatsPage {...queryProps} />
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
