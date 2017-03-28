class Segment
  attr_accessor :flight_number, :stop_no_plane_change, :has_wifi
  def initialize(flyday_segment)
    @flight_number = flyday_segment['operatingCarrierInfo']['flightNumber']
    @stop_no_plane_change = flyday_segment['numberOfStops'] > 0
    @has_wifi = flyday_segment['wifiAvailable']
  end

  def to_s
    "#{flight_number} " +
    (has_wifi ? ' <i class="fa fa-wifi text-success"></i>' : ' <i class="fa fa-wifi text-danger"></i>') +
    (stop_no_plane_change ? ' <i class="fa fa-map-signs" style="color:#ff8c00"></i>' : '')
  end
end
