React = require 'react'
GenericTask = require '../generic'
DropdownEditor = require './editor'
Select = require 'react-select'

Summary = React.createClass
  displayName: 'DropdownSummary'

  getDefaultProps: ->
    task: {}
    annotation: {}

  render: ->
    {selects} = @props.task

    <div className="classification-task-summary">
      <div className="question">{@props.task.instruction}</div>
      <div className="answers">
        {if @props.annotation.value
          Object.keys(selects).map (i) =>
            <div key={i} className="answer">
              <i className="fa fa-arrow-circle-o-right" /> {selects[i].title} - {@props.annotation?.value[i]}
            </div>
        }
      </div>
    </div>

module?.exports = React.createClass
  displayName: 'DropdownTask'

  statics:
    Editor: DropdownEditor
    Summary: Summary

    getDefaultTask: ->
      type: 'dropdown'
      instruction: 'Select or type an option'
      help: ''
      selects: []

    getTaskText: (task) ->
      task.instruction

    getDefaultAnnotation: ->
      value: []

    isAnnotationComplete: (task, annotation) ->
      requiredSelects = Object.keys(task.selects).filter (i) -> task.selects[i].required

      select = (i) ->
        return i if annotation.value[i] isnt '' and annotation.value[i] isnt undefined
      selectsCompleted = requiredSelects.map select

      compareArrays = (requiredSelects, selectsCompleted) ->
        areEqual = true
        for i in [0..requiredSelects.length]
          if requiredSelects[i] isnt selectsCompleted[i]
            areEqual = false
        return areEqual

      (not requiredSelects.length) or compareArrays(requiredSelects, selectsCompleted)

    testAnnotationQuality: (unknown, knownGood) ->
      distance = levenshtein.get unknown.value.toLowerCase(), knownGood.value.toLowerCase()
      length = Math.max unknown.value.length, knownGood.value.length
      (length - distance) / length

  getInitialState: ->
    answerIndexes: []

  componentDidMount: ->
    @props.annotation.value = @props.task.selects.map -> ''
    @setState answerIndexes: @props.task.selects.map -> undefined

  getOptions: (i) ->
    {selects} = @props.task
    select = selects[i]

    if select.options.length?
      return select.options

    return select.options[@getCondParentAnswer(i)]?[@state.answerIndexes[select.condition]]

  getCondParentAnswer: (i) ->
    {selects} = @props.task

    if selects[selects[i].condition].condition?
      return @state.answerIndexes[selects[selects[i].condition].condition]

    return 0

  getDisabledAttribute: (i) ->
    {selects} = @props.task

    if selects[i].disableUntilCondition and @props.annotation.value[selects[i].condition] is ''
        return true
    return false

  render: ->
    {selects} = @props.task
    selectKeys = Object.keys(selects)

    <GenericTask question={@props.task.instruction} help={@props.task.help} required={@props.task.required}>
      <div>

        {selectKeys.map (i) =>
          options = @getOptions(i)
          <div key={Math.random()}>
            <div>{selects[i].title}</div>
            <Select
              ref="selectRef-#{i}"
              value={@props.annotation.value[i]}
              options={options?.map (option) -> {value: option}}
              labelKey="value"
              onChange={@onChangeSelect.bind(@, i)}
              disabled={@getDisabledAttribute(i)}
              allowCreate={selects[i].allowCreate}
              noResultsText={if not options?.length then null}
              addLabelText="Press enter for {label}..."
            />
          </div>
          }

      </div>
    </GenericTask>

  onChangeSelect: (i, newValue) ->
    value = @props.annotation.value
    value[i] = newValue

    relatedSelects = Object.keys(@props.task.selects).filter (key) =>
      @props.task.selects[key].condition is parseInt(i, 10)
    for key in relatedSelects
      @onChangeSelect(key, '')

    options = @getOptions(i)
    answerIndexes = @state.answerIndexes
    answerIndexes[i] = options?.indexOf(newValue)
    @setState answerIndexes: answerIndexes

    newAnnotation = Object.assign @props.annotation, {value}
    @props.onChange newAnnotation
