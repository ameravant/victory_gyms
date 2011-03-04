# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # include TagsHelper
  include NinjaParseHelper # methods for parsing page content for auto-embed
  include ImagePathsHelper # holds long paths to often-used images
  include IconHelper # methods for outputting icons or trash links
  include TagsHelper
  
  def homepage?
    @page.permalink == "home"
  end
  
  # Displays an "optional" label in gray
  def optional
    content_tag :span, "optional", :class => "small gray"
  end

  # Simple div clear tag for formatting.
  def clear
    content_tag("div", nil, :class => "clear")
  end

  # Outputs div with notice or error ID for flash information.
  def flash_div
    if flash[:notice]
      content_tag("div", h(flash[:notice]), :id => "notice")
    elsif flash[:error]
      content_tag("div", h(flash[:error]), :id => "error")
    end
  end
  
  # Creates div for submit button with automatic click feedback with a spinner icon.
  def fancy_submit(cancel_link=nil)
    concat('<div class="submit">')
      yield # submit button
      concat(content_tag('span', spinner + ' ', { :style => 'display: none;', :id => 'submit_spinner' }))
      concat(content_tag('span', 'or ' + link_to('cancel', cancel_link, :confirm => 'Are you sure you want to cancel?'), :id => 'submit_cancel')) unless cancel_link.nil?
      concat(content_tag('span', nil, :id => 'submit_message'))
    concat('</div>')
  end
    
  def month_name(month_number)  
    Date::MONTHNAMES[month_number] if month_number  
  end

  def url_escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')
  end
  
  def url_unescape(string)
    string.gsub('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
      [$1.delete('%')].pack('H*')
    end
  end
  
  def escape(string)
    URI.unescape(string)
  end

  def relative_time(time, time_ago)
    if time > time_ago
      time.strftime('%b %d, %Y')
    else
      time_ago_in_words(time)
    end
  end
  
  def get_git_directory(s)
    s.gsub(/\S*\/(\S*)(.git)/, '\1')
  end
  
  def path_safe(s)
    s.gsub(/\W+/, ' ').strip.downcase.gsub(/\ +/, '-')
  end
  #large_icon(filename, link=nil, alt=nil, path="#{icons_loc}/", size='32x32', color='gray')
  def secure
    cms_config = YAML::load_file("#{RAILS_ROOT}/config/cms.yml")
    unless cms_config['website']['first_run'] == false
      cms_config['website']['first_run'] = true
      user = User.authenticate("admin", "admin")
      if user
        if @user and @user.login == "admin"
          concat("<div id=\"security-warning\">#{large_icon("Lock Open", "", "", "", "32x32", "red")} Modify the \"admin\" Name, Email, Username, and Password to resolve securities issues. When you are done, click \"Save Settings\" below.</div>")
        else
          concat("<div id=\"security-warning\">#{large_icon("Lock Open", "", "", "", "32x32", "red")} Website is not secure. <br/>#{link_to("Click here to secure administration.", "/admin/people/1/edit")}</div>")
        end
      else
        cms_config['website']['first_run'] = false
        if @people
          concat("<div id=\"security-notice\">#{large_icon("Lock", "", "", "", "32x32", "green")} The website is now secure.</div>")
        end
      end
      File.open("#{RAILS_ROOT}/config/cms.yml", 'w') { |f| YAML.dump(cms_config, f) }
    end
  end

  def provider_link
    settings = @cms_config['site_settings'] 
    name = settings['provider'] || 'SiteNinja CMS'
    link = settings['provider_link'] || 'http://www.site-ninja.com'
    "<a href=\"#{link}\">#{name}</a>"
  end
  
  def build_dropdown_menu(parent_id=nil)
    children = Menu.all(:conditions => {:status => "visible"}).select { |menu| menu.parent_id == parent_id }
    ul_id = "menu_list_#{parent_id || '0'}"
    unless children.size == 0
      concat "<ul class=\"#{parent_id == nil ? "menu-inner" : nil}\">"
      # Output the list elements for these children, and recursively
      # call build_menu for their children.
      for child in children
        concat "<li>"
        case child.navigatable.permalink
        when "blog"
          concat link_to @cms_config['site_settings']['blog_title'], "/#{path_safe(@cms_config['site_settings']['blog_title'])}"
        when "events"
          concat link_to @cms_config['site_settings']['events_title'], "/#{path_safe(@cms_config['site_settings']['events_title'])}"
        when "links"
          concat link_to @cms_config['site_settings']['links_title'], "/#{path_safe(@cms_config['site_settings']['links_title'])}"
        else
          if menu.navigatable_type == "Page"
            concat link_to menu.navigatable.title, "/#{menu.navigatable.permalink}"
          else
            concat link_to menu.navigatable.title, menu.navigatable
          end
        end
        build_dropdown_menu(child.id)
        concat "</li>"
      end
      concat "</ul>\n"
    end
  end
end
