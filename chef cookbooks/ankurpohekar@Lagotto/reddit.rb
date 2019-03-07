class Reddit < Source
  def parse_data(result, work, options={})
    return result if result[:error]

    result = result.deep_fetch('data', 'children') { [] }

    likes = get_sum(result, 'data', 'score')
    comments = get_sum(result, 'data', 'num_comments')
    total = likes + comments
    related_works = get_related_works(result, work)
    extra = get_extra(result)
    events_url = total > 0 ? get_events_url(work) : nil

    { works: related_works,
      events: {
        source: name,
        work: work.pid,
        comments: comments,
        likes: likes,
        total: total,
        events_url: events_url,
        extra: extra,
        days: get_events_by_day(related_works, work),
        months: get_events_by_month(related_works) } }
  end

  def get_related_works(result, work)
    result.map do |item|
      data = item.fetch('data', {})
      timestamp = get_iso8601_from_epoch(data.fetch('created_utc', nil))
      url = data.fetch('url', nil)

      { "author" => get_authors([data.fetch('author', "")]),
        "title" => data.fetch("title", ""),
        "container-title" => "Reddit",
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => url,
        "type" => "personal_communication",
        "tracked" => tracked,
        "registration_agency" => "reddit",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "discusses" }] }
    end
  end

  def get_extra(result)
    result.map do |item|
      data = item['data']
      event_time = get_iso8601_from_epoch(data['created_utc'])
      url = data['url']

      { event: data,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([data.fetch('author', "")]),
          'title' => data.fetch('title', ""),
          'container-title' => 'Reddit',
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'personal_communication' }
      }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://www.reddit.com/search.json?q=%{query_string}&limit=100"
  end

  def events_url
    "http://www.reddit.com/search?q=%{query_string}" #query_string is combination of DOI and canonical url
  end

  def job_batch_size
    config.job_batch_size || 100
  end

  def rate_limiting
    config.rate_limiting || 1800
  end

  def queue
    config.queue || "low"
  end
end
