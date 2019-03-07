class Researchblogging < Source
  def request_options
    { content_type: 'xml', username: username, password: password }
  end

  def get_query_string(work)
    return {} unless work.doi.present?

    work.doi_escaped
  end

  def get_related_works(result, work)
    related_works = result.deep_fetch('blogposts', 'post') { nil }
    related_works = [related_works] if related_works.is_a?(Hash)
    Array(related_works).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("published_date", nil))

      { "author" => get_authors([item.fetch('blogger_name', nil)]),
        "title" => item.fetch('post_title', "No title"),
        "container-title" => item.fetch('blog_name', nil),
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "URL" => item.fetch("post_URL", nil),
        "type" => 'post',
        "tracked" => tracked,
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "discusses" }] }
    end
  end

  def get_extra(result)
    extra = result.deep_fetch('blogposts', 'post') { nil }
    extra = [extra] if extra.is_a?(Hash)
    Array(extra).map do |item|
      event_time = get_iso8601_from_time(item["published_date"])
      url = item['post_URL']

      { event: item,
        event_time: event_time,
        event_url: url,

        # the rest is CSL (citation style language)
        event_csl: {
          'author' => get_authors([item.fetch('blogger_name', "")]),
          'title' => item.fetch('post_title', ""),
          'container-title' => item.fetch('blog_name', ""),
          'issued' => get_date_parts(event_time),
          'url' => url,
          'type' => 'post'
        }
      }
    end
  end

  def config_fields
    [:url, :events_url, :username, :password]
  end

  def url
    "http://researchbloggingconnect.com/blogposts?count=100&article=doi:%{query_string}"
  end

  def events_url
    "http://researchblogging.org/post-search/list?article=%{query_string}"
  end

  def staleness_year
    config.staleness_year || 1.month
  end

  def rate_limiting
    config.rate_limiting || 2000
  end

  def job_batch_size
    config.job_batch_size || 50
  end

  def tracked
    config.tracked || true
  end
end
