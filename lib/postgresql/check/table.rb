module Postgresql
  module Check
    module Table
      def check(condition, options)
        @base.add_check(@table_name, condition, options)
      end

      def remove_check(options)
        @base.remove_check(@table_name, options)
      end
    end
  end
end