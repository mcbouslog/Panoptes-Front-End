import React from 'react';
import { browserHistory } from 'react-router';
import apiClient from 'panoptes-client/lib/api-client';
import Translate from 'react-translate-component';
import isAdmin from '../../lib/is-admin';
import OrganizationPage from './organization-page';

class OrganizationContainer extends React.Component {
  constructor() {
    super();

    this.state = {
      collaboratorView: true,
      error: null,
      errorFetchingProjects: null,
      fetchingOrganization: false,
      fetchingProjects: false,
      organization: null,
      organizationAvatar: {},
      organizationBackground: {},
      organizationRoles: [],
      organizationPages: [],
      organizationProjects: []
    };

    this.toggleCollaboratorView = this.toggleCollaboratorView.bind(this);
    this.updateQuery = this.updateQuery.bind(this);
  }

  componentDidMount() {
    if (this.context.initialLoadComplete) {
      this.fetchOrganization(this.props.params.name, this.props.params.owner);
    }
  }

  componentWillReceiveProps(nextProps, nextContext) {
    const noOrgAfterLoad = nextContext.initialLoadComplete && this.state.organization === null;

    if (nextProps.params.name !== this.props.params.name ||
      nextProps.params.owner !== this.props.params.owner ||
      nextContext.user !== this.context.user ||
      noOrgAfterLoad) {
      if (!this.state.fetchingOrganization) {
        this.fetchOrganization(nextProps.params.name, nextProps.params.owner);
      }
    }

    if (this.state.organization && (nextProps.location.query !== this.props.location.query)) {
      this.fetchProjects(this.state.organization, (isAdmin() || this.isCollaborator()), nextProps.location.query);
    }
  }

  isCollaborator() {
    if (!this.context.user) {
      return false;
    }

    const collaboratorRoles = this.state.organizationRoles.filter(role =>
      role.roles.includes('collaborator') || role.roles.includes('owner'));
    return collaboratorRoles.some(role => role.links.owner.id === this.context.user.id);
  }

  toggleCollaboratorView() {
    const newView = !this.state.collaboratorView;
    this.setState({ collaboratorView: newView });
    this.fetchProjects(this.state.organization, newView);
  }

  updateQuery(newParams) {
    const query = Object.assign({}, this.props.location.query, newParams);
    const results = [];
    Object.keys(query).map((key) => {
      if (query[key] === '') {
        results.push(delete query[key]);
      }
      return results;
    });
    const newLocation = Object.assign({}, this.props.location, { query });
    newLocation.search = '';
    browserHistory.push(newLocation);
  }

  fetchProjects(organization, collaboratorView, locationQuery) {
    this.setState({ errorFetchingProjects: null, fetchingProjects: true });
    const query = { cards: true, launch_approved: true };

    if (collaboratorView) {
      delete query.launch_approved;
    }
    if (locationQuery && locationQuery.category) {
      query.tags = locationQuery.category;
    }

    organization.get('projects', query)
      .then(organizationProjects => this.setState({ fetchingProjects: false, organizationProjects }))
      .catch((error) => {
        console.error('error loading projects', error); // eslint-disable-line no-console
        this.setState({ errorFetchingProjects: error, fetchingProjects: false });
      });
  }

  fetchOrganization(name, owner) {
    if (!name || !owner) {
      return;
    }

    this.setState({ fetchingOrganization: true, error: null });

    const slug = `${owner}/${name}`;

    apiClient.type('organizations').get({ slug, include: 'avatar,background,organization_roles,pages' })
      .then(([organization]) => {
        this.setState({ organization });

        if (organization) {
          const awaitAvatar = apiClient.type('avatars').get(organization.links.avatar.id)
            .catch(error => console.error('error loading avatar', error)); // eslint-disable-line no-console
          const awaitBackground = apiClient.type('backgrounds').get(organization.links.background.id)
            .catch(error => console.error('error loading background', error)); // eslint-disable-line no-console
          const awaitRoles = apiClient.type('organization_roles').get(organization.links.organization_roles)
            .catch(error => console.error('error loading roles', error)); // eslint-disable-line no-console
          const awaitPages = apiClient.type('organization_pages').get(organization.links.pages)
            .catch(error => console.error('error loading pages', error)); // eslint-disable-line no-console

          Promise.all([
            awaitAvatar,
            awaitBackground,
            awaitRoles,
            awaitPages
          ])
            .then(([
              organizationAvatar,
              organizationBackground,
              organizationRoles,
              organizationPages
            ]) => {
              this.setState({
                organizationAvatar,
                organizationBackground,
                organizationRoles,
                organizationPages
              });
              this.fetchProjects(organization, (isAdmin() || this.isCollaborator()), this.props.location.query);
            })
            .catch((error) => {
              console.error(error); // eslint-disable-line no-console
              this.setState({ error });
            });
        }
      })
      .then(() => this.setState({ fetchingOrganization: false }))
      .catch((error) => {
        console.error('error loading organization', error); // eslint-disable-line no-console
        this.setState({ fetchingOrganization: false, error });
      });
  }

  render() {
    if (this.state.organization && (this.state.organization.listed || isAdmin() || this.isCollaborator())) {
      const children = this.props.children; // eslint-disable-line react/prop-types
      const organization = this.state.organization;

      // inject props into children
      const wrappedChildren = React.Children.map(children, child =>
        React.cloneElement(child, {
          organization,
          category: (this.props.location && this.props.location.query && this.props.location.query.category),
          collaborator: (isAdmin() || this.isCollaborator()),
          collaboratorView: this.state.collaboratorView,
          errorFetchingProjects: this.state.errorFetchingProjects,
          fetchingProjects: this.state.fetchingProjects,
          onChangeQuery: this.updateQuery,
          organizationAvatar: this.state.organizationAvatar,
          organizationBackground: this.state.organizationBackground,
          organizationPages: this.state.organizationPages,
          organizationProjects: this.state.organizationProjects,
          toggleCollaboratorView: this.toggleCollaboratorView
        }),
      );

      return (<div>{wrappedChildren}</div>);
    } else if (this.state.fetchingOrganization) {
      return (
        <div className="content-container">
          <p>
            <Translate content="organization.loading" />
            <strong>{this.props.params.name}</strong>...
          </p>
        </div>);
    } else if (this.state.error) {
      return (
        <div className="content-container">
          <p>
            <Translate content="organization.error" />
            <strong>{this.props.params.name}</strong>.
          </p>
          <p>
            <code>{this.state.error.toString()}</code>
          </p>
        </div>);
    } else if (this.state.organization === undefined || (this.state.organization && !this.state.organization.listed)) {
      return (
        <div className="content-container">
          <p>
            <strong>{this.props.params.name} </strong>
            <Translate content="organization.notFound" with={{ title: this.props.params.name }} />
          </p>
          <p>
            <Translate content="organization.notPermission" />
          </p>
        </div>);
    } else {
      return (
        <div className="content-container">
          <p><Translate content="organization.pleaseWait" /></p>
        </div>);
    }
  }
}

OrganizationContainer.contextTypes = {
  initialLoadComplete: React.PropTypes.bool,
  user: React.PropTypes.shape({
    id: React.PropTypes.string
  })
};

OrganizationContainer.propTypes = {
  location: React.PropTypes.shape({
    query: React.PropTypes.shape({
      category: React.PropTypes.string
    })
  }),
  params: React.PropTypes.shape({
    name: React.PropTypes.string,
    owner: React.PropTypes.string
  }).isRequired
};

export default OrganizationContainer;
