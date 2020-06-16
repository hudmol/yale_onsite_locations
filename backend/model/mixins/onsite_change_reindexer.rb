module OnsiteChangeReindexer

  def reindex_records_contained_within!
    records_to_poke = {}

    Location
      .join(:top_container_housed_at_rlshp, Sequel.qualify(:top_container_housed_at_rlshp, :location_id) => Sequel.qualify(:location, :id))
      .join(:top_container_link_rlshp, Sequel.qualify(:top_container_link_rlshp, :top_container_id) => Sequel.qualify(:top_container_housed_at_rlshp, :top_container_id))
      .join(:sub_container, Sequel.qualify(:sub_container, :id) => Sequel.qualify(:top_container_link_rlshp, :sub_container_id))
      .join(:instance, Sequel.qualify(:instance, :id) => Sequel.qualify(:sub_container, :instance_id))
      .filter(Sequel.qualify(:location, :id) => self.id)
      .filter(Sequel.qualify(:top_container_housed_at_rlshp, :status) => 'current')
      .select(Sequel.qualify(:instance, :archival_object_id),
              Sequel.qualify(:instance, :resource_id),
              Sequel.qualify(:instance, :accession_id))
      .each do |row|
      if row[:resource_id]
        records_to_poke[Resource] ||= []
        records_to_poke[Resource] << row[:resource_id]
      elsif row[:archival_object_id]
        records_to_poke[ArchivalObject] ||= []
        records_to_poke[ArchivalObject] << row[:archival_object_id]
      elsif row[:accession_id]
        records_to_poke[Accession] ||= []
        records_to_poke[Accession] << row[:accession_id]
      end
    end

    if records_to_poke.has_key?(ArchivalObject)
      ArchivalObject
        .filter(:id => records_to_poke.fetch(ArchivalObject))
        .select(:root_record_id)
        .each do |row|
        records_to_poke[Resource] ||= []
        records_to_poke[Resource] << row[:root_record_id]
      end
    end

    records_to_poke.each do |model, ids|
      model.update_mtime_for_ids(ids.uniq)
    end
  end

  def update_from_json(json, opts = {}, apply_nested_records = true)
    old_onsite = self.onsite

    obj = super

    # if `onsite` has changed then reindex all records contained
    # within this location
    if old_onsite != obj.onsite
      reindex_records_contained_within!
    end

    obj
  end

end