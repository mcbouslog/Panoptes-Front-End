import React from 'react';
import qs from 'qs';
import { StatsPage } from './stats.jsx';

class StatsController extends React.Component {
  constructor(props) {
    super(props);

    this.handleGraphChange = this.handleGraphChange.bind(this);
    this.handleWorkflowChange = this.handleWorkflowChange.bind(this);
    this.handleRangeChange = this.handleRangeChange.bind(this);
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
    const queryProps = {
      handleGraphChange: this.handleGraphChange,
      handleRangeChange: this.handleRangeChange,
      handleWorkflowChange: this.handleWorkflowChange,
      classificationsBy: this.getQuery('classification') || 'day',
      classificationRange: this.getQuery('classificationRange'),
      commentsBy: this.getQuery('comment') || 'day',
      commentRange: this.getQuery('commentRange'),
      projectId: this.props.id,
      workflowId: this.getQuery('workflow_id'),
      totalVolunteers: this.props.totalVolunteers,
      currentClassifications: this.props.currentClassifications,
      workflows: this.props.workflowList,
      startDate: this.props.startDate
    };

    return <StatsPage {...queryProps} />;
  }
}

StatsController.contextTypes = { router: React.PropTypes.object };

StatsController.propTypes = {
  id: React.PropTypes.string,
  totalVolunteers: React.PropTypes.number,
  currentClassifications: React.PropTypes.number,
  workflowList: React.PropTypes.arrayOf(
    React.PropTypes.shape({
      id: React.PropTypes.string,
      display_name: React.PropTypes.string
    })
  ),
  startDate: React.PropTypes.string,
  params: React.PropTypes.shape({
    name: React.PropTypes.string,
    owner: React.PropTypes.string
  })
};

export default StatsController;
