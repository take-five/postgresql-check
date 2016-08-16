module Postgresql
  module Check
    module SchemaDumper
      extend ActiveSupport::Concern

      included do
        alias_method :table_without_checks, :table
        alias_method :table, :table_with_checks
      end

      def table_with_checks(table, stream)
        table_without_checks table, stream
        check_constraints table, stream
      end

      private
      def check_constraints(table, stream)
        if (checks = @connection.checks(table)).any?
          definitions = checks.map do |check|
            dump_check_constraint check
          end

          stream.puts definitions.join("\n")
          stream.puts "\n"
        end
      end

      def dump_check_constraint(check)
        <<-RUBY.chomp
  add_check "#{remove_prefix_and_suffix(check.table_name)}", "#{check.condition}", name: "#{check.name}"
        RUBY
      end
    end
  end
end
