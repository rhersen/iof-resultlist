tag = React.DOM

getTime = (totalSeconds, status) ->
  if status isnt 'OK'
    return status
  seconds = totalSeconds % 60
  minutes = (totalSeconds - seconds) / 60
  if seconds < 10
    minutes + ':0' + seconds
  else
    minutes + ':' + seconds

getPerson = (i, p) ->
  name: $(p).find('Person Name Given').text() + ' ' + $(p).find('Person Name Family').text()
  position: $(p).find('Result > Position').text()
  time: getTime $(p).find('Result > Time').text(), $(p).find('Result > Status').text()

window.getResult = (doc) ->
  result = {}
  $(doc).find('ClassResult').each (i, c) ->
    className = $(c).find('Class Name').text()
    persons = $(c).find('PersonResult').map getPerson
    result[className] = $.makeArray persons
  result

window.PersonResult = React.createClass
  render: ->
    tag.tr {},
      tag.td {}, @props.person.position
      tag.td {}, @props.person.name
      tag.td {}, @props.person.time

window.ClassResult = React.createClass
  render: ->
    tag.table {},
      tag.caption
        children: [@props.name].concat @props.persons.map (person) ->
          PersonResult
            person: person

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