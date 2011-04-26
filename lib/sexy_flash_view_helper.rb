# SexyFlash
module SexyFlashViewHelper
  # Helper for flash messages
  # Previously this used Prototype, and has now been migrated to JQuery. Timings have now changed to milliseconds to match JQuery's metrics.
  # == Options
  # * timeout: Flash timeout in milliseconds
  # * duration: Flash effect duration in milliseconds
  # ==
  # i.e: sexy_flash :timeout => 2000, :duration => 1000, :show_effect => "fade", :hide_effect => "fade"
  # If :timeout is <= 0 then the flash message does not get hidden.
  #
  # These same options can be overwritten at when creating the flash, and for that flash message only:
  #
  # i.e:
  # flash[:notice] = 'I just want you to know', {:timeout => 0, :show_effect => 'fade' }

  def sexy_flash(view_options = {})

    the_flash = the_flash_js = ''
    fancybox_resize_js = '$.fancybox.resize();' if view_options[:fancybox]

    global_timeout = view_options[:timeout] ? view_options[:timeout] : 0
    global_duration = view_options[:duration] || 2000
    global_show_effect = view_options[:show_effect] || 'fade'
    global_hide_effect = view_options[:hide_effect] || 'fade'
    global_target = view_options[:target] || nil
    global_debug = view_options[:debug] ? true : false

    # Convert :alert to :error for Devise
    if flash.has_key?(:alert)
      flash[:error] = flash[:alert]
      flash.delete :alert
    end
    
    [:error, :warning, :info, :notice].each do |key|
      if flash.has_key?(key)
        # Set options specific to this flash message:
        flash_options = flash[(key.to_s + '_options').to_sym]
        timeout = flash_options.has_key?(:timeout) ? flash_options[:timeout] : global_timeout
        duration = flash_options[:duration] || global_duration
        show_effect = flash_options[:show_effect] || global_show_effect
        hide_effect = flash_options[:hide_effect] || global_hide_effect
        target = flash_options[:target] || nil

        if (global_target.nil? and target.nil?) or target == global_target
          the_flash += content_tag(:div, flash[key], :class => 'flash', :id => "flash_#{key}", :style => "display: #{show_effect.blank? ? 'block' : 'none'};")
          the_flash_js += "$('#flash_#{key}').show('#{show_effect}',{}, #{duration});\n"
          the_flash_js += "$('#flash_#{key}').delay(#{timeout}).hide('#{hide_effect}', {}, #{duration}, function(){#{fancybox_resize_js}});\n" if timeout > 0
        end

      end #if flash.has_key?(key)
    end #each do |key|

    the_flash_js += fancybox_resize_js unless fancybox_resize_js.blank?
    the_flash += javascript_tag the_flash_js unless the_flash.blank?
    the_flash += javascript_tag "alert('#{escape_javascript the_flash}');" if global_debug

    return the_flash.html_safe
  end

end