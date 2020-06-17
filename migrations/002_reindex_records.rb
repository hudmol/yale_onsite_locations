require 'db/migrations/utils'

Sequel.migration do

  up do
    now = Time.now
    [:resource, :archival_object, :accession, :top_container].each do |table|
      self[table].update(:system_mtime => now)
    end
  end

end



