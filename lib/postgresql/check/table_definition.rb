module Postgresql
  module Check
    module TableDefinition
      # Add new check constraint to table
      #
      # Example:
      #   create_table :goods do |t|
      #     t.float :price
      #     t.check 'price > 0', :name => 'goods_price_gt_0_check'
      #   end
      def check(condition, options)
        checks << [condition, options]
      end

      def checks
        @checks ||= []
      end
    end
  end
end