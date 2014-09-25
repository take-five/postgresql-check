module Postgresql
  module Check
    module SchemaDumper
      extend ActiveSupport::Concern

      included do
        alias_method_chain :table, :checks
      end

      def table_with_checks(table, stream)
        table_without_checks(table, stream)
        check_constraints(table, stream)
      end

      private
      def check_constraints(table, stream)
        if (checks = @connection.checks(table)).any?
          definitions = checks.map do |check|
            dump_check_constraint(check)
          end

          stream.puts
          stream.puts definitions.join("\n")
          stream.puts
        end
      end

      def dump_check_constraint(check)
        '  add_check ' + remove_prefix_and_suffix(check.table_name).inspect + ', '+
            check.condition.inspect + ', name: ' + check.name.inspect
      end
    end
  end
end