React = require 'react'
GenericTask = require '../generic'
SelectTaskEditor = require './editor'
Select = require 'react-select'

Summary = React.createClass
  displayName: 'SelectSummary'

  render: ->
    <div><p>Cool stuff</p></div>
  # TODO - ADD ALL THE STUFF!

module?.exports = React.createClass
  displayName: 'SelectTask'

  statics:
    Editor: SelectTaskEditor
    Summary: Summary

    getDefaultTask: ->
      type: 'select'
      instruction: 'Select or type an option from the dropdown(s)'
      help: ''
      selects: []

    getTaskText: (task) ->
      task.instruction

    getDefaultAnnotation: ->
      value: []

    isAnnotationComplete: (task, annotation) ->
      # TODO build this
      true

  componentDidMount: ->
    @props.annotation.value = @props.task.selects.map -> ''

  getSelectOptions: (i) ->
    if @props.task.selects[i].condition?
      conditionParent = @props.annotation.value[i-1]
      return @props.task.selects[i].condition[conditionParent]
    else
      options = @props.task.selects[i].options

  render: ->
    {selects} = @props.task
    selectIndexes = Object.keys(selects)

    <GenericTask question={@props.task.instruction} help={@props.task.help} required={@props.task.required}>
      <div>

        {selectIndexes.map (i) =>
          options = @getSelectOptions(i)
          <div key={i}>
            <div>{selects[i].title}</div>
            <Select
              ref="selectRef-#{i}"
              name="selectName-#{i}"
              value={@props.annotation.value[i]}
              options={options}
              onChange={@onChangeSelect.bind(@, i)}
              allowCreate={true}
            />
          </div>
          }

      </div>
    </GenericTask>

  onChangeSelect: (i, newValue) ->
    value = @props.annotation.value
    value[i] = newValue
    newAnnotation = Object.assign @props.annotation, {value}
    @props.onChange newAnnotation
