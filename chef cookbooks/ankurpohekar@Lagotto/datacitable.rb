module Datacitable
  extend ActiveSupport::Concern

  included do
    def get_events_url(work)
      if events_url.present? && work.doi.present?
        events_url % { doi: work.doi_escaped }
      end
    end

    def config_fields
      [:url, :events_url]
    end
  end
end
