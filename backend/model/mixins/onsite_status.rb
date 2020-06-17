module OnsiteStatus

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def calculate_onsite_status(objs)
      result = {}

      # Special case for TopContainer (they don't have containers)
      if self == TopContainer
        TopContainer
          .join(:top_container_housed_at_rlshp, Sequel.qualify(:top_container_housed_at_rlshp, :top_container_id) => Sequel.qualify(:top_container, :id))
          .join(:location, Sequel.qualify(:location, :id) => Sequel.qualify(:top_container_housed_at_rlshp, :location_id))
          .filter(Sequel.qualify(:top_container_housed_at_rlshp, :status) => 'current')
          .filter(Sequel.qualify(:top_container, :id) => objs.map(&:id))
          .distinct(Sequel.qualify(:top_container, :id), Sequel.qualify(:location, :onsite))
          .select(Sequel.qualify(:top_container, :id), Sequel.qualify(:location, :onsite))
          .each do |row|
          # only one location for a top container; no `mixed` required
          result[row[:id]] = (row[:onsite] == 1 ? 'onsite' : 'offsite')
        end

        return result
      end

      # Ok, let's deal with records that have instances
      backlink_col = "#{self.table_name}_id"

      self
        .join(:instance, Sequel.qualify(:instance, backlink_col) => Sequel.qualify(self.table_name, :id))
        .join(:sub_container, Sequel.qualify(:sub_container, :instance_id) => Sequel.qualify(:instance, :id))
        .join(:top_container_link_rlshp, Sequel.qualify(:top_container_link_rlshp, :sub_container_id) => Sequel.qualify(:sub_container, :id))
        .join(:top_container_housed_at_rlshp, Sequel.qualify(:top_container_housed_at_rlshp, :top_container_id) => Sequel.qualify(:top_container_link_rlshp, :top_container_id))
        .join(:location, Sequel.qualify(:location, :id) => Sequel.qualify(:top_container_housed_at_rlshp, :location_id))
        .filter(Sequel.qualify(:top_container_housed_at_rlshp, :status) => 'current')
        .filter(Sequel.qualify(self.table_name, :id) => objs.map(&:id))
        .distinct(Sequel.qualify(self.table_name, :id), Sequel.qualify(:location, :onsite))
        .select(Sequel.qualify(self.table_name, :id), Sequel.qualify(:location, :onsite))
        .each do |row|
        if result.has_key?(row[:id])
          result[row[:id]] = 'mixed'
        else
          result[row[:id]] = (row[:onsite] == 1 ? 'onsite' : 'offsite')
        end
      end

      if self == Resource
        # check children of the resource too and merge the status
        ArchivalObject
          .join(:resource, Sequel.qualify(:resource, :id) => Sequel.qualify(:archival_object, :root_record_id))
          .join(:instance, Sequel.qualify(:instance, :archival_object_id) => Sequel.qualify(:archival_object, :id))
          .join(:sub_container, Sequel.qualify(:sub_container, :instance_id) => Sequel.qualify(:instance, :id))
          .join(:top_container_link_rlshp, Sequel.qualify(:top_container_link_rlshp, :sub_container_id) => Sequel.qualify(:sub_container, :id))
          .join(:top_container_housed_at_rlshp, Sequel.qualify(:top_container_housed_at_rlshp, :top_container_id) => Sequel.qualify(:top_container_link_rlshp, :top_container_id))
          .join(:location, Sequel.qualify(:location, :id) => Sequel.qualify(:top_container_housed_at_rlshp, :location_id))
          .filter(Sequel.qualify(:top_container_housed_at_rlshp, :status) => 'current')
          .filter(Sequel.qualify(:resource, :id) => objs.map(&:id))
          .distinct(Sequel.qualify(:resource, :id), Sequel.qualify(:location, :onsite))
          .select(Sequel.qualify(:resource, :id), Sequel.qualify(:location, :onsite))
          .each do |row|
          status = (row[:onsite] == 1 ? 'onsite' : 'offsite')
          if result[row[:id]] == 'mixed' || result[row[:id]] == status
            next
          elsif result.has_key?(row[:id])
            result[row[:id]] = 'mixed'
          else
            result[row[:id]] = status
          end
        end
      end

      result
    end

    def sequel_to_jsonmodel(objs, opts = {})
      jsons = super

      onsite_status_map = calculate_onsite_status(objs)

      objs.zip(jsons).each do |obj, json|
        json['onsite_status'] = onsite_status_map.fetch(obj.id, 'onsite')
      end

      jsons
    end

  end
end