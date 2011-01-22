# SexyFlash
module SexyFlashViewHelper

  #helper for flash messages
  # == Options
  # * timeout: Flash timeout in seconds
  # * duration: Flash effect duration
  # ==
  # i.e: sexy_flash :timeout => 2, :duration => 1, :show_effect => "BlindDown", :hide_effect => "BlindUp"
  # If :timeout is set to be 0 or less then 0. Don't hide the flash message
  #
  # These same options can be overwritten at when creating the flash, and for that flash message only:
  #
  # i.e:
  # flash[:notice] = 'I just want you to know', {:timeout => 0, :show_effect => 'BlindDown' }
  #
  # for fadeIn and fadeOut show/hide effects used jQuery core functions (with duration and timeout applied), so no need jQueryUI, for the rest its required

  def sexy_flash(view_options = {})

    the_flash = the_flash_js = ''
    fancybox_resize_js = '$.fancybox.resize();' if view_options[:fancybox]

    global_timeout = view_options[:timeout] ? view_options[:timeout]*1000 : 0
    global_duration = view_options[:duration] || 0
    global_show_effect = view_options[:show_effect] || 'fadeIn'
    global_hide_effect = view_options[:hide_effect] || 'fadeOut'
    global_target = view_options[:target] || nil
    global_debug = view_options[:debug] ? true : false

    [:error, :warning, :info, :notice].each do |key|
      if flash.has_key?(key)
        #set options specific to this flash message:
        flash_options = flash[(key.to_s + '_options').to_sym]
        timeout = flash_options.has_key?(:timeout) ? flash_options[:timeout]*1000 : global_timeout
        duration = flash_options[:duration] || global_duration
        show_effect = flash_options[:show_effect] || global_show_effect
        hide_effect = flash_options[:hide_effect] || global_hide_effect
        target = flash_options[:target] || nil

        if (global_target.nil? and target.nil?) or target == global_target

          the_flash += content_tag(:div, flash[key], :class => 'flash', :id => "flash_#{key}",
            :style => "display: #{show_effect.blank? ? 'block' : 'none'};")

          if show_effect
            if show_effect == 'fadeIn'
              duration || "'slow'"
              the_flash_js += "$('#flash_#{key}').fadeIn(#{duration});\n"
            else
              the_flash_js += "new Effect.#{show_effect}('flash_#{key}', {duration: #{duration}});\n" # add later!
            end
          end

          if timeout > 0
            if hide_effect
              if hide_effect == 'fadeOut'
                the_flash_js += "$('#flash_#{key}').delay(#{timeout}).fadeOut(function(){#{fancybox_resize_js}});\n"
              else
                the_flash_js += "setTimeout(\"Effect.#{hide_effect}('#flash_#{key}')\", #{timeout})" #add later!
              end
            else
              the_flash_js += "$('#flash_#{key}').delay(#{timeout}).hide(function(){#{fancybox_resize_js}});\n"
            end
          end #if timeout > 0

        end

      end #if flash.has_key?(key)
    end #each do |key|

    the_flash_js += "$('.flash').corner('round 5px');\n"
    the_flash_js += fancybox_resize_js unless fancybox_resize_js.blank?
    the_flash += javascript_tag the_flash_js unless the_flash.blank?
    the_flash += javascript_tag "alert('#{escape_javascript the_flash}');" if global_debug

    return the_flash.html_safe
  end

end