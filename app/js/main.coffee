tag = React.DOM

getTime = (totalSeconds, status = 'OK') ->
  if status is 'MissingPunch' then return 'felst.'
  if status is 'DidNotStart' then return 'dns'
  if status isnt 'OK' then return status
  seconds = totalSeconds % 60
  minutes = (totalSeconds - seconds) / 60
  if seconds < 10
    minutes + ':0' + seconds
  else
    minutes + ':' + seconds

getSplits = (splits) ->
  intermediate = $.makeArray (splits).map (i, split) -> $(split).text()
  prev = 0
  intermediate.map (current) ->
    seconds = current - prev
    prev = current
    getTime seconds

getPerson = (i, person) ->
  p = $ person
  name: ['Given', 'Family'].map((field)-> p.find('Person > Name > ' + field).text()).join ' '
  position: p.find('Result > Position').text()
  time: getTime p.find('Result > Time').text(), p.find('Result > Status').text()
  splits: getSplits p.find('Result > SplitTime > Time')

window.getResult = (doc) ->
  result = {}
  $(doc).find('ClassResult').each (i, c) ->
    className = $(c).find('Class Name').text()
    persons = $(c).find('PersonResult').map getPerson
    result[className] = $.makeArray persons
  result

window.PersonResult = React.createClass
  render: ->
    person = [ tag.td {}, @props.person.position, tag.td {className: 'name'}, @props.person.name ]
    splits = @props.person.splits.map((split) -> tag.td {className: 'split'}, split)
    time = [tag.td {className: 'total'}, @props.person.time]
    tag.tr children: [].concat person, splits, time

window.ClassResult = React.createClass
  render: ->
    tag.table {},
      tag.caption
        children: [@props.name].concat @props.persons.map (person) -> PersonResult person: person

window.ReactRoot = React.createClass
  getInitialState: ->
    classes: []

  componentDidMount: ->
    $.ajax
      url: 'result.xml'
      success: @setResult

  setResult: (doc) ->
    @setState classes: getResult doc

  render: ->
    tag.div {},
      children: _.map @state.classes, (value, key) ->
        ClassResult
          name: key
          persons: value