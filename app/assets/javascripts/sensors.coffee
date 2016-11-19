# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.sensors_poll_count = 0

$(document).on 'click', '#sensors_poll_btn', (evt) ->
  evt.preventDefault()
  if window.sensors_poll_count <= 0
    window.sensors_poll_count = 20
    setTimeout ( ->
      poll_sensors_update()
    ), 1000

$(document).on 'toggle', '#sensor_led', (evt) ->
  $.ajax '/sensors/update',
    type: 'POST'
    dataType: 'text'
    data: {
      data_type: 'toggle',
      setting_name: evt.target.id,
      setting_value: evt.target.className.split(" ")
    }

poll_sensors_update = () ->
  window.sensors_poll_count = window.sensors_poll_count - 1
  $("#poll_message").html("POLLING... Trigger sensors and count should increase.")
  $("#sensors_poll_btn").removeClass('btn-positive').addClass('btn-negative')
  $.ajax '/sensors/poll_update',
    type: 'GET'
    success: (data) ->
      $('#proximity_count_value').html(data.proximity)
      $('#vibration_count_value').html(data.vibration)
    complete: () ->
      if window.sensors_poll_count > 0
        setTimeout ( ->
            poll_sensors_update()
          ), 1000
      else
        $("#poll_message").html("Press the Poll button to check if sensors are working. It will poll every second for 20 seconds. Every poll it checks sensor value.")
        $("#sensors_poll_btn").removeClass('btn-negative').addClass('btn-positive')
