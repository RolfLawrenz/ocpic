# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'toggle', '.camera_setting_toggle', (evt) ->
  $.ajax '/camera/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'toggle',
      setting_name: evt.target.id
      setting_value: evt.target.className.split(" ")
    }
    error: (data) ->
      alert('ERROR attempting to set '+data.responseText)

$(document).on 'change', '.camera_setting_text', (evt) ->
  $.ajax '/camera/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'text',
      setting_name: evt.target.id
      setting_value: evt.target.value
    }
    error: (data) ->
      alert('ERROR attempting to set '+data.responseText)

$(document).on 'change', '.camera_setting_select', (evt) ->
  $.ajax '/camera/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'select',
      setting_name: evt.target.id
      setting_value: evt.target.value
    }
    error: (data) ->
      alert('ERROR attempting to set '+data.responseText)

$(document).on 'change', '.camera_setting_range', (evt) ->
  $.ajax '/camera/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'range',
      setting_name: evt.target.id
      setting_value: evt.target.value
    }
    error: (data) ->
      alert('ERROR attempting to set '+data.responseText)

$(document).on 'click', '#take_photo_btn', (evt) ->
  evt.preventDefault()
  $.ajax '/camera/take_photo',
    type: 'POST'
    dataType: 'text'
    data: {
      photo: "take"
    }
