# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Traditional $ -> does not on iphone. Must use $(document).on here.

$(document).on 'change', '#program_name', (evt) ->
  $.ajax '/program/update',
    type: 'POST'
    dataType: 'text'
    data: {
      program_name: $('#program_name :selected').val()
    }

$(document).on 'change', '#timelapse_mode', (evt) ->
  $.ajax '/program/update',
    type: 'POST'
    dataType: 'text'
    data: {
      timelapse_mode: $('#timelapse_mode :selected').val()
    }

$(document).on 'change', '#interval', (evt) ->
  $.ajax '/program/update',
    type: 'POST'
    dataType: 'text'
    data: {
      interval: $('#interval').val()
    }

$(document).on 'toggle', '#sensor_proximity', (evt) ->
  $.ajax '/program/update',
    type: 'POST'
    dataType: 'text'
    data: {
      sensor_proximity: $('#sensor_proximity').attr('class')
    }

$(document).on 'toggle', '#sensor_vibration', (evt) ->
  $.ajax '/program/update',
    type: 'POST'
    dataType: 'text'
    data: {
      sensor_vibration: $('#sensor_vibration').attr('class')
    }
