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

  ResourcesController.class_eval do
    alias_method :fetch_containers_pre_yale_onsite_locations, :fetch_containers
    def fetch_containers(resource_uri, page_uri, params)
      result = fetch_containers_pre_yale_onsite_locations(resource_uri, page_uri, params)

      @results.records.each do |record|
        if record.json['indicator'] && record.json['onsite_status']
          record.json['indicator'] += " — #{I18n.t("yale_onsite_locations.onsite_status_u_sstr.#{record.json['onsite_status']}", :default => record.json['onsite_status'])}"
        end
      end

      result
    end
  end

  ContainersController.class_eval do
    alias_method :show_pre_yale_onsite_locations, :show
    def show
      result = show_pre_yale_onsite_locations

      if @result
        if @result.json['indicator'] && @result.json['onsite_status']
          @result.json['indicator'] += " — #{I18n.t("yale_onsite_locations.onsite_status_u_sstr.#{@result.json['onsite_status']}", :default => @result.json['onsite_status'])}"
        end
      end

      result
    end
  end
end