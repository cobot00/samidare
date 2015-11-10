require 'spec_helper'

describe Samidare::EmbulkUtility::ColumnInfo do
  let(:column_info) { Samidare::EmbulkUtility::ColumnInfo.new(column_name, data_type) }
  let(:column_name) { 'id' }
  let(:data_type) { 'int' }

  it { expect(column_info.column_name).to eq 'id' }
  it { expect(column_info.data_type).to eq 'int' }

  describe '#bigquery_data_type' do
    subject { column_info.bigquery_data_type }

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
    subject { column_info.converted_value }

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
    subject { column_info.to_json }

    let(:column_name) { 'id' }
    let(:data_type) { 'int' }
    it { expect(subject).to eq '{"name":"id","type":"integer"}' }
  end
end
