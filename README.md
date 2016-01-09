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

### database.yml
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

### table.yml
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
require 'samidare'

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
ruby sample.rb
```

## Features
### process status
`Samidare` returns process status as boolean.  
If all tables are succeed, then returns `true`, else `false` .  
It is useful to control system flow.

```ruby
process_status = Samidare::EmbulkClient.new.run(config)
exit 1 unless process_status
```

### narrow tables
You can narrow actual target tables from `table.yml` for test or to retry.  
If no target tables is given, `Samidare` will execute all tables.

```ruby
# in case, all tables are ['users', 'purchases', 'items']
target_tables = ['users', 'purchases']
Samidare::EmbulkClient.new.run(config, target_tables)
```

### retry
You can set retry count.  
If any table failed, only failed table will be retried until retry count.  
If no retry count is given, `Samidare` dosen't retry.

```ruby
# 2 times retry will execute
Samidare::EmbulkClient.new.run(config, [], 2)
```

### SQL condition
If you set `condition` to a table in `table.yml` , SQL is generated like below.  
It is useful for large size table.

```yml
[table.yml]
production:
  tables:
    - name: users
    - name: events
      conditon: created_at < CURRENT_DATE()
```

```sql
SELECT * FROM users
SELECT * FROM events WHERE created_at < CURRENT_DATE()
```

### daily snapshot
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
