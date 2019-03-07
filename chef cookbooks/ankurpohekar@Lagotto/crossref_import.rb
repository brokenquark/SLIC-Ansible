class CrossrefImport < Import

  def initialize(options = {})
    @from_update_date = options.fetch(:from_update_date, nil)
    @from_update_date = (Time.zone.now.to_date - 1.day).iso8601 if from_update_date.blank?

    @until_update_date = options.fetch(:until_update_date, nil)
    @until_update_date = Time.zone.now.to_date.iso8601 if until_update_date.blank?

    @from_pub_date = options.fetch(:from_pub_date, nil)

    @until_pub_date = options.fetch(:until_pub_date, nil)
    @until_pub_date = Time.zone.now.to_date.iso8601 if until_pub_date.blank?

    @member = options.fetch(:member, nil)
    @type = options.fetch(:type, nil)
    @issn = options.fetch(:issn, nil)
    @sample = options.fetch(:sample, 0).to_i
  end

  def total_results
    result = get_result(query_url(offset = 0, rows = 0)) || {}
    result.fetch('message', {}).fetch('total-results', 0)
  end

  def query_url(offset = 0, rows = 10) #before rows = 1000
    url = "http://api.crossref.org/works?"
    mem = member.split(",") if member.present?

    filter = "from-update-date:#{from_update_date}"
    filter += ",until-update-date:#{until_update_date}"
    filter += ",until-pub-date:#{until_pub_date}"
    filter += ",from-pub-date:#{from_pub_date}" if from_pub_date
    filter += ",type:#{type}" if type
    filter += ",issn:#{issn}" if issn
    filter += mem.reduce("") { |sum, m| sum + ",member:#{m}" } if member.present?

    if sample > 0
      params = { filter: filter, sample: sample }
    else
      params = { filter: filter, offset: offset, rows: rows }
    end
    url + params.to_query
  end

  def get_data(options={})
    offset = options[:offset].to_i
    get_result(query_url(offset), options)
  end

  def parse_data(result)
    # return early if an error occured
    return [] unless result && result.fetch('status', nil) == "ok"

    items = result.fetch('message', {}).fetch('items', nil)
    Array(items).map do |item|
      doi = item.fetch("DOI", nil)
      canonical_url = item.fetch("URL", nil)
      date_parts = item.fetch("issued", {}).fetch("date-parts", []).first
      year, month, day = date_parts[0], date_parts[1], date_parts[2]

      # use date indexed if date issued is in the future
      if year.nil? || Date.new(*date_parts) > Time.zone.now.to_date
        date_parts = item.fetch("indexed", {}).fetch("date-parts", []).first
        year, month, day = date_parts[0], date_parts[1], date_parts[2]
      end

      title = case item["title"].length
              when 0 then nil
              when 1 then item["title"][0]
              else item["title"][0].presence || item["title"][1]
              end

      if title.blank? && !TYPES_WITH_TITLE.include?(item["type"])
        title = item["container-title"][0].presence || "No title"
      end
      publisher_id = item.fetch("member", nil)
      publisher_id = publisher_id[30..-1].to_i if publisher_id

      type = item.fetch("type", nil)
      type = CROSSREF_TYPE_TRANSLATIONS[type] if type
      work_type_id = WorkType.where(name: type).pluck(:id).first

      csl = {
        "issued" => { "date-parts" => [date_parts] },
        "author" => item.fetch("author", []),
        "container-title" => item.fetch("container-title", [])[0],
        "page" => item.fetch("page", nil),
        "issue" => item.fetch("issue", nil),
        "title" => title,
        "type" => type,
        "DOI" => doi,
        "URL" => canonical_url,
        "publisher" => item.fetch("publisher", nil),
        "volume" => item.fetch("volume", nil)
      }

      { doi: doi,
        title: title,
        year: year,
        month: month,
        day: day,
        publisher_id: publisher_id,
        work_type_id: work_type_id,
        registration_agency: "crossref",
        tracked: true,
        csl: csl }
    end
  end
end
