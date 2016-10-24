module ApplicationHelper

  def application_title
    title = 'Home'
    title = params[:controller].titleize if params[:controller]
    title
  end

  def footer_table_cell(name)
    active = params[:controller] == name
    "<td class=\"bar-footer-tab#{active ? '-active' : ''}\"><a href=\"/#{name}/index\">#{image_tag("#{name}.png", class: "tab-icon")}</a></td>".html_safe
  end

  def reload_path
    query = ''
    query = "?#{params.to_h.to_query}" if params.present?
    request.original_url + query
  end

  def back_path
    if @back_path
      link_to "", @back_path, class: "icon icon-left-nav pull-left"
    end
  end

end
