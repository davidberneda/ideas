function initMap() {
  const babili = { lat: 32.536389, lng: 44.420833 };
  
  const map = new google.maps.Map(document.getElementById("map"), { zoom: 4, center: babili, });
  
  const marker = new google.maps.Marker({ position: babili, map: map, });
}
