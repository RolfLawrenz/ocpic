module CameraHelper

  def camera_label_field(field)
    case field[:type]
      when :range
        name = "#{field[:name]} (#{field[:options][0]}..#{field[:options][-1]})"
      else
        name = field[:name]
    end
    label_tag("field_#{field[:name]}", name, class: 'label_setting')
  end

  def camera_setting_field(field)
    html = ""
    case field[:type]
      when :toggle
        html =  "<div id='field_#{field[:name]}' class=\"camera_setting_toggle toggle#{ field[:value] ? ' active' : ''}\">\n"
        html += "  <div class=\"toggle-handle\"></div>\n"
        html += "</div>\n"
      when :text
        html = text_field_tag("field_#{field[:name]}", field[:value], class: "camera_setting_text setting_field setting_text_field", disabled: Camera::Camera::MENU_FIELDS_DISABLED.include?(field[:name]))
      when :radio
        select_values = field[:options].map{|opt| [opt, opt]}
        html = select_tag("field_#{field[:name]}", options_for_select(select_values, field[:value]), class: "camera_setting_select setting_field setting_select_field")
      when :range
        html = text_field_tag("field_#{field[:name]}", field[:value], class: "camera_setting_range setting_field setting_text_field", disabled: Camera::Camera::MENU_FIELDS_DISABLED.include?(field[:name]))
      when :date
        html = text_field_tag("field_#{field[:name]}", field[:value], class: "camera_setting_date setting_field setting_text_field", disabled: Camera::Camera::MENU_FIELDS_DISABLED.include?(field[:name]))
    end
    html.html_safe
  end
end
