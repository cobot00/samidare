require 'spec_helper'

describe Samidare::Embulk do
  describe '#target_table_configs' do
    subject { Samidare::Embulk.new.target_table_configs(table_configs, target_table_names) }

    context 'all tables' do
      let(:table_hoge) { Samidare::MySQL::TableConfig.new({ 'name' => 'hoge' }) }
      let(:table_fuga) { Samidare::MySQL::TableConfig.new({ 'name' => 'fuga' }) }
      let(:table_configs) { [table_hoge, table_fuga] }
      let(:target_table_names) { [] }
      it { expect(subject).to match(table_configs) }
    end

    context 'target table selected' do
      let(:table_hoge) { Samidare::MySQL::TableConfig.new({ 'name' => 'hoge' }) }
      let(:table_fuga) { Samidare::MySQL::TableConfig.new({ 'name' => 'fuga' }) }
      let(:table_configs) { [table_hoge, table_fuga] }
      let(:target_table_names) { ['hoge'] }
      it { expect(subject).to match([table_hoge]) }
    end
  end
end
