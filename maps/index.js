function initMap() {

  const babili_pos = { lat: 32.536389, lng: 44.420833 };
  const map = new google.maps.Map(document.getElementById("map"), { zoom: 7, center: babili_pos, });
  
  const agade = new google.maps.Marker({ title: "Agade / Tell Mohammed", position: { lat: 36.924371, lng: 41.564096 }, map: map, });
  const babili = new google.maps.Marker({ title: "Babili", position: babili_pos, map: map, });
  
}
