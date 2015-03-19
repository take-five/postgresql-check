module Postgresql
  module Check
    module SchemaDefinitions
      def self.included(base)
        if ActiveRecord::VERSION::STRING > '4.2'
          ActiveRecord::ConnectionAdapters::PostgreSQL::Table.class_eval do
            include Postgresql::Check::Table
          end

          ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.class_eval do
            include Postgresql::Check::TableDefinition
          end
        else
          base::Table.class_eval do
            include Postgresql::Check::Table
          end

          base::TableDefinition.class_eval do
            include Postgresql::Check::TableDefinition
          end
        end
      end
    end
  end
end