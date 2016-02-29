React = require 'react'
FileButton = require '../../../components/file-button'
TriggeredModalForm = require 'modal-form/triggered'
dropdownEditorHelp = require './editor-help'
AutoSave = require '../../../components/auto-save'
handleInputChange = require '../../../lib/handle-input-change'
NextTaskSelector = require '../next-task-selector'
PromiseRenderer = require '../../../components/promise-renderer'
{MarkdownEditor} = require 'markdownz'
MarkdownHelp = require '../../../partials/markdown-help'
Papa = require 'papaparse'

{Countries} = require './countries'
{Months} = require './months'

module?.exports = React.createClass
  displayName: 'DropdownEditor'

  getInitialState: ->
    dropdown: ''
    answerIndexes: if @props.task.selects.length? then @props.task.selects.map -> "" else []
    importErrors: []

  getDefaultProps: ->
    workflow: {}
    task: {}

  componentWillReceiveProps: (nextProps) ->
    if @props.task.instruction isnt nextProps.task.instruction
      @setState({dropdown: ''})

  updateTasks: ->
    @props.workflow.update('tasks')
    @props.workflow.save()

  addSelect: (i, select) ->
    if not select.title
      return window.alert('Dropdowns must have a Title.')

    selectTitles = @props.task.selects.map (select) -> select.title

    if selectTitles.indexOf(select.title) isnt -1
      return window.alert('Dropdowns must have a unique Title.')

    if @props.task.selects.length > 0 and not select.condition
      return window.alert('Any dropdown in addition to the original dropdown must be conditional on an existing dropdown. If you\'d like to have multiple independent dropdowns please use the Combo task.')

    @setState({dropdown: "#{i}"})
    answerIndexes = @state.answerIndexes
    answerIndexes[i] = ""
    @setState({answerIndexes: answerIndexes})
    @props.task.selects[i] = select
    @updateTasks()

  addSelectOption: (i, option) ->
    if not option
      return window.alert('Please provide an option')

    if @getOptions(i).indexOf(option) isnt -1
      return window.alert('Options must be unique to each dropdown')

    if i isnt "0" and @state.condition is ""
      return window.alert('Please select an answer to the related conditional dropdown to associate the new dropdown option to')

    if i is "0"
      @props.task.selects[i].options.push(option)
    else
      {selects} = @props.task
      select = selects[i]
      condParentAnswer = @getCondParentAnswer(i)
      condAnswer = @state.answerIndexes[select.condition]
      if select.options[condParentAnswer]?[condAnswer]?.length?
        select.options[condParentAnswer][condAnswer].push(option)
      else
        select.options["#{condParentAnswer}"] = {"#{condAnswer}": [option]}

    @updateTasks()

  getOptions: (i) ->
    {selects} = @props.task
    select = selects[i]

    if select.options.length?
      return select.options
    else if select.condition
      return select.options[@getCondParentAnswer(i)]?[@state.answerIndexes[select.condition]] or []

  getCondParentAnswer: (i) ->
    {selects} = @props.task

    if selects[selects[i].condition].condition?
      return @state.answerIndexes[selects[selects[i].condition].condition]

    return 0

  onClickAddSelect: (e) ->
    if @props.task.selects.length is 0
      @addSelect(0, {
        title: @refs.selectTitle.value,
        options: []
      })
    else
      @addSelect(@props.task.selects.length, {
        title: @refs.selectTitle.value,
        condition: @refs.selectCondition.value,
        options: @buildOptionsBase(@props.task.selects.length, @refs.selectCondition.value)
      })
      @refs.selectCondition.value = ''

    @updateTasks()
    @refs.selectTitle.value = ''

  buildOptionsBase: (i, conditionIndex) ->
    if conditionIndex is "0"
      return {0: {}}
    return {}

  onClickAddSelectOption: (e) ->
    @addSelectOption(@state.dropdown, @refs.selectOption.value)
    @refs.selectOption.value = ''

  onChangeDropdown: (e) ->
    @setState({dropdown: e.target.value})
    answerIndexes = @props.task.selects.map (i) -> ""
    @setState({answerIndexes: answerIndexes})

  onChangeConditionAnswer: (i, e) ->
    answerIndexes = @state.answerIndexes
    answerIndexes[i] = e.target.value
    @setState({answerIndexes: answerIndexes})

  editTask: ->
    select = @props.task.selects[@state.dropdown]
    select['required'] = @refs.required.checked
    select['allowCreate'] = @refs.allowCreate.checked
    select['disableUntilCondition'] = @refs.disableUntilCondition?.checked
    @updateTasks()

  onClickAddPreset: ->
    # TODO REFACTOR
    if @refs.preset.value is 'countries'
      for name in Countries
        @addSelectOption @state.dropdown, name
    if @refs.preset.value is 'months'
      for name in Months
        @addSelectOption @state.dropdown, name
    @refs.preset.value = ""

  onClickDeleteDropdown: (selectKey) ->
    if window.confirm('Are you sure that you would like to delete this dropdown?')
      @props.task.selects.splice(selectKey, 1)
      @setState {dropdown: ''}, =>
        @updateTasks()

  onClickDeleteDropdownOption: (dropdownOption) ->
    {selects} = @props.task

    if window.confirm('Are you sure that you would like to delete this option?')
      selects[@state.dropdown]?.options = @getOptions(@state.dropdown).filter (option) -> option isnt dropdownOption
      @updateTasks()

  handleFiles: (forEachRow, e) ->
    @setState
      importErrors: []
    Array::slice.call(e.target.files).forEach (file) =>
      @readFile file
        .then @parseFileContent
        .then (rows) =>
          Promise.all rows.map (row, i) =>
            try
              forEachRow row
            catch error
              @handleImportError error, file, i
        .catch (error) =>
          throw error
          @handleImportError error, file
        .then =>
          @props.workflow.update('tasks').save()

  readFile: (file) ->
    new Promise (resolve) ->
      reader = new FileReader
      reader.onload = (e) =>
        resolve e.target.result
      reader.onerror = (error) =>
        @handleImportError error, file
      reader.readAsText file

  parseFileContent: (content) ->
    {errors, data} = Papa?.parse content.trim(), header: true

    cleanRows = []

    for row in data
      for key, value of row
        cleanValue = value.trim?()
        cleanRows.push cleanValue

    for error in errors
      @handleImportError error

    cleanRows

  determineBoolean: (value) ->
    # TODO: Iterate on this as we see more cases.
    value?.charAt(0).toUpperCase() in ['T', 'X', 'Y', '1']

  addCSVSelectOption: (name) ->
    unless name?
      throw new Error 'Options require an "option" column.'
    @addSelectOption @state.dropdown, name

  handleImportError: (error, file, row) ->
    @state.importErrors.push {error, file, row}
    @setState importErrors: @state.importErrors

  render: ->
    handleChange = handleInputChange.bind @props.workflow

    {selects} = @props.task
    selectKeys = Object.keys(selects)

    <div className="dropdown-editor">
      <div className="dropdown">

        <section>

          <div>
            <AutoSave resource={@props.workflow}>
              <span className="form-label">Main text</span>
              <br />
              <textarea name="#{@props.taskPrefix}.instruction" value={@props.task.instruction} className="standard-input full" onChange={handleChange} />
            </AutoSave>
            <small className="form-help">Describe the task, or ask the question, in a way that is clear to a non-expert. You can use markdown to format this text.</small><br />
          </div>
          <br />

          <div>
            <AutoSave resource={@props.workflow}>
              <span className="form-label">Help text</span>
              <br />
              <MarkdownEditor name="#{@props.taskPrefix}.help" onHelp={-> alert <MarkdownHelp/>} value={@props.task.help ? ""} rows="4" className="full" onChange={handleChange} />
            </AutoSave>
            <small className="form-help">Add text and images for a help window.</small>
          </div>

          <hr />

        </section>

        <section>

          <h2 className="form-label">Dropdowns</h2>
          <ul>
          {selectKeys.map (selectKey) =>
            <li key={selects[selectKey].title}> {selects[selectKey].title} <button onClick={@onClickDeleteDropdown.bind(@, selectKey)}><i className="fa fa-close" /></button></li>
          }
          </ul>

        </section>

        <hr />

        <section>
          <h2 className="form-label">Add a dropdown
          <TriggeredModalForm trigger={<i className="fa fa-question-circle"></i>}>
            <p><strong>Title</strong> is what will be displayed as the dropdown title</p>
            <p><strong>Conditional</strong> is which dropdown the new dropdown will be conditional upon</p>
          </TriggeredModalForm></h2>

          <br/>
          <label>
            Title <input ref="selectTitle"></input>
          </label>
          {if selects.length > 0
            <div>
              <span>Conditional </span>

              <select key={"selectCondition-#{@state.dropdown}"} ref="selectCondition">
                <option value="">none selected</option>

                {selectKeys.map (selectKey) =>
                  <option key={selects[selectKey].title} value={selectKey}>{selects[selectKey].title}</option>}
              </select>
            </div>
          }
          <br/>
          <button type="button" onClick={@onClickAddSelect}><i className="fa fa-plus" /> Add Dropdown</button>
        </section>

        <hr/>

        <section>
          <h2 className="form-label">Edit a Dropdown<TriggeredModalForm trigger={<i className="fa fa-question-circle"></i>}>
            <p><strong>Required</strong> is what ...</p>
            <p><strong>Allow Create</strong> is what ...</p>
            <p><strong>Disable Until Condition</strong> is what ...</p>
            <p><strong>Options</strong> are what will be displayed to users as options within the dropdown</p>
          </TriggeredModalForm></h2>

          <span>Dropdown </span>

          <select key={"edit-#{@state.dropdown}"} ref="dropdown" defaultValue={@state.dropdown} onChange={@onChangeDropdown}>
            <option value="" disabled>none selected</option>
            {selectKeys.map (selectKey) =>
              <option key={selects[selectKey].title} value={selectKey}>{selects[selectKey].title}</option>}
          </select>

          {if @state.dropdown
            <div key={@state.dropdown}>
              <br/>
              <h2 className="form-label">Properties</h2>
              <label className="pill-button">
                Required <input type="checkbox" ref="required" defaultChecked={selects[@state.dropdown].required} onChange={@editTask}></input>
              </label>
              <br/>
              <label className="pill-button">
                Allow Create <input type="checkbox" ref="allowCreate" defaultChecked={selects[@state.dropdown].allowCreate} onChange={@editTask}></input>
              </label>
              <br/>

              {if @state.dropdown isnt "0"
                <div>
                  <label className="pill-button">
                  Disable Until Condition <input type="checkbox" ref="disableUntilCondition" defaultChecked={selects[@state.dropdown].disableUntilCondition} onChange={@editTask}></input>
                  </label>
                  <br/>
                </div>
              }

              <br/>
              <h2 className="form-label">Options</h2>

              {if selects[@state.dropdown]?.condition

                condition = selects[@state.dropdown].condition
                conditions = []
                while condition?
                  conditions.push(condition)
                  condition = selects[condition].condition
                conditions.reverse()

                conditions.map (condition) =>
                  conditionalSelect = selects[condition]
                  <div key={Math.random()}>
                    <span>Conditional On {conditionalSelect.title}, option </span>
                    <select ref="conditionalAnswer" defaultValue={@state.answerIndexes[condition]} onChange={@onChangeConditionAnswer.bind(@, condition)}>
                      <option value="">none selected</option>
                      {@getOptions(condition).map (option, index) =>
                        <option key={option} value={index}>{option}</option>}
                    </select>
                  </div>
              }

              <ul>
                {@getOptions(@state.dropdown).map (option) =>
                  <li key={option}>
                    {option}{' '}

                    <button onClick={@onClickDeleteDropdownOption.bind(this, option)} title="Delete">
                      <i className="fa fa-close" />
                    </button>
                  </li>}
              </ul>

              <div className="dropdown-option">
                <label>
                  Option <input ref="selectOption"></input>
                </label>{' '}
              </div>

              <button type="button" onClick={@onClickAddSelectOption}><i className="fa fa-plus" /> Add Dropdown Option</button>

              <br/>
              <br/>

              <span>Preset Options </span>

              <select ref="preset" defaultValue="">
                <option value="">none selected</option>
                <option value="countries">Countries</option>
                <option value="months">Months</option>
              </select>
              <button type="button" onClick={@onClickAddPreset}><i className="fa fa-plus" /> Add Preset Options</button>

              <br/>

              <div className="workflow-task-editor">
                <p><span className="form-label">Import task data</span></p>
                <div className="columns-container" style={marginBottom: '0.2em'}>
                  <FileButton className="major-button column" accept=".csv, .tsv" multiple onSelect={@handleFiles.bind this, @addCSVSelectOption}>Add options CSV</FileButton>
                  <TriggeredModalForm trigger={
                    <span className="secret-button">
                      <i className="fa fa-question-circle"></i>
                    </span>
                  }>
                    {dropdownEditorHelp.options}
                  </TriggeredModalForm>
                </div>
              </div>

            </div>
          }

        </section>

      </div>

      <hr/>

      <AutoSave resource={@props.workflow}>
        <span className="form-label">Next task</span>
        <br />
        <NextTaskSelector workflow={@props.workflow} name="#{@props.taskPrefix}.next" value={@props.task.next ? ''} onChange={handleInputChange.bind @props.workflow} />
      </AutoSave>
    </div>