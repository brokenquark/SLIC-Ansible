require 'spec_helper'

describe Minimart::Mirror::Source do

  let(:base_url) { 'https://fakesupermarket.com/chef' }

  subject { Minimart::Mirror::Source.new(base_url) }

  let(:raw_universe) { File.open('spec/fixtures/universe.json').read }

  before(:each) do
    stub_request(:get, "#{base_url}/universe").
      to_return(status: 200, body: raw_universe)
  end

  describe '#find_cookbook' do
    describe 'when a cookbook is present in the universe' do
      it 'should return a matching cookbook' do
        result = subject.find_cookbook('mysql', '5.6.1')
        expect(result.name).to eq 'mysql'
        expect(result.version).to eq '5.6.1'
        expect(result.location_path).to eq 'https://supermarket.getchef.com/api/v1'
        expect(result.download_url).to eq 'https://supermarket.getchef.com/api/v1/cookbooks/mysql/versions/5.6.1/download'
        expect(result.dependencies).to eq("yum-mysql-community" => ">= 0.0.0")
      end
    end

    describe 'when a cookbook is not present in the universe' do
      it 'should return nil' do
        expect(subject.find_cookbook('madeup', '0.0.1')).to be_nil
      end
    end

    context 'when the given universe does not exist' do
      before(:each) do
        stub_request(:get, "#{base_url}/universe").to_return(status: 404)
      end

      it 'should raise the proper exception' do
        expect {
          subject.find_cookbook('mysql', '5.6.1')
        }.to raise_error(
          Minimart::Error::UniverseNotFoundError,
          "no universe found for #{base_url}")
      end
    end
  end

  describe '#to_s' do
    it 'should return the base url' do
      expect(subject.to_s).to eq base_url
    end
  end
end
