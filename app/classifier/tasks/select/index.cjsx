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
      help: 'Click on the dropdown and choose an option, or type a new option.'
      selects: []

    getTaskText: (task) ->
      task.instruction

    getDefaultAnnotation: ->
      value: []

    isAnnotationComplete: (task, annotation) ->
      selectsCompleted = annotation.value.filter (value) -> value >= 0
      selectsCompleted.length is task.selects.length

  render: ->
    {selects} = @props.task
    selectIndexes = Object.keys(selects)

    <GenericTask question={@props.task.instruction} help={@props.task.help} required={@props.task.required}>
      <div>

        {selectIndexes.map (i) =>
          options = selects[i].options
          <div key="#{@props.task.instruction}-#{selects[i].title}">
            <div>{selects[i].title}</div>
            <Select
              autoFocus={if i is "0" then "true"}
              options={options}
              clearable="true"
              searchable="true"
              ref="select-#{i}"
              onChange={@onChangeSelect.bind(@, selectIndexes)}
            />
          </div>
          }

      </div>
    </GenericTask>

  onChangeSelect: (selects, e) ->
    currentAnswers = selects.reduce((obj, i) =>
      obj[i] = parseInt(@refs["select-#{i}"].value, 10)
      obj
    , [])

    @props.annotation.value = currentAnswers
    @props.onChange()
