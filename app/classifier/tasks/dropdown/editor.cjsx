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

module?.exports = React.createClass
  displayName: 'DropdownEditor'

  getInitialState: ->
    dropdown: ''
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
      return window.alert('Dropdowns must have a Title')

    selectTitles = @props.task.selects.map (select) -> select.title

    if selectTitles.indexOf(select.title) isnt -1
      return window.alert('Dropdowns must have a unique Title')

    @setState({dropdown: i})
    @props.task.selects[i] = select
    @updateTasks()

  addSelectOption: (i, option) ->
    if not option
      return window.alert('Please provide an option')

    if @getSelectOptions().indexOf(option) isnt -1
      return window.alert('Options must be unique to each dropdown')

    @props.task.selects[i].options?.push(option)
    @updateTasks()

  getSelectOptions: ->
    # TODO build conditional dropdown options get

    {selects} = @props.task
    select = selects[@state.dropdown]

    if select.options.length?
      console.log 'get select options...'
      options = select.options
      console.log options
      return options

  onClickAddSelect: (e) ->
    @addSelect(@props.task.selects.length, {
      title: @refs.selectTitle.value,
      options: []
    })
    @updateTasks()

    @refs.selectTitle.value = ''

  onClickAddSelectOption: (e) ->
    @addSelectOption(@state.dropdown, @refs.selectOption.value)
    @refs.selectOption.value = ''

  onChangeDropdown: (e) ->
    @setState({dropdown: e.target.value})

  onClickDeleteDropdown: (selectKey) ->
    if window.confirm('Are you sure that you would like to delete this dropdown?')
      @props.task.selects.splice(selectKey, 1)
      @setState {dropdown: ''}, =>
        @updateTasks()

  onClickDeleteDropdownOption: (dropdownOption) ->
    {selects} = @props.task

    if window.confirm('Are you sure that you would like to delete this option?')
      selects[@state.dropdown]?.options = @getSelectOptions().filter (option) -> option isnt dropdownOption
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
          </TriggeredModalForm></h2>

          <br/>
          <label>
            Title <input ref="selectTitle"></input>
          </label>
          <br/>
          <button type="button" onClick={@onClickAddSelect}><i className="fa fa-plus" /> Add Dropdown</button>
        </section>

        <hr/>

        <section>
          <h2 className="form-label">Edit dropdown options<TriggeredModalForm trigger={<i className="fa fa-question-circle"></i>}>
            <p><strong>Options</strong> are what will be displayed to users as options within the dropdown</p>
          </TriggeredModalForm></h2>

          <span>Dropdown </span>

          <select key={@state.dropdown} ref="dropdown" defaultValue={@state.dropdown} onChange={@onChangeDropdown}>
            <option value="" disabled>none selected</option>

            {selectKeys.map (selectKey) =>
              <option key={selects[selectKey].title} value={selectKey}>{selects[selectKey].title}</option>}
          </select>

          {if @state.dropdown
            <div>
              <ul>
                {@getSelectOptions().map (option) =>
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
