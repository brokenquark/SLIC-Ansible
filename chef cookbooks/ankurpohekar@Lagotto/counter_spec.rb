require 'rails_helper'

describe Counter, type: :model, vcr: true do

  subject { FactoryGirl.create(:counter) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Counter API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'counter_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(response['rest']['response']['results']['item']).to be_nil
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Counter API" do
      response = subject.get_data(work)
      expect(response["rest"]["response"]["criteria"]).to eq("year"=>"all", "month"=>"all", "journal"=>"all", "doi"=>work.doi)
      expect(response["rest"]["response"]["results"]["total"]["total"]).to eq("5900")
      expect(response["rest"]["response"]["results"]["item"].length).to eq(67)
    end

    it "should catch timeout errors with the Counter API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.plosreports.org/services/rest?method=usage.stats&doi=#{work.doi_escaped}", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report if there are no events returned by the Counter API" do
      body = File.read(fixture_path + 'counter_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report if there are events returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(3387)
      expect(response[:events][:pdf]).to eq(447)
      expect(response[:events][:html]).to eq(2919)
      expect(response[:events][:extra].length).to eq(37)
      expect(response[:events][:months].length).to eq(37)
      expect(response[:events][:months].first).to eq(month: 1, year: 2010, html: 299, pdf: 90, total: 390)
      expect(response[:events][:events_url]).to be_nil
    end

    it "should catch timeout errors with the Counter API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
