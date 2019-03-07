require "rails_helper"

describe "/api/v6/events", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=6",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=6",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "index" do
    context "JSON" do
      let(:works) { FactoryGirl.create_list(:work_with_events, 5) }
      let(:work) { works.first }
      let(:work_list) { works.map { |work| "#{work.pid}" }.join(",") }
      let(:uri) { "/api/events?ids=#{work_list}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["events"].length).to eq(10)

        item = response["events"].find { |i| i["work_id"] == work.pid }
        expect(item["source_id"]).to eq("citeulike")
        expect(item["total"]).to eq(50)
        expect(item["readers"]).to eq(50)
        expect(item["events_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
        expect(item["by_day"]).to be_empty
        expect(item["by_month"]).not_to be_nil
        expect(item["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["events"].length).to eq(10)

        item = response["events"].find { |i| i["work_id"] == work.pid }
        expect(item["source_id"]).to eq("citeulike")
        expect(item["work_id"]).to eq(work.pid)
        expect(item["total"]).to eq(50)
        expect(item["readers"]).to eq(50)
        expect(item["events_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
        expect(item["by_day"]).to be_empty
        expect(item["by_month"]).not_to be_nil
        expect(item["by_year"]).not_to be_nil
      end

      it "can be sorted by retrieval_statuses.id using the created_at query parameter" do
        get "/api/events?sort=created_at", nil, headers
        response = JSON.parse(last_response.body)
        data = response["events"]
        actual_work_ids = data.map{ |work| work["work_id"] }

        expected_work_ids = RetrievalStatus.all
          .includes(:work)
          .order("retrieval_statuses.id ASC")
          .map(&:work)
          .map(&:pid)

        expect(actual_work_ids).to eq(expected_work_ids)
      end
    end

    context "show" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/works/#{work.pid}/events" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(2)

        item = response["events"].first
        expect(item["source_id"]).to eq("citeulike")
        expect(item["work_id"]).to eq(work.pid)
        expect(item["total"]).to eq(50)
        expect(item["readers"]).to eq(50)
        expect(item["events_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
        expect(item["by_day"]).to be_empty
        expect(item["by_month"]).not_to be_nil
        expect(item["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["meta"]["total"]).to eq(2)

        item = response["events"].first
        expect(item["source_id"]).to eq("citeulike")
        expect(item["work_id"]).to eq(work.pid)
        expect(item["total"]).to eq(50)
        expect(item["readers"]).to eq(50)
        expect(item["events_url"]).to eq("http://www.citeulike.org/doi/#{work.doi}")
        expect(item["by_day"]).to be_empty
        expect(item["by_month"]).not_to be_nil
        expect(item["by_year"]).not_to be_nil
      end

      it "returns a valid JSON response with no events when provided with a bad id/pid" do
        work.pid = "somebadpidvalue"
        get uri, nil, headers
        expect(last_response.status).to eq(200)
        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(0)
      end
    end
  end
end
