module Postgresql
  module Check
    module CommandRecorder
      def add_check(*args)
        record(:add_check, args)
      end

      def remove_check(*args)
        record(:remove_check, args)
      end

      def invert_add_check(args)
        table_name, condition, options = args

        [:remove_check, [table_name, options]]
      end
    end
  end
end