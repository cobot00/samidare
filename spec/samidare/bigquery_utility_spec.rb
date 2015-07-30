require 'spec_helper'
require 'unindent'
require 'timecop'

describe Samidare::BigQueryUtility do
  describe '.generate_schema' do
    subject { Samidare::BigQueryUtility.generate_schema(column_infos) }

    let(:column_infos) { [
      Samidare::EmbulkUtility::ColumnInfo.new('id', 'int'),
      Samidare::EmbulkUtility::ColumnInfo.new('name', 'varchar'),
      Samidare::EmbulkUtility::ColumnInfo.new('created_at', 'datetime')
      ] }
    let(:schema_json) {
      <<-JSON.unindent
      [
      {"name":"id","type":"integer"},
      {"name":"name","type":"string"},
      {"name":"created_at","type":"timestamp"}
      ]
      JSON
    }
    it { expect(subject).to eq schema_json }
  end

  describe '.generate_sql' do
    subject { Samidare::BigQueryUtility.generate_sql(table_name, column_infos) }

    let(:table_name) { 'simple' }
    let(:column_infos) { [
      Samidare::EmbulkUtility::ColumnInfo.new('id', 'int'),
      Samidare::EmbulkUtility::ColumnInfo.new('name', 'varchar'),
      Samidare::EmbulkUtility::ColumnInfo.new('created_at', 'datetime')
      ] }
    let(:sql) { "SELECT id,name,UNIX_TIMESTAMP(created_at) AS created_at FROM simple\n" }
    it { expect(subject).to eq sql }
  end

  describe '#actual_table_name' do
    before { Timecop.freeze(Time.now) }

    after { Timecop.return }

    subject { Samidare::BigQueryUtility.new({}).actual_table_name(table_name, daily_snapshot) }
    let(:table_name) { 'users' }
    let(:daily_snapshot) { false }

    context 'do not use daily snapshot' do
      it { expect(subject).to eq table_name }
    end

    context 'use daily snapshot' do
      let(:daily_snapshot) { true }
      it { expect(subject).to eq table_name + Time.now.strftime('%Y%m%d') }
    end
  end
end
