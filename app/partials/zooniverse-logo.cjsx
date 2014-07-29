React = require 'react'

ZooniverseLogoSource = React.createClass
  displayName: 'ZooniverseLogoSource'

  render: ->
    symbolHTML = '''
      <symbol id="zooniverse-logo-source" viewBox="0 0 100 100">
        <g fill="currentColor" stroke="transparent" stroke-width="0" transform="translate(50, 50)">
          <path d="M 0 -45 A 45 45 0 0 1 0 45 A 45 45 0 0 1 0 -45 Z M 0 -30 A 30 30 0 0 0 0 30 A 30 30 0 0 0 0 -30 Z" />
          <path d="M 0 -13.5 A 13.5 13.5 0 0 1 0 13.5 A 13.5 13.5 0 0 1 0 -13.5 Z" />
          <path d="M 0 -75 L 6 0 L 0 75 L -6 0 Z" transform="rotate(50)" />
        </g>
      </symbol>
    '''

    <svg dangerouslySetInnerHTML={__html: symbolHTML} />

sourceContainer = document.createElement 'div'
sourceContainer.id = 'zooniverse-logo-source-container'
sourceContainer.style.display = 'none'
document.body.appendChild sourceContainer

React.renderComponent <ZooniverseLogoSource />, sourceContainer

module.exports = React.createClass
  displayName: 'ZooniverseLogo'

  getDefaultProps: ->
    width: '1em'
    height: '1em'

  render: ->
    useHTML = '''
      <use xlink:href="#zooniverse-logo-source" x="0" y="0" width="100" height="100" />
    '''

    <svg viewBox="0 0 100 100" width={@props.width} height={@props.height} className="zooniverse-logo" dangerouslySetInnerHTML={__html: useHTML} />
