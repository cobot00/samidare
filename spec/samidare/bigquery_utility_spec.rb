require 'spec_helper'
require 'unindent'

describe Samidare::BigQueryUtility do
  describe '.generate_schema' do
    subject { Samidare::BigQueryUtility.generate_schema(column_infos) }

    context '' do
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
  end

  describe '.generate_sql' do
    subject { Samidare::BigQueryUtility.generate_sql(table_name, column_infos) }

    context '' do
      let(:table_name) { 'simple' }
      let(:column_infos) { [
        Samidare::EmbulkUtility::ColumnInfo.new('id', 'int'),
        Samidare::EmbulkUtility::ColumnInfo.new('name', 'varchar'),
        Samidare::EmbulkUtility::ColumnInfo.new('created_at', 'datetime')
        ] }
      let(:sql) { "SELECT id,name,UNIX_TIMESTAMP(created_at) AS created_at FROM simple\n" }
      it { expect(subject).to eq sql }
    end
  end
end
