module Postgresql
  module Check
    module Table
      def check(column, condition = nil)
        @base.add_check(@table_name, column, condition)
      end

      def remove_check(column_name)
        @base.remove_check(@table_name, column_name)
      end
    end
  end
end