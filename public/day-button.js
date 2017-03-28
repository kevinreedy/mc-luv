var glob = null;
function get_nearby_prices(date, orig, dest, route_type, days) {
  $.ajax({
    type: "POST",
    url: "/nearby_prices",
    data: { date: date, orig: orig, dest: dest, route_type: route_type, days: days },
    success: function(data) {
      var lowest_price = null;

      // first pass to find lowest price - 0's and nulls make this more complex
      for (var date in data) {
        var price = data[date];
        if (price == null || price == 0) {
          data[date] = 0;
        } else {
          if (lowest_price == null || price < lowest_price ) {
            lowest_price = price;
          }
        }
      }

      for (var date in data) {
        var price = data[date];

        if (price == 0) {
          $("#price-"+date).addClass("btn-default").removeClass("btn-primary").removeClass("btn-info");
          $("#price-"+date).html(date + "<br />Unavailable");
        } else {
          if (price == lowest_price) {
            $("#price-"+date).html(date + "<br /><i class=\"fa fa-star\"></i> $" + price);
          } else {
            $("#price-"+date).html(date + "<br />$" + price);
          }
        }
      }
    }
  });
}
