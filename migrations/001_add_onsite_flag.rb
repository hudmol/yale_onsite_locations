require 'db/migrations/utils'

Sequel.migration do

  up do
    alter_table(:location) do
      add_column(:onsite, Integer, :default => 1, :null => false)
    end
  end

end

