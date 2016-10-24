module SettingsHelper

  def setting_label_field(field, shooting_mode, time_mode)
    case field[:type]
      when :range
        name = "#{field[:name]} (#{field[:options][0]}..#{field[:options][-1]})"
      else
        name = field[:name]
    end
    label_tag("field_#{shooting_mode}_#{time_mode}_#{field[:name]}", name, class: 'label_setting')
  end

  def setting_setting_field(field, shooting_mode, time_mode)
    html = ""
    case field[:type]
      when :toggle
        html =  "<div id='field_#{shooting_mode}_#{time_mode}_#{field[:name]}' data-shooting-mode='#{shooting_mode}' data-time-mode='#{time_mode}' class=\"setting_setting_toggle toggle#{ field[:value] ? ' active' : ''}\">\n"
        html += "  <div class=\"toggle-handle\"></div>\n"
        html += "</div>\n"
      when :text
        html = text_field_tag("field_#{shooting_mode}_#{time_mode}_#{field[:name]}", field[:value], class: "setting_setting_text setting_field setting_text_field", data: {shooting_mode: shooting_mode, time_mode: time_mode})
      when :radio
        select_values = field[:options].map{|opt| [opt, opt]}
        html = select_tag("field_#{shooting_mode}_#{time_mode}_#{field[:name]}", options_for_select(select_values, field[:value]), class: "setting_setting_select setting_field setting_select_field", data: {shooting_mode: shooting_mode, time_mode: time_mode})
      when :range
        html = text_field_tag("field_#{shooting_mode}_#{time_mode}_#{field[:name]}", field[:value], class: "setting_setting_range setting_field setting_text_field", data: {shooting_mode: shooting_mode, time_mode: time_mode})
      when :date
        html = text_field_tag("field_#{shooting_mode}_#{time_mode}_#{field[:name]}", field[:value], class: "setting_setting_date setting_field setting_text_field", data: {shooting_mode: shooting_mode, time_mode: time_mode})
    end
    html.html_safe
  end

end
