Rails.application.config.after_initialize do

  ApplicationHelper.class_eval do
    alias_method :render_aspace_partial_pre_yale_onsite_locations, :render_aspace_partial
    def render_aspace_partial(args)
      result = render_aspace_partial_pre_yale_onsite_locations(args)

      if args[:partial] == "locations/form"
        result += render_aspace_partial(:partial => 'locations/form_ext',
                                        :locals => args[:locals])
      elsif args[:partial] == "locations/form_batch"
        result += render_aspace_partial(:partial => 'locations/form_batch_ext',
                                        :locals => args[:locals])
      end

      result
    end
  end

end
