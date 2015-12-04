require 'spec_helper'

describe Samidare::MySQL::TableConfig do

  describe '.generate_table_configs' do
    subject { Samidare::MySQL::TableConfig.generate_table_configs('spec/support/table.yml') }
    let(:db01_hoge) { Samidare::MySQL::TableConfig.new({ 'name' => 'hoge', 'daily_snapshot' => true }) }
    let(:db01_simple) { Samidare::MySQL::TableConfig.new({ 'name' => 'simple' }) }
    let(:db02_fuga) { Samidare::MySQL::TableConfig.new({ 'name' => 'fuga' }) }
    let(:db02_with_condition) { Samidare::MySQL::TableConfig.new({ 'name' => 'with_condition', 'condition' => 'created_at < CURRENT_DATE()' }) }

    it { expect(subject['db01'][0]).to eq db01_hoge }
    it { expect(subject['db01'][1]).to eq db01_simple }
    it { expect(subject['db02'][0]).to eq db02_fuga }
    it { expect(subject['db02'][1]).to eq db02_with_condition }
  end
end

describe Samidare::MySQL::Column do
  let(:column) { Samidare::MySQL::Column.new(column_name, data_type) }
  let(:column_name) { 'id' }
  let(:data_type) { 'int' }

  it { expect(column.column_name).to eq 'id' }
  it { expect(column.data_type).to eq 'int' }

  describe '#bigquery_data_type' do
    subject { column.bigquery_data_type }

    context 'int' do
      let(:data_type) { 'int' }
      it { expect(subject).to eq 'integer' }
    end

    context 'tinyint' do
      let(:data_type) { 'tinyint' }
      it { expect(subject).to eq 'integer' }
    end

    context 'smallint' do
      let(:data_type) { 'smallint' }
      it { expect(subject).to eq 'integer' }
    end

    context 'mediumint' do
      let(:data_type) { 'mediumint' }
      it { expect(subject).to eq 'integer' }
    end

    context 'bigint' do
      let(:data_type) { 'bigint' }
      it { expect(subject).to eq 'integer' }
    end

    context 'float' do
      let(:data_type) { 'float' }
      it { expect(subject).to eq 'float' }
    end

    context 'double' do
      let(:data_type) { 'double' }
      it { expect(subject).to eq 'float' }
    end

    context 'decimal' do
      let(:data_type) { 'decimal' }
      it { expect(subject).to eq 'float' }
    end

    context 'char' do
      let(:data_type) { 'char' }
      it { expect(subject).to eq 'string' }
    end

    context 'varchar' do
      let(:data_type) { 'varchar' }
      it { expect(subject).to eq 'string' }
    end

    context 'tinytext' do
      let(:data_type) { 'tinytext' }
      it { expect(subject).to eq 'string' }
    end

    context 'text' do
      let(:data_type) { 'text' }
      it { expect(subject).to eq 'string' }
    end

    context 'date' do
      let(:data_type) { 'date' }
      it { expect(subject).to eq 'timestamp' }
    end

    context 'datetime' do
      let(:data_type) { 'datetime' }
      it { expect(subject).to eq 'timestamp' }
    end

    context 'timestamp' do
      let(:data_type) { 'timestamp' }
      it { expect(subject).to eq 'timestamp' }
    end
  end

  describe '#converted_value' do
    subject { column.converted_value }

    context 'datetime' do
      let(:column_name) { 'create_at' }
      let(:data_type) { 'datetime' }
      it { expect(subject).to eq 'UNIX_TIMESTAMP(`create_at`) AS `create_at`' }
    end

    context 'int' do
      let(:column_name) { 'id' }
      let(:data_type) { 'int' }
      it { expect(subject).to eq '`id`' }
    end

    context 'varchar' do
      let(:column_name) { 'explanation' }
      let(:data_type) { 'varchar' }
      it { expect(subject).to eq '`explanation`' }
    end
  end

  describe '#to_json' do
    subject { column.to_json }

    let(:column_name) { 'id' }
    let(:data_type) { 'int' }
    it { expect(subject).to eq '{"name":"id","type":"integer"}' }
  end
end
