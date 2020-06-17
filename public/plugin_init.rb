Rails.application.config.after_initialize do
  SearchController::DEFAULT_SEARCH_FACET_TYPES << 'onsite_status_u_sstr'
  ResourcesController::DEFAULT_RES_FACET_TYPES << 'onsite_status_u_sstr'
  RepositoriesController::DEFAULT_SEARCH_FACET_TYPES << 'onsite_status_u_sstr'
  AccessionsController::DEFAULT_AC_FACET_TYPES << 'onsite_status_u_sstr'

  module HandleFaceting
    alias_method :get_pretty_facet_value_pre_yale_onsite_locations, :get_pretty_facet_value
    def get_pretty_facet_value(k, v)
      if k == 'onsite_status_u_sstr'
        I18n.t("yale_onsite_locations.onsite_status_u_sstr.#{v}", :default => v)
      else
        get_pretty_facet_value_pre_yale_onsite_locations(k, v)
      end
    end
  end

  Record.class_eval do
    alias_method :parse_sub_container_display_string_pre_yale_onsite_locations, :parse_sub_container_display_string
    def parse_sub_container_display_string(sub_container, inst, opts = {})
      display_string = parse_sub_container_display_string_pre_yale_onsite_locations(sub_container, inst, opts)

      return display_string if opts.fetch(:summary, false)

      if (onsite_status = sub_container.dig('top_container', '_resolved', 'onsite_status'))
        display_string += " — #{I18n.t("yale_onsite_locations.onsite_status_u_sstr.#{onsite_status}", :default => onsite_status)}"
      end

      display_string
    end
  end
end