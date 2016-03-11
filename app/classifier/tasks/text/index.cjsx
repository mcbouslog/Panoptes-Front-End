React = require 'react'
{Markdown} = require 'markdownz'
GenericTask = require '../generic'
GenericTaskEditor = require '../generic-editor'
levenshtein = require 'fast-levenshtein'

NOOP = Function.prototype

Summary = React.createClass
  displayName: 'TextSummary'

  getDefaultProps: ->
    task: null
    annotation: null
    expanded: false

  render: ->
    <div>
      <div className="question">
        {@props.task.instruction}
      </div>
      <div className="answers">
      {if @props.annotation.value?
        <div className="answer">
          “<code>{@props.annotation.value}</code>”
        </div>}
      </div>
    </div>

module.exports = React.createClass
  displayName: 'TextTask'

  statics:
    Editor: GenericTaskEditor
    Summary: Summary

    getDefaultTask: ->
      type: 'text'
      instruction: 'Enter an instruction.'
      help: ''

    getTaskText: (task) ->
      task.instruction

    getDefaultAnnotation: ->
      value: ''

    isAnnotationComplete: (task, annotation) ->
      annotation.value isnt '' or not task.required

    testAnnotationQuality: (unknown, knownGood) ->
      distance = levenshtein.get unknown.value.toLowerCase(), knownGood.value.toLowerCase()
      length = Math.max unknown.value.length, knownGood.value.length
      (length - distance) / length

  getDefaultProps: ->
    task: null
    annotation: null
    onChange: NOOP

  render: ->
    # <label className="answer">
    # </label>

    # <textarea className="standard-input full" rows="5" ref="textInput" value={@props.annotation.value} onChange={@handleChange}/>

    # <input type="text" name={@props.task.instruction} defaultValue={@props.annotation.value} onChange={@handleChange} onBlur={@triggerSubmit}/>

    <GenericTask question={@props.task.instruction} help={@props.task.help} required={@props.task.required}>
      <form onSubmit={@handleSubmit}>
        <input type="text" name={@props.task.instruction} defaultValue={@props.annotation.value} onChange={@handleChange} onBlur={@triggerSubmit}/>
        <input ref="textSubmit" type="submit" className="hidden-submit"/>
      </form>
    </GenericTask>

  handleChange: (e) ->
    value = e.target.value
    newAnnotation = Object.assign @props.annotation, {value}
    @props.onChange newAnnotation

  triggerSubmit: (e) ->
    @refs.textSubmit.click()

  handleSubmit: (e) ->
    e.preventDefault()
