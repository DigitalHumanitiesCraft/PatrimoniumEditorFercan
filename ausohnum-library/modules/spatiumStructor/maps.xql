xquery version "3.0";

module namespace maps = "http://ausohnum.huma-num.fr/maps";



(: Edit VR :)
(:~
 : Build leafletJS map
:)
declare function maps:build-leaflet-map-withGeoJson($GeoJson as xs:string, $total-count as xs:integer?) {
   <div
      id="map-data"
      style="margin-bottom:3em;">
      <script
         type="text/javascript"
         src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet/leaflet.js"/>
      <script
         type="text/javascript"
         src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet/leaflet.awesome-markers.min.js"/>
      <div
         id="map" style="height: 400px;"/>
      <script
         type="text/javascript"><!--
         
         var mbAttr = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
			'<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
			'Imagery © <a href="http://mapbox.com">Mapbox</a>';
			var dareAttr = 'Digital Atlas of the Roman Empire project <a href="https://dh.gu.se/dare/">DARE</a>,  <a href="https://creativecommons.org/licenses/by/4.0/">CC-BY-4.0</a> ';
            /*var terrain = L.tileLayer('http://api.tiles.mapbox.com/v3/sgillies.map-ac5eaoks/{z}/{x}/{y}.png', {attribution: "ISAW, 2012"});*/
                                
            /* Not added by default, only through user control action */
            /*var streets = L.tileLayer('http://api.tiles.mapbox.com/v3/sgillies.map-pmfv2yqx/{z}/{x}/{y}.png', {attribution: "ISAW, 2012"});*/
           var dare = L.tileLayer('https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {attribution:dareAttr});

              
           var mbUrl = 'https://api.mapbox.com/styles/v1/mapbox/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibmVmZXJuZWZlcm91YXRvbiIsImEiOiJjajA3eHpueG4wMDB2MzNvY3RtYXBocDdzIn0.XmDsYcxB2442ABeP25_BhQ';

    var grayscale   = L.tileLayer(mbUrl, {id: 'light-v9', attribution: mbAttr}),
	    streets  = L.tileLayer(mbUrl, {id: 'streets-v11',   attribution: mbAttr});
       
       
        mapLink =  '<a href="http://www.esri.com/">Esri</a>';
        wholink =  'i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community';
        var esriMap = L.tileLayer(
            'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: '&copy; '+mapLink+', '+wholink,
            maxZoom: 18,
            });
           
//-->
             var placesgeo = { $GeoJson }
         <!--                                
            L.Icon.Default.imagePath='/$ausohnum-lib/resources/scripts/spatiumStructor/leaflet/images/';
            var sropheIcon = L.Icon.extend({
                                            options: {
                                                iconSize:     [2, 2],
                                                iconAnchor:   [2, 2],
                                                popupAnchor:  [-1, -1]
                                                }
                                            });
                                            var redIcon =
                                                L.AwesomeMarkers.icon({
                                                    icon:'glyphicon',
                                                    markerColor: 'red'
                                                }),
                                            greenIcon =
                                                L.AwesomeMarkers.icon({
                                                    icon:'glyphicon',
                                                    markerColor: 'green'
                                                }),
                                            orangeIcon =  
                                                L.AwesomeMarkers.icon({
                                                    icon:'glyphicon',
                                                    markerColor: 'orange'
                                                }),
                                            purpleIcon = 
                                                L.AwesomeMarkers.icon({
                                                    icon:'glyphicon',
                                                    markerColor: 'purple'
                                                }),
                                             kakiIcon = 
                                                L.AwesomeMarkers.icon({
                                                    icon:'glyphicon',
                                                    markerColor: 'darkgreen'
                                                }),
                                            blueIcon =  L.AwesomeMarkers.icon({
                                                    icon:'glyphicon',
                                                    markerColor: 'blue'
                                                });
                                        
            var geojson = L.geoJson(placesgeo, {onEachFeature: function (feature, layer){
                        
                            var typeText = feature.properties.type
                            
                            docIds = feature.properties.hits.docId;
                            var listOfDocs = "";
                            if(Array.isArray(docIds) ==true){
                            $(docIds).each(function (index, value) {
                                    listOfDocs= listOfDocs + '<li><a href="/documents/' + value + '">Doc. ' + value + '</a></li>';
                                }); 
                            }else{
                                    listOfDocs= '<li><a href="/documents/' + docIds + '">Doc. ' + docIds + '</a></li>';

                            }


                            var popupContent = 
                                "<a href='" + feature.properties.uri + "' class='map-pop-title'>" +
                                feature.properties.name + "</a>" + (feature.properties.type ? "Type: " + typeText : "") +
                                (feature.properties.desc ? "<span class='map-pop-desc'>"+ feature.properties.desc +"</span>" : "")
                                + "<h7 style='display:block;'>Place of provenance of:</h7>"
                                + "<ol>" + listOfDocs + "</ol>"
                                ;
                                layer.bindPopup(popupContent);
         switch (feature.properties.lang) {
         	case 'xtg-Latn' : return layer.setIcon(orangeIcon);
         	case 'xtg-Grek' : return layer.setIcon(blueIcon);
         	case 'grc' : return layer.setIcon(blueIcon);
         	case 'lat' : return layer.setIcon(orangeIcon);
            case 'archaeo' : return layer.setIcon(kakiIcon);

         	default : return 
                
                    layer.setIcon(purpleIcon);
         }
                                switch (feature.properties.type) {
                                    case 'born-at': return layer.setIcon(orangeIcon);
                                    case 'syriaca:bornAt' : return layer.setIcon(orangeIcon);
                                    case 'died-at':   return layer.setIcon(redIcon);
                                    case 'syriaca:diedAt' : return layer.setIcon(redIcon);
                                    case 'has-literary-connection-to-place':   return layer.setIcon(purpleIcon);
                                    case 'syriaca:hasLiteraryConnectionToPlace' : return layer.setIcon(purpleIcon);
                                    case 'has-relation-to-place':   return layer.setIcon(blueIcon);
                                    case 'syriaca:hasRelationToPlace' :   return layer.setIcon(blueIcon);
                                    default : '';
                                 }               
                                }
                            })
        var map = L.map('map').fitBounds(geojson.getBounds(),{maxZoom: 18});     
        dare.addTo(map);
                                        
        L.control.layers({
        						"DARE": dare,
                        "OpenStreetMap": grayscale,
                        "ESRI Word Imagery": esriMap,
                        
                         }).addTo(map);
        geojson.addTo(map);     
//-->
      </script>
      <div>
         <div
            class="modal fade"
            id="map-selection"
            tabindex="-1"
            role="dialog"
            aria-labelledby="map-selectionLabel"
            aria-hidden="true">
            <div
               class="modal-dialog">
               <div
                  class="modal-content">
                  <div
                     class="modal-header">
                     <button
                        type="button"
                        class="close"
                        data-dismiss="modal">
                        <span
                           aria-hidden="true"> x </span>
                        <span
                           class="sr-only">Close</span>
                     </button>
                  </div>
                  <div
                     class="modal-body">
                     <div
                        id="popup"
                        style="border:none; margin:0;padding:0;margin-top:-2em;"/>
                  </div>
                  <div
                     class="modal-footer">
                     <a
                        class="btn"
                        href="/documentation/faq.html"
                        aria-hidden="true">See all FAQs</a>
                     <button
                        type="button"
                        class="btn btn-default"
                        data-dismiss="modal">Close</button>
                  </div>
               </div>
            </div>
         </div>
      </div>
      <script
         type="text/javascript">
         <![CDATA[
            $('#mapFAQ').click(function(){
                $('#popup').load( '../documentation/faq.html #map-selection',function(result){
                    $('#map-selection').modal({show:true});
                });
             });]]>
      </script>
   </div>
};