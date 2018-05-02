import PropTypes from 'prop-types';
import React from 'react';
import apiClient from 'panoptes-client/lib/api-client';

export default class RandomProject extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    // the following API call should be replaced with a call to a new endpoint on the API that returns 1 random (launch approved, live) project card
    apiClient.type('projects')
      .get({ cards: true, launch_approved: true, state: 'live', page_size: 100 })
      .then((projects) => {
        const randomIndex = Math.floor(Math.random() * Math.floor(projects.length));
        const slug = projects[randomIndex].slug;
        this.context.router.push({ pathname: `/projects/${slug}` });
      })
      .catch(error => console.info(error));
  }

  render() {
    return (
      <button
        className="primary-button primary-button--light"
        onClick={this.handleClick}
      >I&apos;m Feeling Lucky</button>
    );
  }
}

RandomProject.contextTypes = {
  router: PropTypes.object.isRequired
};
