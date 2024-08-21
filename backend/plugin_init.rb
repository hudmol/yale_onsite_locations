LocationConverter.class_eval do
  def self.normalize_boolean
    @normalize_boolean ||= Proc.new {|val| val.to_s.upcase.match(/\A(1|T|Y|YES|TRUE)\Z/) ? true : false }
    @normalize_boolean
  end

  def self.configure
    {
      'location_building' => 'location.building',
      'location_floor' => 'location.floor',
      'location_room' => 'location.room',
      'location_area' => 'location.area',
      'location_barcode' => 'location.barcode',
      'location_classification' => 'location.classification',
      'location_coordinate_1_label' => 'location.coordinate_1_label',
      'location_coordinate_1_indicator' => 'location.coordinate_1_indicator',
      'location_coordinate_2_label' => 'location.coordinate_2_label',
      'location_coordinate_2_indicator' => 'location.coordinate_2_indicator',
      'location_coordinate_3_label' => 'location.coordinate_3_label',
      'location_coordinate_3_indicator' => 'location.coordinate_3_indicator',
      'location_temporary' => 'location.temporary',
      'location_onsite' => [normalize_boolean, 'location.onsite'],
    }
  end

end
