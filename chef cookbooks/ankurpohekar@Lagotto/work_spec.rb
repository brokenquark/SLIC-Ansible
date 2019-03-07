require 'rails_helper'

describe Work, type: :model, vcr: true do

  let(:work) { FactoryGirl.create(:work) }

  subject { work }

  it { is_expected.to have_many(:retrieval_statuses) }
  it { is_expected.to validate_uniqueness_of(:doi) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:year).only_integer }

  context "validate doi format" do
    it "10.5555/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.5555/12345678")
      expect(work).to be_valid
    end

    it "10.13039/100000001" do
      work = FactoryGirl.build(:work, :doi => "10.13039/100000001")
      expect(work).to be_valid
    end

    it "10.1386//crre.4.1.53_1" do
      work = FactoryGirl.build(:work, :doi => " 10.1386//crre.4.1.53_1")
      expect(work).not_to be_valid
    end

    it "10.555/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.555/12345678")
      expect(work).not_to be_valid
    end

    it "8.5555/12345678" do
      work = FactoryGirl.build(:work, :doi => "8.5555/12345678")
      expect(work).not_to be_valid
    end

    it "10.asdf/12345678" do
      work = FactoryGirl.build(:work, :doi => "10.asdf/12345678")
      expect(work).not_to be_valid
    end

    it "10.5555" do
      work = FactoryGirl.build(:work, :doi => "10.5555")
      expect(work).not_to be_valid
    end

    it "asdfasdfasdf" do
      work = FactoryGirl.build(:work, :doi => "asdfasdfasdf")
      expect(work).not_to be_valid
    end
  end

  context "validate url format" do
    it "http://example.com/1234" do
      work = FactoryGirl.build(:work, :canonical_url => "http://example.com/1234")
      expect(work).to be_valid
    end

    it "https://example.com/1234" do
      work = FactoryGirl.build(:work, :canonical_url => "http://example.com/1234")
      expect(work).to be_valid
    end

    it "ftp://example.com/1234" do
      work = FactoryGirl.build(:work, :canonical_url => "ftp://example.com/1234")
      expect(work).not_to be_valid
    end

    it "http://" do
      work = FactoryGirl.build(:work, :canonical_url => "http://")
      expect(work).not_to be_valid
      #expect{work}.to raise_error(Addressable::URI::InvalidURIError)
    end

    it "asdfasdfasdf" do
      work = FactoryGirl.build(:work, :canonical_url => "asdfasdfasdf")
      expect(work).not_to be_valid
    end
  end

  context "validate ark format" do
    it "ark:/13030/m5br8stc" do
      work = FactoryGirl.build(:work, :ark => "ark:/13030/m5br8stc")
      expect(work).to be_valid
    end

    it "13030/m5br8stc" do
      work = FactoryGirl.build(:work, :ark => " 13030/m5br8stc")
      expect(work).not_to be_valid
    end

    it "ark:/13030" do
      work = FactoryGirl.build(:work, :ark => "ark:/13030")
      expect(work).not_to be_valid
    end

    it "ark:/1303x/m5br8stc" do
      work = FactoryGirl.build(:work, :ark => "ark:/1303x/m5br8stc")
      expect(work).not_to be_valid
    end
  end

  context "validate date " do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    it 'validate date' do
      work = FactoryGirl.build(:work)
      expect(work).to be_valid
    end

    it 'validate date with missing day' do
      work = FactoryGirl.build(:work, day: nil)
      expect(work).to be_valid
    end

    it 'validate date with missing month and day' do
      work = FactoryGirl.build(:work, month: nil, day: nil)
      expect(work).to be_valid
    end

    it 'don\'t validate date with missing year, month and day' do
      work = FactoryGirl.build(:work, year: nil, month: nil, day: nil)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(year: ["is not a number"], published_on: ["is before 1650"])
    end

    it 'don\'t validate wrong date' do
      work = FactoryGirl.build(:work, month: 2, day: 30)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(published_on: ["2012-2-30 is not a valid date"])
    end

    it 'don\'t validate wrong month' do
      work = FactoryGirl.build(:work, month: 13, day: 30)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(month: ["must be less than or equal to 12"], published_on: ["2012-13-30 is not a valid date"])
    end

    it 'don\'t validate wrong day' do
      work = FactoryGirl.build(:work, month: 11, day: 32)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(day: ["must be less than or equal to 31"], published_on: ["2012-11-32 is not a valid date"])
    end

    it 'don\'t validate date in the future' do
      date = Time.zone.now.to_date + 1.day
      work = FactoryGirl.build(:work, year: date.year, month: date.month, day: date.day)
      expect(work).not_to be_valid
      expect(work.errors.messages).to eq(published_on: ["is a date in the future"])
    end

    it 'published_on' do
      work = FactoryGirl.create(:work)
      date = Date.new(work.year, work.month, work.day)
      expect(work.published_on).to eq(date)
    end

    it 'issued' do
      work = FactoryGirl.create(:work)
      date = { "date-parts" => [[work.year, work.month, work.day]] }
      expect(work.issued).to eq(date)
    end

    it 'issued_date year month day' do
      work = FactoryGirl.create(:work, year: 2013, month: 2, day: 9)
      expect(work.issued_date).to eq("February 9, 2013")
    end

    it 'issued_date year month' do
      work = FactoryGirl.create(:work, year: 2013, month: 2, day: nil)
      expect(work.issued_date).to eq("February 2013")
    end

    it 'issued_date year' do
      work = FactoryGirl.create(:work, year: 2013, month: nil, day: nil)
      expect(work.issued_date).to eq("2013")
    end
  end

  context "sanitize title" do
    it "strips tags and attributes" do
      title = '<span id="date">2013-12-05</span'
      work = FactoryGirl.create(:work, title: title)
      expect(work.title).to eq("2013-12-05")
    end

    it "keeps allowed tags" do
      title = "Characterization of the Na<sup>+</sup>/H<sup>+</sup> Antiporter from <i>Yersinia pestis</i>"
      work = FactoryGirl.create(:work, title: title)
      expect(work.title).to eq(title)
    end
  end

  context "normalize doi" do
    it "downcase doi" do
      doi = "10.6085/AA/KNB-LTER-SBC.17.9"
      work = FactoryGirl.create(:work, doi: doi)
      expect(work.doi).to eq("10.6085/aa/knb-lter-sbc.17.9")
    end
  end

  it 'to doi escaped' do
    expect(CGI.escape(work.doi)).to eq(work.doi_escaped)
  end

  it 'doi as url' do
    expect(Addressable::URI.encode("http://doi.org/#{work.doi}")).to eq(work.doi_as_url)
  end

  context "pid" do
    it 'for doi' do
      expect(work.to_param).to eq "http://doi.org/#{work.doi}"
    end

    it 'for pmid' do
      work = FactoryGirl.create(:work, doi: nil)
      expect(work.to_param).to eq "http://www.ncbi.nlm.nih.gov/pubmed/#{work.pmid}"
    end

    it 'for pmcid' do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil)
      expect(work.to_param).to eq "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC#{work.pmcid}"
    end

    it 'for canonical_url' do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil, canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0043007")
      expect(work.to_param).to eq work.canonical_url
    end

    it 'for arxiv' do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil, canonical_url: nil, arxiv: "1503.04201")
      expect(work.to_param).to eq "http://arxiv.org/abs/#{work.arxiv}"
    end

    it 'for ark' do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil, pmcid: nil, canonical_url: nil)
      expect(work.to_param).to eq "http://n2t.net/#{work.ark}"
    end
  end

  it 'dataone escaped' do
    work = FactoryGirl.create(:work, dataone: "doi:10.5063/F1PC3085")
    expect(work.dataone_escaped).to eq("doi\\:10.5063/F1PC3085")
  end

  it 'to title escaped' do
    expect(CGI.escape(work.title.to_str).gsub("+", "%20")).to eq(work.title_escaped)
  end

  it 'event_counts' do
    work = FactoryGirl.create(:work_with_events)
    expect(work.event_counts(["citeulike", "mendeley"])).to eq(100)
  end

  it 'metrics' do
    work = FactoryGirl.create(:work_with_events)
    expect(work.metrics).to eq([["citeulike", 50], ["mendeley", 50]])
  end

  it 'viewed' do
    work = FactoryGirl.create(:work_with_counter_citations)
    expect(work.viewed).to eq(500)
  end

  it 'discussed' do
    work = FactoryGirl.create(:work_with_tweets)
    expect(work.discussed).to eq(50)
  end

  it 'saved' do
    work = FactoryGirl.create(:work_with_events)
    expect(work.saved).to eq(100)
  end

  it 'cited' do
    work = FactoryGirl.create(:work_with_crossref_citations)
    expect(work.cited).to eq(25)
  end

  it "events count" do
    Work.all.each do |work|
      total = work.retrieval_statuses.reduce(0) { |sum, rs| sum + rs.event_count }
      expect(total).to eq(work.events_count)
    end
  end

  it "has events" do
    expect(Work.has_events.all? { |work| work.events_count > 0 }).to be true
  end

  context "url" do
    it "should use doi as url" do
      expect(work.url).to eq(work.doi_as_url)
    end

    it "should use pmid as url if doi is not present" do
      work = FactoryGirl.create(:work, doi: nil)
      expect(work.url).to eq(work.pmid_as_url)
    end

    it "should use canonical_url if doi and pmid are not present" do
      work = FactoryGirl.create(:work, doi: nil, pmid: nil)
      expect(work.url).to eq(work.canonical_url)
    end
  end

  context "get_url" do
    it 'should get_url' do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", canonical_url: nil)
      url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
      expect(work.get_url).not_to be_nil
      expect(work.canonical_url).to eq(url)
    end

    it "with canonical_url" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", canonical_url: "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030")
      expect(work.get_url).to be true
    end

    it "without doi" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(work.get_url).to be false
      expect(work.canonical_url).to be_nil
    end
  end

  it 'should get_ids' do
    work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", pmid: nil)
    expect(work.get_ids).to be true
    expect(work.pmid).to eq("17183658")
  end

  it "should get all_urls" do
    work = FactoryGirl.build(:work, :canonical_url => "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000001")
    expect(work.all_urls).to eq([work.canonical_url, work.pmid_as_europepmc_url].compact + work.events_urls)
  end

  context "associations" do
    it "should create associated retrieval_statuses" do
      expect(RetrievalStatus.count).to eq(0)
      @works = FactoryGirl.create_list(:work_with_events, 2)
      expect(RetrievalStatus.count).to eq(4)
    end

    it "should delete associated retrieval_statuses" do
      @works = FactoryGirl.create_list(:work_with_events, 2)
      expect(RetrievalStatus.count).to eq(4)
      @works.each(&:destroy)
      expect(RetrievalStatus.count).to eq(0)
    end
  end
end
