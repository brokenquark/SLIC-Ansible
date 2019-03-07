class ArticleCoverage < Source
  # include common methods for Article Coverage
  include Coverable

  def parse_data(result, work, options = {})
    if !result.is_a?(Hash)
      # make sure we have a hash
      result = { 'data' => result }
      result.extend Hashie::Extensions::DeepFetch
    elsif result[:status] == 404
      # properly handle not found errors
      result = { 'data' => [] }
      result.extend Hashie::Extensions::DeepFetch
    elsif result[:error]
      # return early if an error occured that is not a not_found error
      return result
    end

    extra = get_extra(result)
    metrics = get_metrics(comments: extra.length)

    { events: {
        source: name,
        work: work.pid,
        comments: metrics[:comments],
        total: metrics[:total],
        extra: extra } }
  end

  def get_extra(result)
    Array(result['referrals']).map do |item|
      { event: item,
        event_time: get_iso8601_from_time(item['published_on']),
        event_url: item['referral'] }
    end
  end
end
