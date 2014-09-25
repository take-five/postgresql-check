module Postgresql
  module Check
    module SchemaDefinitions
      def self.included(base)
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