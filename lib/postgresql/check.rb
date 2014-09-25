require 'postgresql/check/version'
require 'active_support/dependencies/autoload'
require 'active_support/lazy_load_hooks'

module Postgresql
  module Check
    extend ActiveSupport::Autoload

    autoload :Constraint
    autoload :CommandRecorder
    autoload :SchemaStatements
    autoload :SchemaDefinitions
    autoload :SchemaDumper
    autoload :Table
    autoload :TableDefinition

    def self.setup
      ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.module_eval do
        include Postgresql::Check::SchemaStatements
        include Postgresql::Check::SchemaDefinitions
      end

      ActiveRecord::SchemaDumper.class_eval do
        include Postgresql::Check::SchemaDumper
      end

      ActiveRecord::Migration::CommandRecorder.class_eval do
        include Postgresql::Check::CommandRecorder
      end
    end

    if defined?(Rails)
      class Railtie < Rails::Railtie
        initializer 'postgresql_check.setup' do
          ActiveSupport.on_load :active_record do
            Postgresql::Check.setup
          end
        end
      end
    end
  end
end