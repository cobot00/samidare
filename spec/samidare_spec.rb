require 'spec_helper'

describe Samidare do
  it 'has a version number' do
    expect(Samidare::VERSION).not_to be nil
  end

  describe Samidare::EmbulkClient do
    describe '#target_table?' do
      subject { Samidare::EmbulkClient.new.send(:target_table?, table, target_tables) }
      context 'target_tables is empty' do
        let(:table) { 'hoge' }
        let(:target_tables) { [] }
        it { expect(subject).to be_truthy }
      end

      context 'is included' do
        let(:table) { 'hoge' }
        let(:target_tables) { ['hoge'] }
        it { expect(subject).to be_truthy }
      end

      context 'is not included' do
        let(:table) { 'hoge' }
        let(:target_tables) { ['fuga'] }
        it { expect(subject).to be_falsy }
      end
    end
  end
end
