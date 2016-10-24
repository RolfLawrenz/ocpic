# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'toggle', '.setting_setting_toggle', (evt) ->
  $.ajax '/settings/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'toggle',
      setting_name: evt.target.id
      setting_value: evt.target.className.split(" ")
#      shooting_mode: 'a'
#      time_mode: 'b'
    }
    error: (data) ->
      alert('ERROR attempting to set '+data.responseText)

$(document).on 'change', '.setting_setting_text', (evt) ->
  $.ajax '/settings/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'text',
      setting_name: evt.target.id
      setting_value: evt.target.value
    }
    error: (data) ->
      alert('ERROR attempting to set '+data.responseText)

$(document).on 'change', '.setting_setting_select', (evt) ->
  $.ajax '/settings/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'select',
      setting_name: evt.target.id
      setting_value: evt.target.value
    }
    error: (data) ->
      alert('ERROR attempting to set '+data.responseText)

$(document).on 'change', '.setting_setting_range', (evt) ->
  $.ajax '/settings/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'range',
      setting_name: evt.target.id
      setting_value: evt.target.value
    }
    error: (data) ->
      alert('ERROR attempting to set '+data.responseText)
