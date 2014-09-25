module Postgresql
  module Check
    module SchemaStatements
      extend ActiveSupport::Concern

      included do
        alias_method_chain :create_table, :checks
      end

      def create_table_with_checks(table_name, *args, &block)
        definition = nil

        create_table_without_checks(table_name, *args) do |td|
          definition = td # trick to get the definition
          block.call(td) unless block.nil?
        end

        definition.checks.each do |condition, options|
          add_check(table_name, condition, options)
        end
      end

      def add_check(table_name, condition, options)
        name = options.fetch(:name) { raise 'add_check, :name option required' }

        sql = "ALTER TABLE #{quote_table_name(table_name)} " +
            "ADD CONSTRAINT #{quote_column_name("#{table_name}_#{name}")} " +
            "CHECK (#{condition})"

        execute(sql)
      end

      def remove_check(table_name, options)
        name = options.fetch(:name) { raise 'remove_check, :name option required' }

        sql = "ALTER TABLE #{quote_table_name(table_name)} " +
            "DROP CONSTRAINT #{quote_column_name("#{table_name}_#{name}")}"

        execute(sql)
      end

      def checks(table_name)
        checks_info = select_all %{
          SELECT c.conname, c.consrc
          FROM pg_constraint c
          JOIN pg_class t ON c.conrelid = t.oid
          WHERE c.contype = 'c'
            AND t.relname = '#{table_name}'
        }

        checks_info.map do |row|
          Constraint.new(table_name, row['conname'], row['consrc'])
        end
      end
    end
  end
end