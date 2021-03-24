function initMap() {

  const image ="babylon32.png";

  const babili_pos = { lat: 32.536389, lng: 44.420833 };
  const map = new google.maps.Map(document.getElementById("map"), { zoom: 8, center: babili_pos, });

  const agade = new google.maps.Marker({ title: "Agade / Tell Mohammed",
                     position: { lat: 33.90962758243391, lng: 44.53480309997145 }, map: map, });

  const babili = new google.maps.Marker({ title: "Babili / Babylon",
                     position: babili_pos, map: map, });

  const barsipa = new google.maps.Marker({ title: "Barsipa / Birs Nimrud",
                     position: { lat: 32.39198758683342, lng: 44.34127626903373 }, map: map, });

  const emeslam = new google.maps.Marker({ title: "Emeslam / Nergal, Cutha",
                     position: { lat: 32.760028, lng: 44.612861 }, map: map, });

  const eridu = new google.maps.Marker({ title: "Eridu / Abu Shahrein",
                     position: { lat: 30.82616123644755, lng: 45.99465066921363 }, map: map, });

  const esarra = new google.maps.Marker({ title: "Ešarra / Nippur",
                     position: { lat: 32.1261, lng: 45.2308 }, map: map,
                     icon: image });

}
