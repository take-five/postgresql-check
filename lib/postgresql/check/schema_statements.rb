module Postgresql
  module Check
    module SchemaStatements
      extend ActiveSupport::Concern

      included do
        alias_method_chain :create_table, :checks
      end

      # Add a new Check constraint to table with given +table_name+
      # using given +conditions+. Constraint name should be specified
      # by +:name+ options in +options+ argument.
      #
      # @example
      #   add_check :products, 'price > 0', :name => 'products_price_chk'
      #
      #   # Generates:
      #   # ALTER TABLE products ADD CONSTRAINT products_price_chk CHECK (price > 0)
      #
      # @note +:name+ option is mandatory.
      #
      # @param [String|Symbol] table_name Table name which constraint created on
      # @param [String] condition Raw SQL string specifying constraint condition
      # @param [Hash] options Hash with single mandatory key +:name+
      # @option options [String|Symbol] :name Constraint name
      def add_check(table_name, condition, options)
        name = options.fetch(:name) { raise 'add_check, :name option required' }

        sql = "ALTER TABLE #{quote_table_name(table_name)} " +
            "ADD CONSTRAINT #{quote_column_name(name)} " +
            "CHECK (#{condition})"

        execute(sql)
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

        sql = "ALTER TABLE #{quote_table_name(table_name)} " +
            "DROP CONSTRAINT #{quote_column_name(name)}"

        execute(sql)
      end

      # @api private
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

      # @api private
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