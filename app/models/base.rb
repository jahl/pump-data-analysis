class Base
  INSTANCE_ID = ENV['BIGTABLE_INSTANCE']

  attr_reader :bigtable, :table_id, :table

  def initialize
    @bigtable = Google::Cloud::Bigtable.new
    @table_id = self.class.name.underscore

    initialize_table
  end

  class << self
    def table
      inst = new
      inst.table
    end
  end

  private

  def initialize_table
    if bigtable.table(INSTANCE_ID, table_id).exists?
      @table = bigtable.table(INSTANCE_ID, table_id)
    else
      @table = bigtable.create_table(INSTANCE_ID, table_id) do |column_families|
        self.class::COLUMN_FAMILIES.each do |family|
          column_families.add(
            family,
            Google::Cloud::Bigtable::GcRule.max_versions(1)
          )
        end
      end
    end
  end
end
