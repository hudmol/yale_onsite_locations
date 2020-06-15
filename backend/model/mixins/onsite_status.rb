module OnsiteStatus

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def calculate_onsite_status(objs)
      result = {}

      if self == Resource
        # look at instances attached to resource (sometimes happens)
        Resource
          .join(:instance, Sequel.qualify(:instance, :resource_id) => Sequel.qualify(:resource, :id))
          .join(:sub_container, Sequel.qualify(:sub_container, :instance_id) => Sequel.qualify(:instance, :id))
          .join(:top_container_link_rlshp, Sequel.qualify(:top_container_link_rlshp, :sub_container_id) => Sequel.qualify(:sub_container, :id))
          .join(:top_container_housed_at_rlshp, Sequel.qualify(:top_container_housed_at_rlshp, :top_container_id) => Sequel.qualify(:top_container_link_rlshp, :top_container_id))
          .join(:location, Sequel.qualify(:location, :id) => Sequel.qualify(:top_container_housed_at_rlshp, :location_id))
          .filter(Sequel.qualify(:top_container_housed_at_rlshp, :status) => 'current')
          .filter(Sequel.qualify(:resource, :id) => objs.map(&:id))
          .distinct(Sequel.qualify(:resource, :id), Sequel.qualify(:location, :onsite))
          .select(Sequel.qualify(:resource, :id), Sequel.qualify(:location, :onsite))
          .each do |row|
          if result.has_key?(row[:id])
            result[row[:id]] = 'mixed'
          else
            result[row[:id]] = (row[:onsite] == 1 ? 'onsite' : 'offsite')
          end
        end

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

      elsif self == ArchivalObject
        ArchivalObject
          .join(:instance, Sequel.qualify(:instance, :archival_object_id) => Sequel.qualify(:archival_object, :id))
          .join(:sub_container, Sequel.qualify(:sub_container, :instance_id) => Sequel.qualify(:instance, :id))
          .join(:top_container_link_rlshp, Sequel.qualify(:top_container_link_rlshp, :sub_container_id) => Sequel.qualify(:sub_container, :id))
          .join(:top_container_housed_at_rlshp, Sequel.qualify(:top_container_housed_at_rlshp, :top_container_id) => Sequel.qualify(:top_container_link_rlshp, :top_container_id))
          .join(:location, Sequel.qualify(:location, :id) => Sequel.qualify(:top_container_housed_at_rlshp, :location_id))
          .filter(Sequel.qualify(:top_container_housed_at_rlshp, :status) => 'current')
          .filter(Sequel.qualify(:archival_object, :id) => objs.map(&:id))
          .distinct(Sequel.qualify(:archival_object, :id), Sequel.qualify(:location, :onsite))
          .select(Sequel.qualify(:archival_object, :id), Sequel.qualify(:location, :onsite))
          .each do |row|
          if result.has_key?(row[:id])
            result[row[:id]] = 'mixed'
          else
            result[row[:id]] = (row[:onsite] == 1 ? 'onsite' : 'offsite')
          end
        end
      else
        raise "Onsite Status not supported for type: #{self}"
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