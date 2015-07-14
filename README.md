# Samidare

Generate Embulk config and BigQuery schema from MySQL schema and run Embulk.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'samidare'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install samidare

## Usage
Require `database.yml` and `table.yml`.  
Below is a sample config file.

#### database.yml
```yml
db01:
  host: localhost
  username: root
  password:
  database: production
  bq_dataset: mysql_db01

db02:
  host: localhost
  username: root
  password:
  database: production
  bq_dataset: mysql_db02

```

#### table.yml
```yml
db01:
  tables:
    - name: users
    - name: events
    - name: hobbies

db02:
  tables:
    - name: administrators
    - name: configs
```

Samidare requires BigQuery parameters.
```ruby
config = {
 'project_id' => 'BIGQUERY_PROJECT_ID',
 'project_name' => 'BIGQUERY_PROJECT_NAME',
 'service_email' => 'SERVICE_ACCOUNT_EMAIL',
 'key' => '/etc/embulk/bigquery.p12',
 'schema_dir' => '/var/tmp/embulk/schema',
 'config_dir' => '/var/tmp/embulk/config',
 'auth_method' => 'private_key'
}

client = Samidare::EmbulkClient.new
client.generate_config(config)
client.run(config)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/samidare/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
