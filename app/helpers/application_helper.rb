module ApplicationHelper

  def footer_table_cell(name)
    active = params[:controller] == name
    "<td class=\"bar-footer-tab#{active ? '-active' : ''}\"><a href=\"/#{name}/index\">#{image_tag("#{name}.png", class: "tab-icon")}</a></td>".html_safe
  end

  def reload_path
    query = ''
    query = "?#{params.to_h.to_query}" if params.present?
    request.original_url + query
  end

end
