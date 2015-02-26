module Postgresql
  module Check
    module Table
      def check(condition, options)
        @base.add_check(check_table_name, condition, options)
      end

      def remove_check(options)
        @base.remove_check(check_table_name, options)
      end

      private
      # @api private
      def check_table_name
        if ActiveRecord::VERSION::STRING > "4.2"
          @name
        else
          @table_name
        end
      end
    end
  end
end
