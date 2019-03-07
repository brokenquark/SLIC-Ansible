class PlosFulltext < Source
  def get_query_url(work, options = {})
    # don't query if work is PLOS article
    return {} if work.doi =~ /^10.1371/ || !registration_agencies.include?(work.registration_agency)

    query_string = get_query_string(work)
    return {} unless query_string.present?

    url % { query_string: query_string }
  end

  def get_query_string(work)
    [work.doi, work.canonical_url].compact.map { |i| "everything:%22#{i}%22" }.join("+OR+")
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    related_works = get_related_works(result, work)
    total = related_works.length
    events_url = total > 0 ? get_events_url(work) : nil

    { works: related_works,
      events: {
        source: name,
        work: work.pid,
        total: total,
        events_url: events_url,
        extra: get_extra(result),
        days: get_events_by_day(related_works, work),
        months: get_events_by_month(related_works) } }
  end

  def get_related_works(result, work)
    result.fetch("response", {}).fetch("docs", []).map do |item|
      timestamp = get_iso8601_from_time(item.fetch("publication_date", nil))
      doi = item.fetch("id", nil)

      { "author" => get_authors(item.fetch("author_display", [])),
        "title" => item.fetch("title", ""),
        "container-title" => item.fetch("cross_published_journal_name", []).first,
        "issued" => get_date_parts(timestamp),
        "timestamp" => timestamp,
        "DOI" => doi,
        "type" => "article-journal",
        "tracked" => tracked,
        "registration_agency" => "crossref",
        "related_works" => [{ "related_work" => work.pid,
                              "source" => name,
                              "relation_type" => "cites" }] }
    end
  end

  def get_extra(result)
    result.fetch("response", {}).fetch("docs", []).map do |item|
      event_time = get_iso8601_from_time(item.fetch("publication_date", nil))
      doi = item.fetch("id")

      { event: item,
        event_time: event_time,
        event_url: "http://doi.org/#{doi}",

        # the rest is CSL (citation style language)
        event_csl: {
          "author" => get_authors(item.fetch("author_display", [])),
          "title" => item.fetch("title", ""),
          "container-title" => item.fetch("cross_published_journal_name", []).first,
          "issued" => get_date_parts(event_time),
          "DOI" => doi,
          "type" => "article-journal" }
      }
    end
  end

  def config_fields
    [:url, :events_url]
  end

  def url
    "http://api.plos.org/search?q=%{query_string}&fq=doc_type:full&fl=id,publication_date,title,cross_published_journal_name,author_display&wt=json&rows=1000"
  end

  def events_url
    "http://www.plosone.org/search/advanced?unformattedQuery=%{query_string}"
  end

  def registration_agencies
    ["datacite", "dataone", "cdl", "github", "bitbucket"]
  end
end
