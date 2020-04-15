module Postgresql
  module Check
    module SchemaStatements
      extend ActiveSupport::Concern

      included do
        alias_method :create_table_without_checks, :create_table
        alias_method :create_table, :create_table_with_checks
      end

      # Add a new Check constraint to table with given +table_name+
      # using given +conditions+. Constraint name should be specified
      # by +:name+ options in +options+ argument.
      #
      # @example
      #   add_check :products, 'price > 0', name: 'products_price_check'
      #
      #   # Generates:
      #   # ALTER TABLE products ADD CONSTRAINT products_price_check CHECK (price > 0)
      #
      # @note +:name+ option is mandatory.
      #
      # @param [String|Symbol] table_name Table name which constraint created on
      # @param [String] condition Raw SQL string specifying constraint condition
      # @param [Hash] options Hash with single mandatory key +:name+
      # @option options [String|Symbol] :name Constraint name
      def add_check(table_name, condition, options)
        name = options.fetch(:name) { raise 'add_check, :name option required' }

        execute <<-SQL
          ALTER TABLE #{quote_table_name(table_name)}
          ADD CONSTRAINT #{quote_column_name(name)}
          CHECK (#{condition})
        SQL
      end

      # Remove constraint with given name from table. Constraint name
      # is specified with +options+ hash.
      #
      # @example
      #   remove_check :products, :name => 'products_price_chk'
      #
      #   # Generates:
      #   # ALTER TABLE products DROP CONSTRAINT products_price_chk
      #
      # @param [String|Symbol] table_name Table name which constraint defined on
      # @param [Hash] options Hash with single mandatory key +:name+
      # @option options [String|Symbol] :name Constraint name
      def remove_check(table_name, options)
        name = options.fetch(:name) { raise 'remove_check, :name option required' }

        execute <<-SQL
          ALTER TABLE #{quote_table_name(table_name)}
          DROP CONSTRAINT #{quote_column_name(name)}
        SQL
      end

      # @api private
      def create_table_with_checks(table_name, *args)
        definition = nil

        create_table_without_checks(table_name, *args) do |td|
          definition = td # trick to get the definition
          yield td if block_given?
        end

        definition.checks.each do |condition, options|
          add_check table_name, condition, options
        end
      end

      # @api private
      def checks(table_name)
        checks_info = select_all <<-SQL
          SELECT DISTINCT c.conname, pg_get_expr(c.conbin, c.conrelid) check_expr
          FROM pg_constraint c
          INNER JOIN pg_class t
            ON c.conrelid = t.oid
          WHERE c.contype = 'c'
            AND t.relname = '#{table_name}'
        SQL

        checks_info.map do |row|
          Constraint.new table_name, row['conname'], row['check_expr']
        end
      end
    end
  end
end
