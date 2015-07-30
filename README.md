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
  password: pswd
  database: production
  bq_dataset: mysql_db01

db02:
  host: localhost
  username: root
  password: pswd
  database: production
  bq_dataset: mysql_db02

```

**Caution: Embulk doesn't allow no password for MySQL**

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

Samidare requires BigQuery parameters like below.
```ruby
[sample.rb]
config = {
 'project_id' => 'BIGQUERY_PROJECT_ID',
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

```bash
bundle exec ruby sample.rb
```

## Features
#### daily snapshot
BigQuery supports table wildcard expression of a specific set of daily tables, for example, `sales20150701` .  
If you need daily snapshot of a table for BigQuery, use `daily_snapshot` option to `database.yml` or `table.yml` like below.  
`daily_snapshot` option effects all tables in case of  `database.yml` .  
On the other hand, only target table in `table.yml` .  
**Daily part is determined by execute date.**

```yml
[database.yml]
production:
  host: localhost
  username: root
  password: pswd
  database: production
  bq_dataset: mysql
  daily_snapshot: true
```

```yml
[table.yml]
production:
  tables:
    - name: users
    - name: events
      daily_snapshot: true
    - name: hobbies

Only `events` is renamed to `eventsYYYYMMDD` for BigQuery.
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/samidare/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
