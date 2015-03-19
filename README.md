# Postgresql::Check

[![Code Climate](https://codeclimate.com/github/take-five/postgresql-check/badges/gpa.svg)](https://codeclimate.com/github/take-five/postgresql-check)

This gem introduces a few methods to your migrations for adding and removing
[Check Constraints](http://www.postgresql.org/docs/9.3/static/ddl-constraints.html).
It also dumps these constraints to `schema.rb`.

## Requirements

* PostgreSQL
* active_record >= 3.2.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'postgresql-check'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install postgresql-check

## Usage

Two new methods are introduced to migrations:

* `add_check(table_name, condition, name: constraint_name)`
* `remove_check(table_name, name: constraint_name)`

Given the following model:

```ruby
class Product < ActiveRecord::Base
  validates :price, numericality: { greater_than: 0 }
end
```

You can add a check constraint in your migration:

```ruby
add_check :products, 'price > 0', name: 'products_price_check'
```

The code above generates following SQL:

```sql
ALTER TABLE "products" ADD CONSTRAINT "products_price_check" (price > 0)
```

**NOTE**: `:name` option is mandatory now.

To remove constraint use `remove_check` method:

```ruby
remove_check :products, name: 'products_price_check'
```

## Change Table methods

This gem adds extra methods to `create_table` and `change_table`:

```ruby
create_table :products do |t|
  t.decimal :price, null: false
  t.check 'price > 0', name: 'products_price_check'
end
```

Remove a check constraint:

```ruby
change_table :products do |t|
  t.remove_check name: 'products_price_check'
end
```

## Future plans

* Write tests
* Auto-generate constraint name
* Make `remove_check` reversible

## Contributing

1. Fork it ( https://github.com/take-five/postgresql-check/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
