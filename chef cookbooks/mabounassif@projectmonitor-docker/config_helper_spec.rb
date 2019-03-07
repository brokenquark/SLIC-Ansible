require 'spec_helper'

describe ConfigHelper do

  describe '.get' do
    let(:key) { 'wibble' }
    let(:actual_value) { ['192.168.1.1'] }
    let(:yaml_value) { "---\n- 192.168.1.1\n" }

    context 'when the requested setting is in the environment' do
      before do
        allow(ENV).to receive(:key?).with(key).and_return(true)
      end

      context 'and the setting is nil' do
        before do
          allow(ENV).to receive(:[]).with(key).and_return(nil)
        end

        context 'and has been passed a block' do
          it "invokes the block with nil" do
            value = actual_value
            ConfigHelper.get(key) {|v| value = v }
            expect(value).to eq(nil)
          end
        end

        context 'and has not been passed a block' do
          it 'returns nil' do
            expect(ConfigHelper.get(key)).to be_nil
          end
        end
      end

      context 'and the setting is present' do
        before do
          allow(ENV).to receive(:[]).with(key).and_return(yaml_value)
        end

        context 'and has been passed a block' do
          it "invokes the block with the expected value" do
            value = nil
            ConfigHelper.get(key) {|v| value = v }
            expect(value).to eq(actual_value)
          end
        end

        context 'and has not been passed a block' do
          it 'returns the expected value' do
            expect(ConfigHelper.get(key)).to eq(actual_value)
          end
        end
      end
    end

    context 'when the requested setting is in the configuration file' do
      before do
        allow(ENV).to receive(:key?).with(key).and_return(false)
        allow(Rails.configuration).to receive(key).and_return(actual_value)
      end

      context 'and has been passed a block' do
        it "invokes the block with the expected value" do
          value = nil
          ConfigHelper.get(key) {|v| value = v}
          expect(value).to eq(actual_value)
        end
      end

      context 'and has not been passed a block' do
        it 'returns the expected value' do
          expect(ConfigHelper.get(key)).to eq(actual_value)
        end
      end

    end

    context 'when the requested setting has not been specified' do
      before do
        allow(ENV).to receive(:key?).with(key).and_return(false)
      end

      context 'and has been passed a block' do
        it 'does not invoke the block' do
          ConfigHelper.get(key) {|v| raise 'Block got called when no value was supplied'}
        end
      end

      context 'and has not been passed a block' do
        it 'returns nil' do
          expect(ConfigHelper.get(key)).to be_nil
        end
      end
    end

  end
end
