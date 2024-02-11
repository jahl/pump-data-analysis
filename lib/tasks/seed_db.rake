require 'csv'
require 'google/cloud/bigtable'

task seed_db: :environment do
  csv = CSV.parse(File.read('seeds/pump_data.csv'), headers: true)

  pump_data_table = PumpData.table

  entries = csv.map do |row|
    value = JSON.parse(csv.first["metrics"])["Psum"]["avgvalue"].to_s
    entry = pump_data_table.new_mutation_entry "pump##{row['deviceid']}##{row['fromts']}##{row['tots']}"
    entry.set_cell(
      PumpData::COLUMN_FAMILIES.first,
      'psum',
      value,
      timestamp: row['fromts'].to_f.round(-3)
    )
  end

  pump_data_table.mutate_rows entries
end
