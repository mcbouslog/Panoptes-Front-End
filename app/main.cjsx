React = require 'react'
ReactDOM = require 'react-dom'
{ applyRouterMiddleware, Router, browserHistory } = require 'react-router'
useScroll = require 'react-router-scroll/lib/useScroll'
routes = require './router'
style = require '../css/main.styl'

# Redux
`import { Provider } from 'react-redux';`
`import configureStore from './redux/store';`
store = configureStore()

# Redirect any old `/#/foo`-style URLs to `/foo`.
if location?.hash.charAt(1) is '/'
  location.replace location.hash.slice 1

browserHistory.listen ->
  dispatchEvent new CustomEvent 'locationchange'

# make sure project stats page does not scroll back to the top when the URL changes
shouldUpdateScroll = (prevRouterProps, routerProps) ->
  pathname = routerProps.location.pathname.split('/')
  isStats = ('stats' in pathname) and ('projects' in pathname)
  isSubjectTalk = ('talk' in pathname) and ('subjects' in pathname)
  isLabVisibility = ('lab' in pathname) and ('visibility' in pathname)
  isOrganization = ('organizations' in pathname)
  hashChange = routerProps.location.hash.length
  if isStats or hashChange or isSubjectTalk or isLabVisibility or isOrganization
    false
  else
    true

ReactDOM.render <Provider store={store}><Router history={browserHistory} render={applyRouterMiddleware(useScroll(shouldUpdateScroll))}>{routes}</Router></Provider>,
  document.getElementById('panoptes-main-container')

# Are we connected to the latest back end?
require('./lib/log-deployed-commit')()

# Just for console access:
window?.zooAPI = require 'panoptes-client/lib/api-client'
window?.talkAPI = require 'panoptes-client/lib/talk-client'
require('./lib/split-config')
