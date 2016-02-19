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

  getConditionalAnswer: (i) ->
    @props.annotation.value[@props.task.selects[i].condition]

  getParentCondAI: (condIndex) ->
    {selects} = @props.task
    if selects[condIndex].condition?
      return @state.answerIndexes[selects[condIndex].condition]
    'first'

  getCondAI: (condIndex) ->
    @state.answerIndexes[condIndex]

  getSelectOptions: (i) ->
    {selects} = @props.task
    select = selects[i]
    if select.options.length
      options = select.options
    else
      options = select.options[@getParentCondAI(select.condition)]?[@getCondAI(select.condition)]

    options

  getDisabledAttribute: (i) ->
    if @props.task.selects[i].disableUntilCondition
      if @getConditionalAnswer(i) is '' or @getConditionalAnswer(i) is undefined
        return true
    return false

  render: ->
    {selects} = @props.task
    selectIndexes = Object.keys(selects)

    <GenericTask question={@props.task.instruction} help={@props.task.help} required={@props.task.required}>
      <div>

        {selectIndexes.map (i) =>
          options = @getSelectOptions(i)
          <div key={Math.random()}>
            <div>{selects[i].title}</div>
            <Select
              ref="selectRef-#{i}"
              value={@props.annotation.value[i]}
              options={options?.map (option) -> {value: option}}
              onChange={@onChangeSelect.bind(@, i)}
              allowCreate={selects[i].allowCreate}
              noResultsText={if not options?.length then null}
              disabled={@getDisabledAttribute(i)}
              labelKey="value"
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

    options = @getSelectOptions(i)
    answerIndexes = @state.answerIndexes
    answerIndexes[i] = options?.indexOf(newValue)
    @setState answerIndexes: answerIndexes

    newAnnotation = Object.assign @props.annotation, {value}
    @props.onChange newAnnotation
