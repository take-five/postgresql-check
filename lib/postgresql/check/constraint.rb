module Postgresql
  module Check
    class Constraint < Struct.new(:table_name, :name, :condition)
    end
  end
end