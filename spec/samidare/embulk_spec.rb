require 'spec_helper'

describe Samidare::Embulk do
  describe '#target_tables' do
    subject { Samidare::Embulk.new.target_tables(tables, target_table_names) }

    context 'all tables' do
      let(:table_hoge) { Samidare::EmbulkUtility::TableInfo.new({ 'name' => 'hoge' }) }
      let(:table_fuga) { Samidare::EmbulkUtility::TableInfo.new({ 'name' => 'fuga' }) }
      let(:tables) { [table_hoge, table_fuga] }
      let(:target_table_names) { [] }
      it { expect(subject).to match(tables) }
    end

    context 'target table selected' do
      let(:table_hoge) { Samidare::EmbulkUtility::TableInfo.new({ 'name' => 'hoge' }) }
      let(:table_fuga) { Samidare::EmbulkUtility::TableInfo.new({ 'name' => 'fuga' }) }
      let(:tables) { [table_hoge, table_fuga] }
      let(:target_table_names) { ['hoge'] }
      it { expect(subject).to match([table_hoge]) }
    end
  end
end
