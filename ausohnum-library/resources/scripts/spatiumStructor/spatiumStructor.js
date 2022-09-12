function getCurrentDocId(){        return $('#currentDocId').html() };
function getCurrentPlaceUri(){    return $('#currentPlaceUri').html() };
function getCurrentPlaceCoordinates(){    return $('#currentPlaceCoordinates').html() };
function getCurrentProject(){      $('#currentProject').text(); };

var docId = $("#currentDocId").text();

var atlasMap ;



$( document ).ready(function() {
    $(".addResourceForm").click(function(event){event.preventDefault();});

/***************************************    
*    Stuff for map in ATLAS   *
**************************************
*/
if(document.getElementById("atlasMap")){

/*Basemaps for maps*/
    var satelliteMap = L.tileLayer.provider('MapBox', {
                                        id: 'mapbox.satellite',
                                        accessToken: 'pk.eyJ1IjoidnJhemFuYWphbyIsImEiOiJjanR0dzU5a2ExMnR5NDRsOHVsdGk2cjdoIn0.3UtNLHIkJ96HSp8qLyFZUA'
                                           });
                


    var openStreetMap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                                        });       
 
    var AWMCBaseMapMap = L.tileLayer(
            'http://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png',
            {
            attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                id: 'isawnyu.map-knmctlkh'
                //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });
    var AWMCRoadsMap = L.tileLayer(
            'http://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png',
            {
            attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                id: 'isawnyu.awmc-roads'
                //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });

 
    var imperiumMap = L.tileLayer('https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
                                     attribution: 'Digital Atlas of the Roman Empire (DARE) project<a href="http://dare.ht.lu.se">http://dare.ht.lu.se</a> <a href="http://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>'
                                     //maxZoom: 0,
                                     //id: 'isawnyu.map-knmctlkh',
                                     //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
                                     });

     var opentopomap = L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
         attribution: 'Kartendaten: © <a href="https://openstreetmap.org/copyright">OpenStreetMap</a>-Mitwirkende, SRTM | Kartendarstellung: © <a href="http://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
         });
    
    var provinces14Shapefiles = "/places/roman-provinces/roman-provinces_14.zip";
   shp(provinces14Shapefiles).then(function (data) {
        romanProvinces14.addData(data, true);
    });
   var romanProvinces14 = L.geoJson({ features: [] }, {
        onEachFeature: function popUp(f, l) {
            var out = [];
            if (f.properties) {
                for (var key in f.properties) {
                    out.push(key + ": " + f.properties[key]);
                }
                l.bindPopup(out.join("<br />"));
            }
            l.on({
                    'add': function () {
                        l.bringToBack();
                        l.setStyle({ color: '#7D1D20', fillColor: 'transparent' });
                    }
                })
        }
    })
   var provinces69Shapefiles = "/places/roman-provinces/roman-provinces_69.zip";
    var romanProvinces69 = L.geoJson({ features: [] }, {
        onEachFeature: function popUp(f, l) {
            var out = [];
            if (f.properties) {
                for (var key in f.properties) {
                    out.push(key + ": " + f.properties[key]);
                }
                l.bindPopup(out.join("<br />"));
            }
            l.on({
                    'add': function () {
                        l.bringToBack();
                        l.setStyle({ color: '#d4c200', fillColor: 'transparent' });
                    }
                })
        }
    })
    // .addTo(displayMap);
    
    
    
     shp(provinces69Shapefiles).then(function (data) {
        romanProvinces69.addData(data, true);
    });
    
    var provinces117Shapefiles = "/places/roman-provinces/roman-provinces_117.zip";
    var romanProvinces117 = L.geoJson({ features: [] }, {
        onEachFeature: function popUp(f, l) {
            var out = [];
            if (f.properties) {
                for (var key in f.properties) {
                    out.push(key + ": " + f.properties[key]);
                }
                l.bindPopup(out.join("<br />"));
            }
            l.on({
                    'add': function () {
                        l.bringToBack();
                        l.setStyle({ color: "#003180", fillColor: 'transparent' });
                    }
                })
        }
    })
    // .addTo(displayMap);
    
    
    
     shp(provinces117Shapefiles).then(function (data) {
        romanProvinces117.addData(data, true);
    });

var provinces200Shapefiles = "/places/roman-provinces/roman-provinces_200.zip";
    var romanProvinces200 = L.geoJson({ features: [] }, {
        onEachFeature: function popUp(f, l) {
            var out = [];
            if (f.properties) {
                for (var key in f.properties) {
                    out.push(key + ": " + f.properties[key]);
                }
                l.bindPopup(out.join("<br />"));
            }
            l.on({
                    'add': function () {
                        l.bringToBack();
                        l.setStyle({ color: "#0c8a13", fillColor: 'transparent' });
                    }
                })
        }
    })
     shp(provinces200Shapefiles).then(function (data) {
        romanProvinces200.addData(data, true);
    });
    
         var provinces280Shapefiles = "/places/roman-provinces/roman-provinces_200.zip";
    var romanProvinces280 = L.geoJson({ features: [] }, {
        onEachFeature: function popUp(f, l) {
            var out = [];
            if (f.properties) {
                for (var key in f.properties) {
                    out.push(key + ": " + f.properties[key]);
                }
                l.bindPopup(out.join("<br />"));
            }
            l.on({
                    'add': function () {
                        l.bringToBack();
                        l.setStyle({ color: "#6d0c8a", fillColor: 'transparent' });
                    }
                })
        }
    })
    
     shp(provinces280Shapefiles).then(function (data) {
        romanProvinces280.addData(data, true);
    });
    mapLink =  '<a href="http://www.esri.com/">Esri</a>';
    wholink =  'i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community';
    var esriMap = L.tileLayer(
            'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: '&copy; '+mapLink+', '+wholink,
            maxZoom: 18
            });
    atlasMap = L.map('atlasMap', {
                                        maxZoom: 18,
                                        fullscreenControl: {
                                        pseudoFullscreen: false}
                                        });
    atlasMap.setView([41.891775, 12.486137], 5);
    atlasMap.createPane('markerPanelRear');
    atlasMap.getPane('markerPanelRear').style.zIndex = 600;
    atlasMap.createPane('markerPanelBottom');
    atlasMap.getPane('markerPanelBottom').style.zIndex = 610;
        
    atlasMap.createPane('markerPanelTop');
    atlasMap.getPane('markerPanelTop').style.zIndex = 640;    

       atlasMap.createPane('markerPanelHighest');
    atlasMap.getPane('markerPanelTop').style.zIndex = 647;
        
       var tempArea;
        var geojsonFeatureProject;
        var geojsonFeatureProdUnits;
       
        var clusterMarkersOptions =
            {
            showCoverageOnHover: false,
            zoomToBoundsOnClick: true,
            removeOutsideVisibleBounds: true,
            disableClusteringAtZoom: 8,
            spiderfyOnMaxZoom: true,
            maxClusterRadius: 80,
            spiderfyOnEveryZoom: true}

       var allMarkersClusterGroup;
        
        allMarkersClusterGroup= L.markerClusterGroup(
       clusterMarkersOptions
        ),
        projectPlacesMarkers = L.featureGroup.subGroup(allMarkersClusterGroup),// use `L.featureGroup.subGroup(parentGroup)` instead of `L.featureGroup()` or `L.layerGroup()`!
        productionUnitsMarkers = L.featureGroup.subGroup(allMarkersClusterGroup);
        
        /*var projectPlacesMarkers = L.markerClusterGroup(clusterMarkersOptions
         //{  disableClusteringAtZoom: 12 }
         );
        var productionUnitsMarkers = L.markerClusterGroup(clusterMarkersOptions);*/     


        console.log("In Atlas");
       markerMap = {};
       markerMapDuplicate = {};
       tempLayerGroup = L.layerGroup();
       
    //Handling places at the very same coordinates ==> https://github.com/jawj/OverlappingMarkerSpiderfier-Leaflet       
        var clusterMarkers4OverlappingPlacesOptions =
            {
            showCoverageOnHover: false,
            zoomToBoundsOnClick: false,
            removeOutsideVisibleBounds: true,
            disableClusteringAtZoom: 20,
            spiderfyOnMaxZoom: true,
            maxClusterRadius: 10,
            spiderfyDistanceMultiplier:2,
            spiderfyOnEveryZoom: true
            /*,
            iconCreateFunction: function (cluster) {
				var markers = cluster.getAllChildMarkers();
				/\*var n = 0;
				for (var i = 0; i < markers.length; i++) {
					n += markers[i].number;
				}*\/
				return L.divIcon({ html: "Overl. places: " + markers.length, className: 'overlappingPlacesMarker', iconSize: L.point(80, 40) });
			}*/
            }
       
         var overlappingPlacesClusterMarkers = L.markerClusterGroup(clusterMarkers4OverlappingPlacesOptions);
       projectPlacesMarkersOP = L.featureGroup.subGroup(overlappingPlacesClusterMarkers),// use `L.featureGroup.subGroup(parentGroup)` instead of `L.featureGroup()` or `L.layerGroup()`!
        productionUnitsMarkersOP = L.featureGroup.subGroup(overlappingPlacesClusterMarkers);     
       
       /*overlappingPlacesClusterMarkers.on('spiderfied unspiderfied', function (event) {
                
                 });
        function removePolygon() {
			if (shownLayer) {
				shownLayer.setOpacity(1);
				shownLayer = null;
			}
			if (polygon) {
				atlasMap.removeLayer(polygon);
				polygon = null;
			}
		};

		overlappingPlacesClusterMarkers.on('clustermouseover', function (a) {
			removePolygon();

			a.layer.setOpacity(0.2);
			shownLayer = a.layer;
			polygon = L.polygon(a.layer.getConvexHull());
			atlasMap.addLayer(polygon);
		});
		overlappingPlacesClusterMarkers.on('clustermouseout', removePolygon);*/
        
   /*     GET PROJECT PLACES                  */
        
        var geojsonProject = new Object();
      
      projectPlacesLayerCluster =
            L.geoJSON(false,{
            onEachFeature: onEachFeatureProjectCluster, 
            pointToLayer: pointToLayerProjectPlace});
          
         getProjectPlaces(geojsonProject, function(geojsonProject){
                       /* projectPlacesLayerCluster.addData(geojsonProject);
                        projectPlacesMarkers.addLayer(projectPlacesLayerCluster);
                        overlappingPlacesClusterMarkers.addLayer(projectPlacesLayerCluster);//for overlapping places
                        atlasMap.addLayer(projectPlacesMarkers);*/

                        projectPlacesLayerCluster.addData(geojsonProject);
                        projectPlacesMarkers.addLayer(projectPlacesLayerCluster);
                        projectPlacesMarkersOP.addLayer(projectPlacesLayerCluster);
                        //projectPlacesMarkers.removeLayer(markerMap["https://patrimonium.huma-num.fr/places/56744"]);
                        //overlappingPlacesClusterMarkers.addLayer(projectPlacesLayerCluster);//for overlapping places

                        projectPlacesMarkers.addTo(atlasMap);
                       projectPlacesMarkersOP.addTo(atlasMap);
                        //overlappingPlacesClusterMarkers.addLayer(projectPlacesLayerCluster);//for overlapping places
                        });
    
            
            
            /*GET PRODUCTION UNITS*/
        
        var geojsonProductionUnit = new Object();
        
        //var productionUnitsLayer = L.geoJSON(false, {onEachFeature: onEachFeatureProductionUnitsCluster, pointToLayer: pointToLayerProductionUnits});   
        
        productionUnitsPlacesLayerCluster =
            L.geoJSON(false,{onEachFeature: onEachFeatureProductionUnitsCluster, pointToLayer: pointToLayerProductionUnits});
        
       getProdUnitsPlaces(geojsonProductionUnit, function(geojsonProductionUnit){
                                  /*productionUnitsPlacesLayerCluster.addData(geojsonProductionUnit);
                                  productionUnitsMarkers.addLayers(productionUnitsPlacesLayerCluster);
                                  overlappingPlacesClusterMarkers.addLayer(productionUnitsPlacesLayerCluster);
                                  atlasMap.addLayer(productionUnitsMarkers);*/
                                  productionUnitsPlacesLayerCluster.addData(geojsonProductionUnit);
                                   productionUnitsMarkers.addLayer(productionUnitsPlacesLayerCluster);
                                   productionUnitsMarkersOP.addLayer(projectPlacesLayerCluster);
                                   //overlappingPlacesClusterMarkers.addLayer(productionUnitsPlacesLayerCluster);
                                   
                                  productionUnitsMarkers.addTo(atlasMap);
                                  productionUnitsMarkersOP.addTo(atlasMap);
                                  //overlappingPlacesClusterMarkers.addLayer(productionUnitsPlacesLayerCluster);
                                  });  
        
        //productionUnitsPlacesLayerCluster = L.markerClusterGroup(
        //{  disableClusteringAtZoom: 5 }
        //);
            
            
            /****************
            *   Events   *
            ****************/
            atlasMap.on('moveend', function onMoveEnd(){
                    
                    var currentZoom = atlasMap.getZoom(); 
                    console.log("Zoom: " + currentZoom);
                    /*if(currentZoom > 9){
                        if(atlasMap.hasLayer(overlappingPlacesClusterMarkers) === false){
                            atlasMap.addLayer(overlappingPlacesClusterMarkers);}
                           }else {
                               if(atlasMap.hasLayer(overlappingPlacesClusterMarkers) === true){
                                   atlasMap.removeLayer(overlappingPlacesClusterMarkers);}
                           }*/
                    
                    });


/*var searchControl = new L.Control.Search({
		layer: projectPlacesLayerCluster,
		propertyName: 'name',
		marker: false,
		moveToLocation: function(latlng, title, atlasMap) {
			//map.fitBounds( latlng.layer.getBounds() );
			var zoom = atlasMap.getBoundsZoom(latlng.layer.getBounds());
  			atlasMap.setView(latlng, zoom); // access the zoom
		}
	});
	
searchControl.on('search:locationfound', function(e) {
		e.layer.setStyle({fillColor: '#3f0', color: '#0f0'});
		if(e.layer._popup)
			e.layer.openPopup();

	           }).on('search:collapsed', function(e) {
                                  projectPlacesLayerCluster.eachLayer(function(layer) {	//restore feature color
			projectPlacesLayerCluster.resetStyle(layer);
		});	
	});
*/
L.control.scale({ position: "bottomleft" }).addTo(atlasMap);


atlasMap.addLayer(allMarkersClusterGroup);
/*
/*ADD base maps and layers*/      
        var baseMaps = {
                //"AWMC BaseMap": AWMCBaseMapMap,
               "MapBox satellite" : satelliteMap,
                "OpenStreetMap" : openStreetMap,
                "OpenTopoMap": opentopomap,
                "ESRI World Imagery" : esriMap, 
                "DARE": imperiumMap
        };
        var overlayMaps;
        overlayMaps = {
            "Project places": projectPlacesMarkers,
            "Production units": productionUnitsMarkers,
            "Roman provinces 14 AD": romanProvinces14,
            "Roman provinces 69 AD": romanProvinces69,
            "Roman provinces 117 AD": romanProvinces117,
            "Roman provinces 200 AD": romanProvinces200,
            "Roman provinces 280 AD": romanProvinces280,
            "AWMC Roads": AWMCRoadsMap
            /*"Geonames": geonamesLayer,
            "AWMC Coastlines": AWMCCoastlinesMap,
            "Peripleo Result": peripleoSearchSelect,
            "edit":editableLayers*/
        };
        
        L.control.layers(baseMaps, overlayMaps
        , {position: 'topleft', 
        width : "35px"}
        ).addTo(atlasMap);
        
       
        
        atlasMap.addLayer(openStreetMap, projectPlacesLayerCluster, productionUnitsPlacesLayerCluster);
                    
      



var searchControl =  L.Control.extend({

                    options: {
                      position: 'topleft'
                    },
                  
                    onAdd: function (atlasMap) {
                      var container = L.DomUtil.create('input', "leaflet-search-control");
                      container.type="button";
                      container.title="Open Search panel";
                      
                      container.style.width = '34px';
                      container.style.height = '34px';
                      
                      container.style.border = "2px solid rgba(0,0,0,0.2)";
                      container.style.backgroundClip = "padding-box";
                      container.style.backgroundColor = 'white';     
                      container.style.backgroundImage = "/$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/images/search-icon.png";
                      container.style.backgroundPosition = "5px 5px";
                      container.style.boxShadow= "none";
                      container.style.backgroundRepeat = "no-repeat";
                      
                      
                      /*container.onmouseover = function(){
                        container.style.backgroundColor = 'pink'; 
                      }
                      container.onmouseout = function(){
                        container.style.backgroundColor = 'white'; 
                      }*/
                  
                      container.onclick = function(){
                      
                          $("#atlasSearchPanel").toggleClass("hidden");
                          }
                  
                      return container;
                    }
                  });
                  
	atlasMap.addControl( new searchControl());  //inizialize search control

var legendButtonControl =  L.Control.extend({

                    options: {
                      position: 'topleft'
                    },
                  
                    onAdd: function (atlasMap) {
                      var container = L.DomUtil.create('input', "legendButton-control");
                      container.type="button";
                      container.title="Open Legend";
                      container.style.width = '34px';
                      container.style.height = '34px';
                      
                      container.style.border = "2px solid rgba(0,0,0,0.2)";
                      container.style.backgroundClip = "padding-box";
                      container.style.backgroundColor = 'white';     
/*                      container.style.backgroundImage = "/$ausohnum-lib-dev/resources/scripts/spatiumStructor/legend.png";*/
                      container.style.backgroundPosition = "5px 5px";
                      container.style.boxShadow= "none";
                      container.style.backgroundRepeat = "no-repeat";
                      
                      
                      /*container.onmouseover = function(){
                        container.style.backgroundColor = 'pink'; 
                      }
                      container.onmouseout = function(){
                        container.style.backgroundColor = 'white'; 
                      }*/
                  
                      container.onclick = function(){
                      
                          $("#atlasMapLegend").toggleClass("hidden");
                          }
                  
                      return container;
                    }
                  });
                  
	atlasMap.addControl( new legendButtonControl());  //inizialize search control

L.control.polylineMeasure({measureControlTitleOn: 'Turn on distance measurement tool', measureControlTitleOff: 'Turn off distance measurement tool' }).addTo(atlasMap);

 
     /*Legend specific*/
  var circleMarkers = [administrativeMarkerOptions, cityMarkerOptions,  
  militaryCampMarkerOptions, 
  miningTerritoryMarkerOptions, modernPlaceMarkerOptions, nomosMarkerOptions,
  ousiaMarkerOptions,  placeMarkerOptions,
   provinceMarkerOptions, supraDistrictMarkerOptions].sort((a,b) => (a.radius> b.radius) ? 1 : ((b.radius > a.radius) ? -1 : 0));
  let cmLen = circleMarkers.length;
  var circleMarkersList = "";
        for (let i = 0; i < cmLen; i++) {
        if(circleMarkers[i].fillOpacity != 0) {var backgroundColor = circleMarkers[i].fillColor}
            else {var backgroundColor = 'transparent'}
            
  circleMarkersList += '<li class="legendItemList" style="display: inline-flex;">'
  + '<svg height="'+ ((circleMarkers[i].radius * 3)+3) +'" width="'+( (circleMarkers[i].radius * 3) +3) +'">'
  + '<circle cx="'+ (circleMarkers[i].radius + 2) +'" cy="'+ (circleMarkers[i].radius + 2) +'" r="' + circleMarkers[i].radius +'" stroke="' +circleMarkers[i].color +'" stroke-width="' + '2'+'" fill="' + backgroundColor +'" />'
  + '</svg>'
  + '<span class="legendLabel" style="padding-left:3!important;">' + circleMarkers[i].label + '</span>'
  + '</li>'

  /*<span style="width: ' + circleMarkers[i].radius  +'px; height: '+ circleMarkers[i].radius + 'px; border-radius: ' 
  /\*+ (circleMarkers[i].radius/2)*\/ +'50%;'
  + 'background:' + backgroundColor 
  + '; border: 1px solid; border-color: ' + circleMarkers[i].color +';'
  
  +'">\xa0\xa0\xa0</span>\xa0' + circleMarkers[i].label + '</li>';*/
}
  
var legend = L.control({ position: "bottomright" });

legend.onAdd = function(map) {
  var div = L.DomUtil.create("div", "legend hidden");
  div.setAttribute("id", "atlasMapLegend")
 div.innerHTML += '<button id="closeLegendPaneButton" type="button" class="close pull-right" onclick="closeAtlasLegendPanel()" style="margin: 3px; outline: none;"><i class="glyphicon glyphicon-remove-circle"></i></button>'; 
  div.innerHTML += "<h5>Legend</h5>";
 
    div.innerHTML += '<ul style="list-style:none; padding: 0;">'+ circleMarkersList + '</ul>';
  div.innerHTML += "<h6>Production units</h6>";
    div.innerHTML += '<ul style="list-style:none; padding: 0;">'
        + ' <li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-villa.png"/><span class="legendLabel">villa</span></li>'
        + '<li><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-forest-pasture.png"/><span class="legendLabel">forest/pasture</span></li>'
        + '</ul>';
  div.innerHTML += "<h7>Production</h7>";
   div.innerHTML += '<ul style="list-style:none; padding: 0;">'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-workshops-bread.png"/><span class="legendLabel">bread</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-workshops-bricks.png"/><span class="legendLabel">bricks/tiles</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-workshops-ceramics.png"/><span class="legendLabel">ceramics</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-workshops-clothing.png"/><span class="legendLabel">clothing</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-workshops-glass.png"/><span class="legendLabel">glass</span></li>'
   + '<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-workshops-oliveoil.png"/><span class="legendLabel">olive oil</span></li>'
   + '<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-workshops-weapons.png"/><span class="legendLabel">weapons</span></li>'
   + '</ul>';

   div.innerHTML += '<ul style="list-style:none; padding: 0;">'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-cows.png"/><span class="legendLabel">cows</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-dates.png"/><span class="legendLabel">dates</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-fishery.png"/><span class="legendLabel">fishery</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-goats.png"/><span class="legendLabel">goats</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-honey.png"/><span class="legendLabel">honey</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-horses.png"/><span class="legendLabel">horses</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-olives.png"/><span class="legendLabel">olives</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-papyrus.png"/><span class="legendLabel">papyrus</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-pigs.png"/><span class="legendLabel">pigs</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-sheeps.png"/><span class="legendLabel">sheep</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-vineyard.png"/><span class="legendLabel">vine/wine</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-farming-wheat.png"/><span class="legendLabel">cereals/generic agricultural ouput</span></li>'
   +'</ul>'
  
  div.innerHTML += "<h7>Extraction</h7>";
   div.innerHTML += '<ul style="list-style:none; padding: 0;">'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-mines.png"/><span class="legendLabel">mine</span></li>'
   +'<li class="legendItemList"><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-smelteries.png"/><span class="legendLabel">smelteries</span></li>'
 
   
   +'<li><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-extraction-marble.png"/><span class="legendLabel">marble</span></li>'
   +'<li><img class="legendImg" src="/$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-extraction-salt.png"/><span class="legendLabel">salt</span></li>'
   +'</ul>';
  return div;
  };
legend.addTo(atlasMap);







          
         
};/*End of Atlas Map*/

/***************************************    
*    Stuff for map in TeiEditor   *
**************************************
*/
if(document.getElementById("editorMap")){
 
 console.log("editorMap exists");
        var editorMap = L.map('editorMap', {
                                    maxZoom: 18,
                                           fullscreenControl: {
                                        pseudoFullscreen: false}
                                        });
        
        editorMap.setView([41.891775, 12.486137], 5);
        editorMap.on('mousemove',         function (e) { 
        latLng = e.latlng.toString();
        var lat = latLng.substring(7, latLng.indexOf(","));
        var longt = latLng.substring(latLng.indexOf(",")+1, latLng.indexOf(")"));
                    $("#positionInfo").html("Coordinates (lat., long.): " + lat + ", " + longt + " (" + convertDMS( lat, longt ) + ")"); });
                    
        editorMap.on('click',         function (e) { 
        latLng = e.latlng.toString();
        var lat = latLng.substring(7, latLng.indexOf(","));
        var longt = latLng.substring(latLng.indexOf(",")+1, latLng.indexOf(")"));
                    $("#savedPositionInfo").html("Click to store current position: lat., long. " + lat + ", " + longt + " (" + convertDMS( lat, longt ) + ")"); });
                    
         editorMap.createPane('markerPanelRear');
    editorMap.getPane('markerPanelRear').style.zIndex = 600;
    editorMap.createPane('markerPanelBottom');
    editorMap.getPane('markerPanelBottom').style.zIndex = 610;
        
    editorMap.createPane('markerPanelTop');
    editorMap.getPane('markerPanelTop').style.zIndex = 640;    

       editorMap.createPane('markerPanelHighest');
    editorMap.getPane('markerPanelTop').style.zIndex = 647;
/*        
********************************
*          Basemaps            *
*********************************/


/*        var editorMaps = L.layerGroup([documentPlacesLayer, projectPlacesLayer, ISAWMap, ImperieumMap]);*/

         var satelliteMap = L.tileLayer.provider('MapBox', {
                                        id: 'mapbox.satellite',
                                        accessToken: 'pk.eyJ1IjoidnJhemFuYWphbyIsImEiOiJjanR0dzU5a2ExMnR5NDRsOHVsdGk2cjdoIn0.3UtNLHIkJ96HSp8qLyFZUA'
                                           });
                


        var openStreetMap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                                        });       
 
              var AWMCBaseMapMap = L.tileLayer(
            'http://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png',
            {
            attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                id: 'isawnyu.map-knmctlkh'
                //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });
         var AWMCRoadsMap = L.tileLayer(
            'http://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png',
            {
            attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                id: 'isawnyu.awmc-roads'
                //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });
/*         .addTo(editorMap); */
 
        var imperiumMap = L.tileLayer('https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
                                     attribution: 'Digital Atlas of the Roman Empire (DARE) project<a href="http://dare.ht.lu.se">http://dare.ht.lu.se</a> <a href="http://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>'
                                     //maxZoom: 0,
                                     //id: 'isawnyu.map-knmctlkh',
                                     //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
                                     });
/*         .addTo(editorMap); */
 
         mapLink =  '<a href="http://www.esri.com/">Esri</a>';
        wholink =  'i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community';
        var esriMap = L.tileLayer(
            'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: '&copy; '+mapLink+', '+wholink,
            maxZoom: 18
            });
 

/*        
*********************************
*          Layer maps            *
*********************************/

var docId = getCurrentDocId();
    

/*        Load Project and Document places*/
        var geojsonFeatureProject;
        var geojsonFeatureDocument;
        var geojsonFeatureProdUnits;
        
        var geojsonDocument = new Object();
       
        var projectPlacesLayer;
        
        var prodUnitsLayer;
        
        var markers = L.markerClusterGroup({  disableClusteringAtZoom: 7 });
/*        var url = "/geo/places/json";*/
/*                            console.log(JSON.stringify($.getJSON("/geo/places/json", function(json){
                                        console.log(JSON.stringify(geojsonFeatureProject = json[0].places));
                                return json[0].places;
                                             
                                           })));
                                           */
        var clusterMarkersOptionsForPlaceManager =
            {
            showCoverageOnHover: false,
            zoomToBoundsOnClick: true,
            removeOutsideVisibleBounds: true,
            disableClusteringAtZoom: 8,
            spiderfyOnMaxZoom: true,
            maxClusterRadius: 80,
            spiderfyOnEveryZoom: true}
   var allMarkersClusterGroup;
      allMarkersClusterGroup= L.markerClusterGroup(
       clusterMarkersOptionsForPlaceManager
        ),
        projectPlacesMarkers = L.featureGroup.subGroup(allMarkersClusterGroup),// use `L.featureGroup.subGroup(parentGroup)` instead of `L.featureGroup()` or `L.layerGroup()`!
        productionUnitsMarkers = L.featureGroup.subGroup(allMarkersClusterGroup);
                                                 
                                           
                                           
                                           
/*     GET PROJECT PLACES                  */
        console.log("In Editor; current doc = " + docId);
        var geojsonProject = new Object();
        markerMap = {};
        tempLayerGroup = L.layerGroup();
/*        var projectPlacesLayer = L.geoJSON(false, {onEachFeature: onEachFeatureProject});   */
         //projectPlacesLayerCluster = L.markerClusterGroup({  disableClusteringAtZoom: 5 });
         projectPlacesLayerCluster = L.geoJSON(false,{onEachFeature: onEachFeatureProjectCluster, pointToLayer: pointToLayerProjectPlace});
          
         getProjectPlaces(geojsonProject, function(geojsonProject){
         
                        projectPlacesLayerCluster.addData(geojsonProject);
                        projectPlacesMarkers.addLayer(projectPlacesLayerCluster);
                        //projectPlacesMarkers.addTo(editorMap);
         
                        //projectPlacesLayerCluster.addData(geojsonProject);
    //if (docId === undefined) {editorMap.addLayer(projectPlacesLayerCluster);};
                        
                                                                                                        /*projectPlacesLayer = L.geoJSON(geojsonProject,
                                                                                                        {pointToLayer: pointToLayerProjectPlace,
                                                                                                        onEachFeature: onEachFeatureProject });*/   
/*                                                                                              console.log("here");*/
/*                                    Before change 2020/0622*/
/*                                  projectPlacesLayer.addData(geojsonProject);*/
/*                                    markers.addLayer(projectPlacesLayerCluster);*/
//editorMap.addLayer(projectPlacesLayer);
                                    });
                                    
/*     LOADING PRODUCTION UNITS                  */
       var geojsonProductionUnit = new Object();
         
        productionUnitsPlacesLayerCluster =
            L.geoJSON(false,{onEachFeature: onEachFeatureProductionUnitsCluster, pointToLayer: pointToLayerProductionUnits});
            
        getProdUnitsPlaces(geojsonProductionUnit, function(geojsonProductionUnit){
        
                productionUnitsPlacesLayerCluster.addData(geojsonProductionUnit);
                productionUnitsMarkers.addLayer(productionUnitsPlacesLayerCluster);
                //productionUnitsMarkers.addTo(editorMap);
                                                                                                        /*projectPlacesLayer = L.geoJSON(geojsonProject,
                                                                                                        {pointToLayer: pointToLayerProjectPlace,
                                                                                                        onEachFeature: onEachFeatureProject });*/   
/*                                  console.log("here");*/
        //                          productionUnitsLayer.addData(geojsonProductionUnit);
         //                         markers.addLayers(productionUnitsLayer);
                                   //editorMap.addLayer(projectPlacesLayer);
                                    });  
                   
       
        //productionUnitsPlacesLayerCluster = L.markerClusterGroup({  disableClusteringAtZoom: 5 });
        //productionUnitsPlacesLayerCluster =
         //   L.geoJSON(false,{onEachFeature: onEachFeatureProductionUnitsCluster, pointToLayer: pointToLayerProjectPlace});

                                    
/*     GET DOCUMENT PLACES                                    */
/*        console.log(getDocumentPlacesGeoJSon(getCurrentDocId()));*/
    
    if (docId != undefined) {
        console.log("Doc");
                
        documentMarkerMap = {};
        
        var documentPlacesLayer;
        documentPlacesLayer = L.markerClusterGroup({  disableClusteringAtZoom: 5 });
        documentPlacesLayer =
                                            L.geoJSON(false,
                                                    {onEachFeature: onEachFeatureDocument,
                                                     pointToLayer: pointToLayerDoc});                            
        
        getDocumentPlaces(geojsonDocument, function(geojsonDocument){
                                    console.log("There");
                                    console.log(JSON.stringify(geojsonDocument));
                                    documentPlacesLayer.addData(geojsonDocument);
                                    console.log("There 2");
          editorMap.addLayer(documentPlacesLayer);
                            
                                    /*var lat = geojsonDocument['features'][1]['geometry']['coordinates']
                                    var longitute = geojsonDocument['features'][1]['geometry']['coordinates']*/
/*                                    console.log(JSON.stringify(geojsonDocument));*/
                                    
/*                                    Span to document's places*/

                                    if (geojsonDocument['features'][0]) {
/*                                            var longitude = geojsonDocument['features'][0]['geometry']['coordinates'][1];*/
                                            
                                           var multiPointCorrdinates = []; 
                                           geojsonDocument['features'].forEach(function(e){
                                                if(e['geometry']){
                                                array = [e['geometry']['coordinates'][0][1], e['geometry']['coordinates'][0][0]]
                                                multiPointCorrdinates.push(array);
/*                                                console.log(JSON.stringify(multiPointCorrdinates));*/
                                                }
                                            }
                                           );
                                            var bounds =  new L.LatLngBounds(multiPointCorrdinates);
                                            var boundCenter = bounds.getCenter();
/*                                            var longLat = geojsonDocument['features'][0]['geometry']['coordinates'][0];*/
/*                                            console.log("Long: " + longitude);*/
/*                                            console.log("longLat: " + longLat[1]);*/
                                            /*editorMap.setView([longLat[1], longLat[0]], 10);}*/
                                            
                                            editorMap.fitBounds(bounds);
                                            if(editorMap.getZoom() > 8){
                                                editorMap.setZoom(6);
                                            }
                                            }
                                        else {var longLat = geojsonDocument['features']['geometry']['coordinates'][0];
                                                 editorMap.setView([longLat[1], longLat[0]], 10);}  
                
                /*                                var marker = L.marker([longitude, latitude], { title: "My marker" }).addTo(editorMap, true);*/
                                
                                });
                                        
                                 };   
        
        var peripleoSearchSelect = L.geoJSON(false,{onEachFeature: onEachFeatureProject,pointToLayer: pointToLayerProjectPlace});; 
        
        var geonamesLayer = L.geoJSON(false, {
                onEachFeature: onEachFeature,
                                                
                                                pointToLayer: function(feature,latlng){
                                                
                                                  label = String(feature.properties.name) // Must convert to string, .bindTooltip can't use straight 'feature.properties.attribute'
                                                  return new L.CircleMarker(latlng, {
                                                    radius: 5
                                                  }).bindTooltip(label, {permanent: true, opacity: 0.6}).openTooltip();
                                                  }});
        
  
                                    
        
    var AWMCCoastlinesMap = L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={access_token}', {
         attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
         //maxZoom: 0,
         id: 'isawnyu.map-knmctlkh',
         accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });
    
    var opentopomap = L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
         attribution: 'Kartendaten: © <a href="https://openstreetmap.org/copyright">OpenStreetMap</a>-Mitwirkende, SRTM | Kartendarstellung: © <a href="http://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
         });
         
   
        
        
        
 editorMap.on('moveend', function onMoveEnd(){
                    
                    var currentZoom = editorMap.getZoom(); 
                    console.log("Zoom: " + currentZoom);
                    if(editorMap.hasLayer(geonamesLayer) && currentZoom >8){
                                var editorMapBounds = editorMap.getBounds();
                                var east = editorMapBounds.getEast();
                                var west = editorMapBounds.getWest();
                                var south = editorMapBounds.getSouth();
                                var north = editorMapBounds.getNorth();
                                var width = editorMapBounds.getEast() - editorMapBounds.getWest();
                                var height = editorMapBounds.getNorth() - editorMapBounds.getSouth();
                                
                                var boundingBox = { east: east, west: west, north: north, south: south} ;
                                var geonamesFeatures;
                                
                                
                                
                                var geojson = new Object();
                                getGeonamesCitiesBound(east, west, north, south, geojson, function(geojson){
            /*                                    console.log("geonamesFeatures: " + JSON.stringify(geojson));*/
                                             
                                     /*var geonamesLayer = L.geoJSON(geojson, {
                                                onEachFeature: onEachFeature ,
                                                
                                                pointToLayer: function(feature,latlng){
                                                  label = String(feature.properties.name) // Must convert to string, .bindTooltip can't use straight 'feature.properties.attribute'
                                                  return new L.CircleMarker(latlng, {
                                                    radius: 1,
                                                  }).bindTooltip(label, {permanent: true, opacity: 0.4}).openTooltip();
                                                  }
                                                });   
                                     */        
                                             geonamesLayer.addData(geojson);
                                             //editorMap.addLayer(geonamesLayer);
            
                               
                                                
                                                });
                                    }
                                    /*else if(currentZoom >11){
                                        editorMap.addLayer(openStreetMap);
                                    }*/
                                    
                                    
                                    
                                    
                                    
                    

   /*                 
                    
                      var controlGeo = L.control.geonames({{
                        username: 'vrazanajao',
            //        bbox: {{east:-121, west: -123, north: 46, south: 45}}
            bbox: function () {{
                var bounds = editorMap.getBounds();
                return {{
                    east: bounds.getEast(),
                    west: bounds.getWest(),
                    north: bounds.getNorth(),
                    south: bounds.getSouth()
                             }}
                         }}
                     }});
        editorMap.addControl(controlGeo);
      */              
                });
    
 L.control.scale().addTo(editorMap);
 
$(document).on('shown.bs.tab', '#pills-places-tab', function (e) {
            editorMap.invalidateSize();
});

/*editorMap.addControl(geonamesControl, peripleoSearchControl);*/


editorMap.addLayer(allMarkersClusterGroup);

/*ADD base maps and layers*/      
        var baseMaps = {
                //"AWMC BaseMap": AWMCBaseMapMap,
               "MapBox satellite" : satelliteMap,
                "OpenStreetMap" : openStreetMap,
                "OpenTopoMap": opentopomap,
                "ESRI World Imagery" : esriMap, 
                "DARE": imperiumMap
               
    
        };
        var overlayMaps;
        if (docId === undefined){ 
            overlayMaps = {
            "Project places": projectPlacesMarkers,
            "Production units": productionUnitsMarkers,
            "AWMC Roads": AWMCRoadsMap
            /*"Geonames": geonamesLayer,
            "AWMC Coastlines": AWMCCoastlinesMap,
            "Peripleo Result": peripleoSearchSelect,
            "edit":editableLayers*/
        };}
        else 
        {overlayMaps = {
            "Document places" : documentPlacesLayer, 
            "Project places": projectPlacesLayerCluster,
            "AWMC Roads": AWMCRoadsMap
            /*"Geonames": geonamesLayer,
            "AWMC Coastlines": AWMCCoastlinesMap,
            "Peripleo Result": peripleoSearchSelect,
            "edit":editableLayers*/
        };}
        
        L.control.layers(baseMaps
        , overlayMaps
        ).addTo(editorMap);
//        editorMap.addLayer(AWMCBaseMapMap);
        
        
        
        editorMap.addLayer(openStreetMap, projectPlacesLayerCluster, productionUnitsPlacesLayerCluster);
        
        var currentPlaceCoordinates = getCurrentPlaceCoordinates();
        projectPlacesLayerCluster.eachLayer(function(layer) {
                                console.log("rrr" + layer.properties.uri);
                                if(layer.uri === currentPlaceCoordinates) {
                                            console.log(currentPlaceCoordinates);
                                    layer.openPopup();
    }});                  
                        
                         
       if(currentPlaceCoordinates !== undefined){
                                   editorMap.flyTo([JSON.parse(currentPlaceCoordinates)[1], JSON.parse(currentPlaceCoordinates)[0]], 12);    
                        };

      if(docId=== undefined){
                
                  
        var currentPlaceCoordinates = getCurrentPlaceCoordinates();
    if(currentPlaceCoordinates != undefined){
        var latLng = [JSON.parse(currentPlaceCoordinates)[1], JSON.parse(currentPlaceCoordinates)[0]];
        var currentPlaceMarker= L.icon({
                             iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-red.png",
                             shadowUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-shadow.png",
                             iconSize: [25,41], // size of the icon
                            // shadowSize:   [50, 64], // size of the shadow
                             iconAnchor:   [12, 41], // point of the icon which will correspond to marker s location
                             shadowAnchor: [12, 41],  // the same for the shadow
                             popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor
                     
                                });
                                
        L.marker(latLng, {icon: currentPlaceMarker}).addTo(editorMap);
             }       
    } //end of Undefined



$( ".projectPlacesLookUp" ).attr('autocomplete','on');

$( ".projectPlacesLookUp" ).attr('autocomplete','on');
$( ".projectPlacesLookUp" ).autocomplete({
        source: function( request, response ) {
                    
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/geo/places/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': $('#projectPlacesLookUp').val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title + " " + object.identifier,
                                                    uri: object.identifier,
                                                    placename: object.title,
                                                    longitude: object.geo_bounds.min_lon,
                                                    latitude: object.geo_bounds.min_lat,
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    //title: title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
              $("#newPlaceUri").val(ui.item.uri);
              $("#projectPlaceDetailsPreview").html("<strong>"+ ui.item.placename + "</strong> <em>" + ui.item.uri +"</uri>");
                if ($('#addProjectPlaceButtonDocPlaces').hasClass('hidden') === true) {
                                $("#addProjectPlaceButtonDocPlaces").toggleClass("hidden");
                                $("#newProjectPlaceTypeContainer").toggleClass("hidden");
                         
                            } else {
                                
                         };
           if(ui.item.latitude !== null){
             editorMap.setView([ui.item.latitude, ui.item.longitude], 8);
            }

            }
    } );

/*$( ".projectPlacesLookUp" ).each(function(i, el) {
                el = $(el);
                lookUpId = el.attr("id");
                
            el.autocomplete({

        source:
                    function( request, response ) {
                    
                    /\*var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    console.log("Search term: " +el.val())
                    *\/console.log("ElementId: " + elementId);
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/geo/places/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': el.val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /\*console.log("sucess: " + JSON.stringify(data));*\/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title + " " + object.identifier,
                                                    uri: object.identifier,
                                                    placename: object.title,
                                                    longitude: object.geo_bounds.min_lon,
                                                    latitude: object.geo_bounds.min_lat,
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    //title: title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object,
                                                    //refType : type
                                                    };
                                                   
                                        }
                                        ));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
              el.val(ui.item.label);
              console.log(ui.item.value);
              $("#newPlaceUri").val(ui.item.uri);
              $("#projectPlaceDetailsPreview").html("<strong>"+ ui.item.placename + "</strong>eeeee <em>" + ui.item.uri +"</uri>");
                if ($('#addProjectPlaceButtonDocPlaces').hasClass('hidden') === true) {
                                $("#addProjectPlaceButtonDocPlaces").toggleClass("hidden");
                                $("#newProjectPlaceTypeContainer").toggleClass("hidden");
                         
                            } else {
                                
                         };
           
             editorMap.setView([ui.item.latitude, ui.item.longitude], 8);
            

            }
    } );
    } );

*/

};/*End of if mapEditorEists*/               
 
 /********************************************    
*    Stuff for map in Places Manager  *
*********************************************
*/ 
if(document.getElementById("placeManagerMap")){
/*        console.log("div #placeManagerMap exists");*/
        
         
/*        ));*/

/*        var markers = L.markerClusterGroup();*/
        displayMap = L.map('placeManagerMap',
                {
                //minZoom: 0,
                 maxZoom: 18,
                 scrollWheelZoom: true
                }).setView([41.891775, 12.486137], 5);
        displayMap.on('mousemove',         function (e) { 
                 latLng = e.latlng.toString();
                 var lat = latLng.substring(7, latLng.indexOf(","));
                 var longt = latLng.substring(latLng.indexOf(",")+1, latLng.indexOf(")"));
                             $("#positionInfo").html("Coordinates (lat., long.): " + lat + ", " + longt + " (" + convertDMS( lat, longt ) + ")"); });
                    
            displayMap.on('click',         function (e) { 
        latLng = e.latlng.toString();
        var lat = latLng.substring(7, latLng.indexOf(","));
        var longt = latLng.substring(latLng.indexOf(",")+1, latLng.indexOf(")"));
                    $("#savedPositionInfo").html("Click to store current position: lat., long. " + lat + ", " + longt + " (" + convertDMS( lat, longt ) + ")"); });        
        
    displayMap.createPane('markerPanelRear');
    displayMap.getPane('markerPanelRear').style.zIndex = 600;
    displayMap.createPane('markerPanelBottom');
    displayMap.getPane('markerPanelBottom').style.zIndex = 610;
        
    displayMap.createPane('markerPanelTop');
    displayMap.getPane('markerPanelTop').style.zIndex = 640;    

    displayMap.createPane('markerPanelHighest');
    displayMap.getPane('markerPanelTop').style.zIndex = 647;
/*        
********************************
*          Basemaps            *
*********************************/


/*        var editorMaps = L.layerGroup([documentPlacesLayer, projectPlacesLayer, ISAWMap, ImperieumMap]);*/

        var satelliteMap = L.tileLayer.provider('MapBox', {
                id: 'mapbox.satellite',
                accessToken: 'pk.eyJ1IjoidnJhemFuYWphbyIsImEiOiJjanR0dzU5a2ExMnR5NDRsOHVsdGk2cjdoIn0.3UtNLHIkJ96HSp8qLyFZUA'
            });
                

    
        var openStreetMap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
});       

       
 
        var AWMCBaseMapMap = L.tileLayer(
            'http://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png',
            {
            attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                id: 'isawnyu.map-knmctlkh'
                //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });
         var AWMCRoadsMap = L.tileLayer(
            'http://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png',
            {
            attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                id: 'isawnyu.awmc-roads'
                //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });
/*         .addTo(editorMap); */
 
        var imperiumMap = L.tileLayer('https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
         attribution: 'Digital Atlas of the Roman Empire (DARE) project<a href="http://dare.ht.lu.se">http://dare.ht.lu.se</a> <a href="http://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>'
         //maxZoom: 0,
         //id: 'isawnyu.map-knmctlkh',
         //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });
/*         .addTo(editorMap); */
 
         mapLink = 
            '<a href="http://www.esri.com/">Esri</a>';
        wholink = 
            'i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community';
        var esriMap = L.tileLayer(
            'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: '&copy; '+mapLink+', '+wholink
           // maxZoom: 18,
            });
                /*var geojsonFeature = {
                   "type": "Feature",
                   "properties": {
                       "name": "Coors Field",
                       "amenity": "Baseball Stadium",
                       "popupContent": "This is where the Rockies play!"
                   },
                   "geometry": {
                       "type": "Point",
                       "coordinates": [-100.99404, 39.75621]
                   }
               };
/\*console.log("geojsonFeature: " + JSON.stringify(geojsonFeature));*\/
var myLayer = L.geoJSON().addTo(displayMap);
myLayer.addData(geojsonFeature);
*/

var opentopomap = L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
         attribution: 'Kartendaten: © <a href="https://openstreetmap.org/copyright">OpenStreetMap</a>-Mitwirkende, SRTM | Kartendarstellung: © <a href="http://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
         });
/*        
*********************************
*          Layer maps            *
*********************************/
/*var 
        featureCollection = {"type":"FeatureCollection","features":[{"type":"Feature","properties":{"name":"a","amenity":"a","popupContent":"a"},"geometry":{"type":"Point"}},{"type":"Feature","properties":{"name":"aItaly","amenity":"aItaly","popupContent":"a"},"geometry":{"type":"Point","coordinates":[43.296854,5.382499]}},{"type":"Feature","properties":{"name":"aPlace V","amenity":"aPlace V","popupContent":"a"},"geometry":{"type":"Point","coordinates":[12.486137,12.486137]}},{"type":"Feature","properties":{"name":"aPlace C","amenity":"aPlace C","popupContent":"a"},"geometry":{"type":"Point","coordinates":[12.486137,12.486137]}}]}
        
         var test = 
        L.geoJSON(featureCollection[0]).addTo(displayMap);   
*/        


/*        Load Project and Document places*/
        var geojsonFeatureProject;
        
        var geojsonFeatureDocument;
        var geojsonFeatureProdUnits;
   
        
/*        var geojsonProject = new Object();*/
        
        
        var geojsonDocument = new Object();
       
/*        var projectPlacesLayer = L.markerClusterGroup();*/
      
      var documentPlacesLayer;
        var url = "/geo/places/json";
        var projectGeoJSonPlaces;
        
        
        /*var requestGeoJSonProjectPlaces = new XMLHttpRequest();
        requestGeoJSonProjectPlaces.open("POST", "/geo/places/json", true);
        var xmlDoc;
        var myArr = JSON.parse(this.responseText);
        var projectPlacesLayer = 
        L.geoJSON(false,{onEachFeature: onEachFeatureProject(myArr),
                    pointToLayer: pointToLayerProjectPlace(myArr)});   
        
            requestGeoJSonProjectPlaces.onreadystatechange = function() {
                     if (requestGeoJSonProjectPlaces.readyState == 4 && requestGeoJSonProjectPlaces.status == 200) {
                      xmlDoc = requestGeoJSonProjectPlaces.responseXML;
                      //console.log(xmlDoc["places"])
                    }
                    };
        requestGeoJSonProjectPlaces.send();*/
        
       /*  $.ajax({
        type: "POST",
        dataType: 'json',
        url: "/geo/places/json",
        
        success: function (json) {
            geojsonFeatureProject = json[0];

            // to see more information about the object returned, use console.log:
/\*            console.log("geojsonFeatureProject: " + JSON.stringify(geojsonFeatureProject));*\/
            
             var projectPlacesLayer = L.geoJSON(false,
                                                                    {onEachFeature: onEachFeatureProject(),
                                                                    pointToLayer: pointToLayerProjectPlace()}
                                                                    );   
        
            
            
            
        },
        error: function(xhr, status, error){
            console.log("error in ajax: " + error);
        }
    });*/
        
        
        
            
            /*
            var geojsonProject = $.getJSON("/geo/places/json", function(json){
                    
                             
            geojsonFeatureProject = json[0]["places"];
            console.log("Features: " + JSON.stringify(geojsonFeatureProject));
            // to see more information about the object returned, use console.log:
            console.log("geojsonFeatureProject: " + JSON.stringify(geojsonFeatureProject));
            
             var projectPlacesLayer = 
        L.geoJSON(false,{onEachFeature: onEachFeatureProject(geojsonFeatureProject, ''),
                    pointToLayer: pointToLayerProjectPlace(geojsonFeatureProject, '')});   
        
            json[0]["places"];
            });*/
                 
        /*var jqxhr = $.ajax({
        type: "POST",
        dataType: 'json',   
        url: "/geo/places/json",
        
        success: function (json) {
            geojsonFeatureProject = json;

            // to see more information about the object returned, use console.log:
            console.log("geojsonFeatureProject: " + JSON.stringify(geojsonFeatureProject));
            
             var projectPlacesLayer = 
        L.geoJSON(false,{onEachFeature: onEachFeatureProject(),
                    pointToLayer: pointToLayerProjectPlace()});   
        }
    });*/
        
/*         console.log("ee" + JSON.stringify(geojsonProject));     */
        /*
        projectPlacesLayer = 
           L.geoJSON(false,{onEachFeature: onEachFeatureProject, pointToLayer: pointToLayerProjectPlace});   
      */
      
        
        
       
        
        
        var peripleoSearchSelect = L.geoJSON(false,{onEachFeature: onEachFeatureProject,pointToLayer: pointToLayerProjectPlace}); 
        
        
 /*       var documentPlacesLayer = L.geoJSON(
                    getDocumentPlacesGeoJSon(getCurrentDocId())
                    ,
                                    {
                                    onEachFeature: onEachFeatureProject,
                                    pointToLayer: pointToLayerDocumentPlace});   
 */         
/* var geonamesLayer = L.markerClusterGroup({  disableClusteringAtZoom: 5 });                                    */
        var geonamesLayer = L.geoJSON(false, {
                onEachFeature: onEachFeature,
                                                
                                                pointToLayer: function(feature,latlng){
                                                  label = String(feature.properties.name) // Must convert to string, .bindTooltip can't use straight 'feature.properties.attribute'
                                                  return new L.CircleMarker(latlng, {
                                                    radius: 1
                                                  }).bindTooltip(label, {permanent: true, opacity: 0.6}).openTooltip();
                                                  }});
                                       
             /* var geonamesLayer = L.geoJson(false, {
                                                onEachFeature: onEachFeature});                                     
                                                  */
        /* var markers = L.markerClusterGroup({  disableClusteringAtZoom: 7 });
         var geoJsonLayerCluster = L.geoJson(false, {
                    onEachFeature: onEachFeatureProjectCluster});*/
     var geojsonFeatureProject;
        var geojsonFeatureProdUnits;
    
    var clusterMarkersOptionsForPlaceManager =
            {
            showCoverageOnHover: false,
            zoomToBoundsOnClick: true,
            removeOutsideVisibleBounds: true,
            disableClusteringAtZoom: 9,
            spiderfyOnMaxZoom: true,
            maxClusterRadius: 80,
            spiderfyOnEveryZoom: true}
     
     var allMarkersClusterGroup;
      allMarkersClusterGroup= L.markerClusterGroup(
       clusterMarkersOptionsForPlaceManager
        ),
        projectPlacesMarkers = L.featureGroup.subGroup(allMarkersClusterGroup),// use `L.featureGroup.subGroup(parentGroup)` instead of `L.featureGroup()` or `L.layerGroup()`!
        productionUnitsMarkers = L.featureGroup.subGroup(allMarkersClusterGroup);
      
      
      
/*  Loading project's places'    */
         
         markerMap = {};
         tempLayerGroup = L.layerGroup();
         //projectPlacesLayerCluster = L.markerClusterGroup({  disableClusteringAtZoom: 5 });
         
         var geojsonProject = new Object();
         projectPlacesLayerCluster = L.geoJSON(false,
                {onEachFeature: onEachFeatureProjectCluster, 
                pointToLayer: pointToLayerProjectPlace});
         
         
         getProjectPlaces(geojsonProject,
                function(geojsonProject){
                /*projectPlacesLayer = L.geoJSON(geojsonProject,
                                    {pointToLayer: pointToLayerProjectPlace,
                                    onEachFeature: onEachFeatureProject });*/   
        //                projectPlacesLayer.addData(geojsonProject);
                        //displayMap.addLayer(projectPlacesLayer);
      
      
                     //  projectPlacesLayerCluster.addData(geojsonProject);
                                   
                                   //displayMap.addLayer(projectPlacesLayerCluster);
                                   //displayMap.addLayer(projectPlacesLayerCluster);
      
      
/*                         markers.addLayer(projectPlacesLayerCluster);*/
/*                         //geoJsonLayerCluster.addData(geojsonProject);*/
                         //displayMap.addLayer(projectPlacesLayerCluster);
                         
                         
                             projectPlacesLayerCluster.addData(geojsonProject);
                        projectPlacesMarkers.addLayer(projectPlacesLayerCluster);
                         projectPlacesMarkers.addTo(displayMap);
      });
         
       /*     LOADING PRODUCTION UNITS                  */
       var geojsonProductionUnit = new Object();
         
        //var productionUnitsLayer = L.geoJSON(false, {onEachFeature: onEachFeatureProductionUnitsCluster, pointToLayer: pointToLayerProductionUnits});   
        //productionUnitsLayerCluster = L.markerClusterGroup({  disableClusteringAtZoom: 5 });
        // productionUnitsLayerCluster = L.geoJSON(false,{onEachFeature: onEachFeatureProjectCluster, pointToLayer: pointToLayerProjectPlace});
        
          productionUnitsPlacesLayerCluster =
            L.geoJSON(false,{onEachFeature: onEachFeatureProductionUnitsCluster, pointToLayer: pointToLayerProductionUnits});
        getProdUnitsPlaces(geojsonProductionUnit, 
                    function(geojsonProductionUnit){
                                        /*projectPlacesLayer = L.geoJSON(geojsonProject,
                                        {pointToLayer: pointToLayerProjectPlace,
                                        onEachFeature: onEachFeatureProject });*/   
/*                                  console.log("here");*/
                                  //******productionUnitsLayerCluster.addData(geojsonProductionUnit);
                                 // productionUnitsMarkers.addLayers(productionUnitsPlacesLayerCluster);
                                 // displayMap.addLayer(productionUnitsMarkers)
                                 //* ******* */ markers.addLayers(productionUnitsLayerCluster);
                                   //editorMap.addLayer(projectPlacesLayer);
                                   productionUnitsPlacesLayerCluster.addData(geojsonProductionUnit);
                                   productionUnitsMarkers.addLayer(productionUnitsPlacesLayerCluster);
                                     productionUnitsMarkers.addTo(displayMap);
                                    });  
                   
       
       /* productionUnitsPlacesLayerCluster = L.markerClusterGroup({  disableClusteringAtZoom: 5 });
        productionUnitsPlacesLayerCluster =
            L.geoJSON(false,{onEachFeature: onEachFeatureProductionUnitsCluster, pointToLayer: pointToLayerProjectPlace});
            */
         /*getProductionUnitsPlaces(geojsonProductionUnits, function(geojsonProductionUnits){
                /\*projectPlacesLayer = L.geoJSON(geojsonProject,
                                    {pointToLayer: pointToLayerProjectPlace,
                                    onEachFeature: onEachFeatureProject });*\/   
        //                projectPlacesLayer.addData(geojsonProject);
                        //displayMap.addLayer(projectPlacesLayer);
      
      
                       productionUnitsPlacesLayerCluster.addData(geojsonProductionUnits);
                                   
                                   //displayMap.addLayer(projectPlacesLayerCluster);
                                   //displayMap.addLayer(projectPlacesLayerCluster);
      
      
                         markers.addLayer(productionUnitsPlacesLayerCluster);
                         //geoJsonLayerCluster.addData(geojsonProject);
                         displayMap.addLayer(markers);
      });
         
     */
  
  
         
        /*getDocumentPlaces(geojsonDocument, function(geojsonDocument){
                var documentPlacesLayer = L.geoJSON(geojsonDocument,
                                    {pointToLayer: pointToLayerDocumentPlace,
                                    onEachFeature: onEachFeatureDocument });   
                                    projectPlacesLayer.addData(geojsonDocument);
                                    displayMap.addLayer(documentPlacesLayer);
                                    });*/
    
    var AWMCCoastlinesMap = L.tileLayer('https://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
         attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
         //maxZoom: 0,
         id: 'isawnyu.map-knmctlkh'
         //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
         });
         
         var provinces117Shapefiles = "/places/roman-provinces/roman-provinces_117.zip";
    var romanProvinces117 = L.geoJson({ features: [] }, {
        onEachFeature: function popUp(f, l) {
            var out = [];
            if (f.properties) {
                for (var key in f.properties) {
                    out.push(key + ": " + f.properties[key]);
                }
                l.bindPopup(out.join("<br />"));
            }
            l.on({
                    'add': function () {
                        l.bringToBack();
                        l.setStyle({ fillColor: 'transparent' });
                    }
                })
        }
    })
    // .addTo(displayMap);
    
    shp(provinces117Shapefiles).then(function (data) {
        romanProvinces117.addData(data, true);
    });


   L.control.scale().addTo(displayMap);
        
        /*$.getJSON("/geo/places/json", function(json){
                        geojsonFeatureProject = json[0].places;
                        console.log("json dans FeatureProject: " + geojsonFeatureProject[1].properties.popupContent);
                        var geojsonMarkerProjectPlaces = {
                            radius: 4,
                            fillColor: "#428bca",
                            color: "#000",
                            weight: 1,
                            opacity: 1,
                            fillOpacity: 0.8
                        };
            

                        L.geoJSON(geojsonFeatureProject, {
                                    onEachFeature: onEachFeaturePatrimonium }
                                 ).addTo(displayMap);
                        });*/


        /*$.getJSON("/geo/document/{$docId}", function(json){
            
                    geojsonFeatureDocument = json[0].places;
        
                    var geojsonMarkerDocumentPlaces = {
                        radius: 8,
                        fillColor: "#7d1d20",
                        color: "#000",
                        weight: 1,
                        opacity: 1,
                        fillOpacity: 0.8
                    };
                    
        
                    L.geoJSON(geojsonFeatureDocument, {
                        pointToLayer: function (feature, latlng) {
                            return L.circleMarker(latlng, geojsonMarkerDocumentPlaces);
                        }}).addTo(displayMap);
            });
 */

            displayMap.on('moveend', function onMoveEnd(){
                    
                    var currentZoom = displayMap.getZoom(); 
                    console.log("Zoom: " + currentZoom);
                    if(displayMap.hasLayer(geonamesLayer) && currentZoom >8){
                                var editorMapBounds = displayMap.getBounds();
                                var east = editorMapBounds.getEast();
                                var west = editorMapBounds.getWest();
                                var south = editorMapBounds.getSouth();
                                var north = editorMapBounds.getNorth();
                                var width = editorMapBounds.getEast() - editorMapBounds.getWest();
                                var height = editorMapBounds.getNorth() - editorMapBounds.getSouth();
                                
                                var boundingBox = { east: east, west: west, north: north, south: south} ;
                                var geonamesFeatures;
                                
                                
                                
                                var geojson = new Object();
                                getGeonamesCitiesBound(east, west, north, south, geojson, function(geojson){
            /*                                    console.log("geonamesFeatures: " + JSON.stringify(geojson));*/
                                            
                                   /*  var geonamesZoneLayer = L.geoJSON(geojson, {
                                                onEachFeature: onEachFeature
                                                ,
                                                
                                                pointToLayer: function(feature,latlng){
                                                
                                                
                                                  label = String(feature.properties.name) // Must convert to string, .bindTooltip can't use straight 'feature.properties.attribute'
                                                  return new L.CircleMarker(latlng, {
                                                    radius: 2,
                                                  }).bindTooltip(label, {permanent: true, opacity: 0.4}).openTooltip();
                                                  }
                                                });   */
                                             
                                            
                                             geonamesLayer.addData(geojson);
/*                                             displayMap.addLayer(geonamesZoneLayer);*/
            
                               
                                                
                                                });
                                    }
                                    /*else if(currentZoom >11){
                                        editorMap.addLayer(openStreetMap);
                                    }*/
                                    
                                    
                                    
                                    
                                    
                    

   /*                 
                    
                      var controlGeo = L.control.geonames({{
                        username: 'vrazanajao',
            //        bbox: {{east:-121, west: -123, north: 46, south: 45}}
            bbox: function () {{
                var bounds = editorMap.getBounds();
                return {{
                    east: bounds.getEast(),
                    west: bounds.getWest(),
                    north: bounds.getNorth(),
                    south: bounds.getSouth()
                             }}
                         }}
                     }});
        editorMap.addControl(controlGeo);
      */              
      
                });//end of onMove
    
 
 
  $(document).on('shown.bs.tab', '#pills-places-tab', function (e) {displayMap.invalidateSize().delay(1000);});

  displayMap.addControl(geonamesControl, peripleoSearchControl);


/*
*******************************
*     LEAFLET DRAW      *
*******************************
*/
var editableLayers = new L.FeatureGroup();
    displayMap.addLayer(editableLayers);

 var MyCustomMarker = L.Icon.extend({
        options: {
            shadowUrl: null,
            iconAnchor: new L.Point(12, 12),
            iconSize: new L.Point(24, 24),
            iconUrl: 'link/to/image.png'
        }
    });
    
    var options = {
        position: 'topright',
        draw: {
            polyline: {
                shapeOptions: {
                    color: '#f357a1',
                    weight: 10
                }
            },
            polygon: {
                allowIntersection: false, // Restricts shapes to simple polygons
                drawError: {
                    color: '#e1e100', // Color the shape will turn when intersects
                    message: '<strong>Oh snap!<strong> you can\'t draw that!' // Message that will show when intersect
                },
                shapeOptions: {
                    color: '#bada55'
                }
            },
            circle: false, // Turns off this drawing tool
            rectangle: {
                shapeOptions: {
                    clickable: false
                }
            },
            marker: {
                icon: new MyCustomMarker()
            }
        },
        edit: {
            featureGroup: editableLayers, //REQUIRED!!
            remove: false
        }
    };
    
     drawnItems = L.featureGroup().addTo(displayMap);
    
    displayMap.addControl(new L.Control.Draw({
        edit: {
            featureGroup: drawnItems,
            poly: {
                allowIntersection: false
            }
        },
        draw: {
            polygon: {
                allowIntersection: false,
                showArea: true
            }
        }
    }));

    displayMap.on(L.Draw.Event.CREATED, function (event) {
        
        var layer = event.layer;

        drawnItems.addLayer(layer);
        console.log(JSON.stringify(layer.toGeoJSON()));
        addDrawnFeatureToPlace(layer.toGeoJSON());
        
        });



 displayMap.on('draw:editmove', function (e) {
            console.log("Editing marker");
         var layers = e.layers;
         layers.eachLayer(function (layer) {
             updateFeature(layer.toGeoJSON());
         });
         });

displayMap.addLayer(allMarkersClusterGroup);

/*ADD base maps and layers*/      
        var baseMaps = {
                "OpenStreetMap" : openStreetMap,
                "MapBox satellite" : satelliteMap,
                 "OpenTopoMap" : opentopomap,
//           "AWMC BaseMap": AWMCBaseMapMap,
                "AWMC Coastlines": AWMCCoastlinesMap,
                
                "DARE": imperiumMap,
           
                "ESRI World Imagery" : esriMap 
                
                
                
    
        };

        var overlayMaps = {
                "Roman provinces 117 AD": romanProvinces117,
                  "Project places": projectPlacesMarkers,
            "Production units": productionUnitsMarkers,
            //"Project places": projectPlacesLayerCluster,
            // "Production units": productionUnitsLayerCluster,
                "AWMC Roads": AWMCRoadsMap,
            "Geonames": geonamesLayer,
            
            //"Peripleo Result": peripleoSearchSelect,
            "edit":editableLayers
        };
        L.control.layers(baseMaps, overlayMaps).addTo(displayMap);
        //displayMap.addLayer(AWMCBaseMapMap);
        displayMap.addLayer(openStreetMap, projectPlacesLayerCluster, productionUnitsPlacesLayerCluster);
        
        var currentPlaceCoordinates = getCurrentPlaceCoordinates();
        if(currentPlaceCoordinates !== undefined  && currentPlaceCoordinates != ""){
                                   displayMap.flyTo([JSON.parse(currentPlaceCoordinates)[1], JSON.parse(currentPlaceCoordinates)[0]], 12);    
                        };

//console.log("I'm  HERE");

$( ".projectPlacesLookUp" ).attr('autocomplete','on');
$( ".projectPlacesLookUp" ).autocomplete({
        source: function( request, response ) {
                    
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/geo/places/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': $('#projectPlacesLookup').val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title + " " + object.identifier,
                                                    uri: object.identifier,
                                                    placename: object.title,
                                                    longitude: object.geo_bounds.min_lon,
                                                    latitude: object.geo_bounds.min_lat,
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    //title: title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
/*              $("#newPlaceUri").val(ui.item.uri);*/
              $("#projectPlaceDetailsPreview").html("<strong>"+ ui.item.placename + "</strong> <em>" + ui.item.uri +"</uri>");
              $("#selectedPlaceUri").val(ui.item.uri)
                
           
/*             editorMap.setView([ui.item.latitude, ui.item.longitude], 8);*/
            

            }
    } );
var redIcon= L.Icon.extend({
    options: {
        iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/icons/map_marker-red.png",
        iconSize: [30,35],
/*        shadowUrl: "../resources/img/map/icons/shadow.png",*/
        shadowAnchor: [8, 20],
        shadowSize: [25, 18],
/*        iconSize: [20, 25],*/
        iconAnchor: [8, 30], // horizontal puis vertical
        opacity: 1
    }
});

/*var marker;*/
$( "#editLocationButton" ).on( "click", function() {
$("#placeLocation_display").toggleClass("hidden");
    $("#placeLocation_edit").toggleClass("hidden");
var longitude = $("#placeLocationLongitudeValue").val();
  var latitude = $("#placeLocationLatitudeValue").val();
console.log("Edit location: " + longitude + " " + latitude);

/*marker = new L.Marker(e.latlng, {draggable:true});*/
marker = new L.marker([latitude, longitude], {draggable:true}, {icon: redIcon});
        editableLayers.addLayer(marker);
        
  marker.on('dragend', function (e) {
          $("#placeLocationLongitudeValue").val(marker.getLatLng().lng);
        $("#placeLocationLatitudeValue").val(marker.getLatLng().lat);

});      
        
});

};/*End of if placeManager*/               
  




function addEditionMarker(longitude, latitude){
    marker = new L.marker([longitude, latitude]);
        editableLayers.addLayer(marker);
    
    
};
 

 $( "#placesLookupInputDocPlaces" ).autocomplete({
                  source: 
                    function( request, response ) {
                    $.ajax({
                        url : 'https://peripleo.pelagios.org/peripleo/search?object_type=place',
                        dataType : 'json',
                        data : {
/*                            query: $('#placesLookupInputSemantic').val() + "*"*/
                            
                            query: $('#placesLookupInputDocPlaces').val() + "*"
                            
            
                        },
            
                        success : function(data){
                            response(
                            $.map(
                                data.items, function(object){
                                       return {
                                            label: object.title + ' (' + object.identifier + ')',
                                            prefLabel: object.title,
                                            value: object.identifier,
                                            fullObject: object
                                            };
                                   }
                                )
                              );
                        },
                        error: console.log("Erreur")
                    });
            
                  },
                  minLength: 3,
                  select: function( event, ui ) {
                        event.preventDefault();
                        $('#placesLookupInputDocPlaces').val(ui.item.label);
            

                                var src = "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F');
                                console.log( "Pleaides - url: " + "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                                 $("#placesLookupInputDocPlaces_peripleoWidget").show();
                                $("#placesLookupInputDocPlaces_peripleoWidget").attr("src", "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                                $("#newPlaceUri").val(ui.item.value);
                                
                         
                          try {
                            var geojsonFeature = {
                                    "type": "Feature",
                                    "properties": {
                                        "name": ui.item.prefLabel,
                                        "amenity": "",
                                        "popupContent": "<p><trong>" + ui.item.prefLabel + "</strong>"
                                        + "<lb/><em>URI</em>" + ui.item.identifier
                                        + "</p>"
                                    },
                                    "geometry": {
                                        "type": "Point",
                                        "coordinates": [ui.item.fullObject.geo_bounds.min_lon, ui.item.fullObject.geo_bounds.min_lat]
                                    }
                                };
                                
 
                                  console.log("Test places: " +getProjectPlacesGeoJSon());
                                
                                
                                peripleoSearchSelect = L.geoJSON(geojsonFeature, {
                                onEachFeature: onEachFeature
                                    }).addTo(editorMap);
                                editorMap.panTo(new L.LatLng(ui.item.fullObject.geo_bounds.min_lat, ui.item.fullObject.geo_bounds.min_lon));
                            console.log(ui.item.fullObject.geo_bounds.min_lon);
                          }
                          catch(error) {
                            console.error(error);
                            // expected output: ReferenceError: nonExistentFunction is not defined
                            // Note - error messages will vary depending on browser
                          };
                         
                         
                         
                          if ($('#addNewPlaceButtonDocPlaces').hasClass('hidden') === true) {
                                $("#addNewPlaceButtonDocPlaces").toggleClass("hidden");
                                $("#newPlaceTypeContainer").toggleClass("hidden");
                            } else {
                                
                         };
                                                 
                           $("#prefLabelPlace").html( ui.item.prefLabel);
                         }
                } );


$( ".peripleoLookup" ).each(function(i, el) {
                el = $(el);
                lookUpId = el.attr("id");
                
            el.autocomplete({
                  source: 
                    function( request, response ) {
                    $.ajax({
                        url : 'https://peripleo.pelagios.org/peripleo/search?object_type=place',
                        dataType : 'json',
                        data : {
/*                            query: $('#placesLookupInputSemantic').val() + "*"*/
                            query: el.val() + "*"
                            
            
                        },
            
                        success : function(data){
                            response(
                            
                            $.map(
                                       
                                data.items, function(object){
                                       return {
                            
                                            label: object.title + ' (' + object.identifier + ')',
                                            prefLabel: object.title,
                                            value: object.identifier,
                                            fullObject: object
                                            };
                                            console.log("Object keys: " + Object.keys(object));
                                   }
                                )
                              );
                        },
                        error: console.log("Erreur")
                    });
            
                  },
                  minLength: 3,
                  select: function( event, ui ) {
                        event.preventDefault();
                        el.val(ui.item.label);
                        

                        var src = "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F');
                        console.log( "Pleaides - url: " + "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                         $("#" + lookUpId + "_peripleoWidget").show();
                        $("#" + lookUpId + "_peripleoWidget").attr("src", "https://peripleo.pelagios.org/embed/" + ui.item.value.replace(/\//g, '%2F'));
                        console.log(ui.item.value);
                         if($("#" + lookUpId + "_placeURI_1_1")){$("#" + lookUpId + "_placeURI__1").val(ui.item.value)}
                         if($("#" + lookUpId + "_placeName_1_1")){$("#" + lookUpId + "_placeName__1").val(ui.item.prefLabel)}
                         
                         
                         
                         
                         try {
                            var geojsonFeature = {
                                    "type": "Feature",
                                    "properties": {
                                        "name": ui.item.prefLabel,
                                        "amenity": "",
                                        "popupContent": "This is where the Rockies play!"
                                    },
                                    "geometry": {
                                        "type": "Point",
                                        "coordinates": [ui.item.fullObject.geo_bounds.min_lat, ui.item.fullObject.geo_bounds.min_lon]
                                    }
                                };
/*                                document.getElementById('editorMap').innerHTML = "<div id='editorMap2' style='width: 100%; height: 100%;'></div>";*/
/*                                mymap.remove();*/
                                /*var mymap2 = L.map('editorMap2').setView([ui.item.fullObject.geo_bounds.min_lon, ui.item.fullObject.geo_bounds.min_lat], 4);
                                        L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ', {
                                         attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
                                         maxZoom: 10,
                                        id: 'isawnyu.map-knmctlkh',
                                        accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
                                   }).addTo(mymap2); 
 */
 /*                                 console.log("Test places: " +getProjectPlacesGeoJSon());
                                
                                
                                L.geoJSON(geojsonFeature, {
                                onEachFeature: onEachFeature
                                    }).addTo(mymap2);
                                L.geoJSON(getProjectPlacesGeoJSon(), {
                                onEachFeature: onEachFeature
                                    }).addTo(mymap2);
 */                           console.log(ui.item.fullObject.geo_bounds.min_lon);
                          }
                          catch(error) {
                            console.error(error);
                            // expected output: ReferenceError: nonExistentFunction is not defined
                            // Note - error messages will vary depending on browser
                          };
                         
                          if ($('#addNewPlaceButton').hasClass('hidden') === true) {
                                $("#addNewPlaceButton").toggleClass("hidden");
                            } else {
                                
                         };
                         
                         
                         
                         
                         
                         
                         
                         
                         /*}else{
                             console.log("else");
                             
                         }*/
                           $("#prefLabelPlace").html( ui.item.prefLabel);
                         }
                         });
                } );


 $("#placeRecordContainer").mouseover(function() {
              atlasMap.scrollWheelZoom.disable();
              atlasMap.doubleClickZoom.disable();
})
$("#placeRecordContainer").mouseout(function() {
              atlasMap.scrollWheelZoom.enable();
              atlasMap.doubleClickZoom.disable();
})
$("#atlasSearchPanel").mouseover(function() {
              atlasMap.scrollWheelZoom.disable();
              atlasMap.doubleClickZoom.disable();
})
$("#atlasSearchPanel").mouseout(function() {
              atlasMap.scrollWheelZoom.enable();
              atlasMap.doubleClickZoom.disable();
})
$("#atlasMapLegend").mouseover(function() {
              atlasMap.scrollWheelZoom.disable();
              atlasMap.doubleClickZoom.disable();})
$("#atlasMapLegend").mouseout(function() {
              atlasMap.scrollWheelZoom.enable();
              atlasMap.doubleClickZoom.disable();
})


 });/*   End of ready Function*/










var geojsonMarkerProjectPlaces = {
                radius: 4,
                fillColor: "#428bca",
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.8
            }
var geonamesMarkers = {
                radius: 4,
                fillColor: "#6a6c70",
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.8
            }


/*var patrimoniumIcon = L.icon({
    iconUrl: '$ausohnum-lib/resources/scripts/spatiumStructor/icons/icon-geo-patrimonium.png',
    iconSize: [34, 55],
    iconAnchor: [22, 94],
    popupAnchor: [-34, -55],
    shadowUrl: '',
    shadowSize: [68, 95],
    shadowAnchor: [22, 94]
});*/


function pointToLayerProjectPlace(feature) {
    let markerOptions ;
    
/*  console.log(feature.properties.placeType);*/
        var markerpane = "";
        var placeType = feature.properties.placeType;
        var coordList = feature.properties.coordList;
        var coordinatesType = feature.properties.coordinatesType;
        switch (placeType) {
                  case 'City': markerOptions = cityMarkerOptions; break;
                  
                  case "Area":
                  case 'Modern place':
                  case 'Village/Settlement':
                  case "building":
                  case "Building":
                  case "Villa":
                                      markerOptions = modernPlaceMarkerOptions; break;
                   case 'Patrimonial district':
                                              markerOptions = administrativeMarkerOptions; break;
                  
                  case 'Mining territory': markerOptions = miningTerritoryMarkerOptions ; break;
                  case 'Patrimonial supradistrict': markerOptions = supraDistrictMarkerOptions ; break;
                  case 'ousia': markerOptions = ousiaMarkerOptions; break;                                              
                  case 'Landed estate':
                  case 'estate':
                  case 'Production units':
                  case 'Forest':
                  case "Quarry": markerOptions = 
                                              productionUnitMarkerOptions;
          /*                                landedEstateCampMarkerOptions; */
                                          break;
                  case 'Workshop': markerOptions = productionUnitMarkerOptions
          /*                                markerOptions = workshopCampMarkerOptions;*/
                                          break;
                  case 'Mine': markerOptions = productionUnitMarkerOptions
          /*                                    mineCampMarkerOptions; */
                                              break;
                  
                  case 'Military camp/outpost': 
                  case "Station":     markerOptions = militaryCampMarkerOptions; break;
                  
                  case 'Roman provinces': 
                  case 'Province': 
                  case "Italic region": markerOptions = provinceMarkerOptions; 
                                                               
                                           break;
                  case "Egyptian meris": 
                  case "Egyptian nomos": markerOptions = nomosMarkerOptions; break;
                  
                  case "Ethnic region": markerOptions = ethnicRegionMarkerOptions; break;
                  case 'untyped place': markerOptions = untypedPlaceOptions; break;   
                  default: markerOptions= placeMarkerOptions; break;
          }
       
       var newLatLng = [];
       //if(coordList.includes("],"))
      //      {
                        var lngLat = feature.properties.coordList;
                        
                        coordList.coordinates.forEach(function(e){
                                                          array = [e[1], e[0]]
                                                        newLatLng.push(array);
                                                        }
                                                        );
            /*            console.log(lngLat);*/
            /*            console.log(newLatLng);*/
                         var bounds =  new L.LatLngBounds(newLatLng);
                         var boundCenter = bounds.getCenter();
            /*            console.log(feature.properties.id + " latLng = " + latlng + "Coordinates: "+ feature.geometry.coordinates + " ==> center: " + boundCenter);*/
                        
                   //Adding uris of isMadeof and other options
                        markerOptions["isMadeOf"] = feature.properties.isMadeOf;
                        markerOptions["bounds"] = bounds;
                        markerOptions["placeType"] = feature.properties.placeType;   
                         //Marker: circle or square?
                         switch (feature.properties.placeType) {
                                        case "dministrative district":
                                        case "usia"://typo on purpose to disable feature
                                                  var marker = new L.rectangle(bounds, {fillColor: "green",
                                                  weight: 0,
                                                  fillOpacity: .1
                                                  });
                                                  break;
                                        default:
                                                  var marker = new L.circleMarker(boundCenter, markerOptions);
                                                  break;
                                        };
       //     }
     //       else 
     //               {var marker = new L.circleMarker(latlng, markerOptions)};
       
            if( feature.properties.id.toString() == getCurrentPlaceUri()){marker.openPopup()};
       var formattedPlaceType;
       var productionType ="";
                            if(feature.properties.placeType) {formattedPlaceType = " (" + feature.properties.placeType + ")" }
                            if(feature.properties.productionType) {productionType =
                            "<hr/><div>Production: " + feature.properties.productionType + "</div>" } 
        /* //Adding uris of isMadeof
                        markerOptions["isMadeOf"] = feature.properties.isMadeOf;
                        markerOptions["bounds"] = bounds;
                        markerOptions["placeType"] = feature.properties.placeType;*/
            var isMadeOfSection = "";
                          if(feature.properties.isMadeOf != null){
                            if(coordinatesType == "assigned"){
                                isMadeOfSection=
                                    "<hr/><div>This place is made of " + feature.properties.isMadeOf.split(" ").length + " place(s).</div>"
                            }
                            else{
                            isMadeOfSection=
                                    "<hr/><div>This place has <strong>no proper location</strong> and is made of " + feature.properties.isMadeOf.split(" ").length + " place(s).</div>"
                                    
                                        }
                         }            
            var placeDetails =
                         "<dl><dt><strong>" + feature.properties.name + "</strong>"
                                    + formattedPlaceType +"</dt>"
                            + '<dt><span class="uri">' + feature.properties.uri +"</span></dt>"
                            
                            + productionType
                            + isMadeOfSection
                            // + "<hr/>" 
                            //+ '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">Read more...</span>'
                            + "</dl>"
 
     
               marker.bindPopup(
               placeDetails
               )
               marker.bindTooltip(placeDetails,{permanent: false,direction: 'top'})
               
               if(feature.properties.uri in markerMap) { markerMapDuplicate[feature.properties.uri] = marker;}
              
              else {markerMap[feature.properties.uri] = marker;
               }
              
              
              return marker;
      
  
 
};



function pointToLayerProductionUnits(feature) {
 var productionUnitsOptions = {};
 var placeType = feature.properties.placeType;
  var coordList = feature.properties.coordList;
/*   console.log(Object.keys( feature.properties));*/
/*    if (feature.properties.placeType == "Landed estate") {*/
 var newLatLng = [];
  //if(feature.geometry.coordinates.length > 1)
            //{
           
           var lngLat = feature.properties.coordList;
            feature.properties.coordList.coordinates.forEach(function(e){
                                            array = [e[1], e[0]]
                                            newLatLng.push(array);
                                            }
                                            );
                                            
           var bounds =  new L.LatLngBounds(newLatLng);
            var boundCenter = bounds.getCenter();
            
         //   console.log("center: " + bounds.getCenter());
          if(feature.properties.isMadeOf) {productionUnitsOptions["isMadeOf"] = feature.properties.isMadeOf;}
          productionUnitsOptions["bounds"] = bounds;
          if(feature.properties.placeType) {productionUnitsOptions["placeType"] = feature.properties.placeType;}
          
          productionUnitsOptions["icon"] = new placeIcon({ iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + feature.properties.icon});
             
          var marker = new L.marker(boundCenter,
            {pane: "markerPanelTop",
            icon: new placeIcon({ 
                iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + feature.properties.icon
            
        })});

        /*var productionType ="";
                            if(feature.properties.placeType) {placeType = " (" + feature.properties.placeType + ")" }
                            if(feature.properties.productionType) {productionType =
                            "<div>Production: " + feature.properties.productionType + "</div>" } 
          var isMadeOf;
                          if(feature.properties.isMadeOf != null){
                            isMadeOf=
                                    "<hr/><dt>This place has <strong>no proper location</strong> and is made of " + feature.properties.isMadeOf.split(" ").length + " place(s)<br/>"
                                    + "<span class='spanLink pull-right' onclick='tempLayerGroup.clearLayers()'>Remove lines</span></dt>"     
                                          }               
            var placeDetails =
                         "<dl><dt><strong>2057" + feature.properties.name + "</strong>"
                                    + placeType +"</dt>"
                            + '<dt><span class="uri">' + feature.properties.uri +"</span></dt>"
                            + "<hr/>"
                            + productionType
                            +
                            isMadeOf
                            // + "<hr/>" 
                            //+ '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">Read more...</span>'
                            + "</dl>"

            marker = marker.bindPopup(placeDetails,{keepInView: false, closeButton: true, autoClose: false, autoPan: false, closeOnClick: false });
            marker = marker.bindTooltip(placeDetails,{permanent: false,direction: 'top'});*/
            //markerMap[feature.properties.uri] = marker;   
            
            //return marker; 
   //         }
   //   else {
   //         var marker = new L.marker(latlng, {icon: new placeIcon({ 
   //         iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + feature.properties.icon
           
   //     })});
   //         }
            /*
            marker.bindPopup(placeDetails,{keepInView: false, closeButton: true, autoClose: false, autoPan: false, closeOnClick: false });
            marker.bindTooltip(placeDetails,{permanent: false,direction: 'top'});   
            */
         
         
/*         console.log(feature.properties.id);*/
     productionUnitsOptions["icon"] = new placeIcon({ iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + feature.properties.icon});
     var productionType ="";
                            if(feature.properties.placeType) {placeType = " (" + feature.properties.placeType + ")" }
                            if(feature.properties.productionType) {productionType =
                            "<hr/><div>Production: " + feature.properties.productionType + "</div>" } 
                        
     var isMadeOfSection = "";
                          if(feature.properties.isMadeOf != null){
                            isMadeOfSection=
                                    "<hr/><div>This place has no proper location and is made of " + feature.properties.isMadeOf.split(" ").length + " place(s). </div>"
                                         
                                          }   
          var placeDetails =
                         "<dl><dt><strong>" + feature.properties.name + "</strong>"
                                    + placeType +"</dt>"
                            + '<dt><span class="uri">' + feature.properties.uri +"</span></dt>"
                            + productionType
                            +
                            isMadeOfSection
                            // + "<hr/>" 
                            //+ '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">Read more...</span>'
                            + "</dl>"
 
     
                marker.bindTooltip(placeDetails,
                                                           {
                                                          permanent: false, 
                                                          direction: 'top'
                                                           });
                marker.bindPopup(placeDetails,{keepInView: false, closeButton: true, autoClose: false, autoPan: false, closeOnClick: false })
                markerMap[feature.properties.uri] = marker;
                return marker; 
        
/*  return L.marker(latlng, {icon: new placeIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + feature.properties.icon,
            
        })});
*/   /*} else{
  return new L.marker(latlng,{
    radius: 1,
    fillColor: "#1171CB",
    weight: 2,
    opacity: 1,
    color: "#CCCCCC",
    fillOpacity: 0.7
  })
  }*/
};

function pointToLayerDoc(feature, latlng) {
/*   console.log(Object.keys( feature.properties));*/
/*    if (feature.properties.placeType == "Landed estate") {*/
 var newLatLng = [];
    
  if(feature.geometry.coordinates.length > 1)
            {
            var lngLat = feature.geometry.coordinates;
            lngLat.forEach(function(e){
                                    
                                            array = [e[1], e[0]]
                                            newLatLng.push(array);
                                            }
                                            );
            console.log(newLatLng);
            var bounds =  new L.LatLngBounds(newLatLng);
            
            var boundCenter = bounds.getCenter();
            
/*            console.log("center: " + bounds.getCenter());*/
             var docPlaceMarker = new L.marker(boundCenter, {icon: new placeIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + feature.properties.icon
            
        })});
         documentMarkerMap[feature.properties.id] = docPlaceMarker;
        return docPlaceMarker; 
            }
      else {
       // console.log("NO: " + latlng);
        
         var docPlaceMarker = new L.marker(latlng, {icon: new placeIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + feature.properties.icon
            
        })});
         documentMarkerMap[feature.properties.id] = docPlaceMarker;
/*         console.log(feature.properties.id);*/
        return docPlaceMarker; 
        }
/*  return L.marker(latlng, {icon: new placeIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + feature.properties.icon,
            
        })});
*/   /*} else{
  return new L.marker(latlng,{
    radius: 1,
    fillColor: "#1171CB",
    weight: 2,
    opacity: 1,
    color: "#CCCCCC",
    fillOpacity: 0.7
  })
  }*/
};

function pointToLayerDocumentPlace(feature, latlng) {
  return new L.circleMarker(latlng,{
    radius: 5,
    fillColor: "#7d1d20",
    weight: 2,
    opacity: 1,
    color: "#CCCCCC",
    fillOpacity: 0.7
  })
};

function pointToLayerGeonamePlace(feature, latlng) {
  return new L.Marker(latlng,{
    radius: 30,
    fillColor: "#7d1d20",
    weight: 10,
    opacity: 1,
    color: "#CCCCCC",
    fillOpacity: 0.7
  })
};

function styleProjectPlace(feature) {
  return {
    fillColor: "red",
    weight: 2,
    opacity: 1,
    color: "red",
    fillOpacity: 0.7
  };
};

var placeMarkerOptions = {
    radius: 5,
    fillColor: "#ff7800",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    pane: "markerPanelBottom",
    label: "administrative district"
};
var productionUnitMarkerOptions = {
    opacity: 0,
    fillOpacity: 0,
    pane: "markerPanelHighest"
};
var cityMarkerOptions = {
    radius: 5,
    fillColor: "#1D207D",
    color: "#1D207D",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    pane: "markerPanelTop",
    label: "city"
};
var provinceMarkerOptions = {
    radius: 13,
    fillColor: "#7d1d20",
    color: "#7d1d20",
    weight: 1,
    opacity: 0.5,
    fillOpacity: 0.5,
    pane: "markerPanelRear",
    label: "province"
};
var nomosMarkerOptions = {
    radius: 11,
    fillColor: "#7d1d20",
    color: "#7d1d20",
    weight: 1,
    opacity: 0.5,
    fillOpacity: 0.5,
    pane: "markerPanelRear",
    label: "Egyptian nomos"
};
var miningTerritoryMarkerOptions = {
    radius: 10,
    fillColor: "#7d1d20",
    color: "#5e5e5e",
    weight: 3,
    opacity: 1,
    fillOpacity: 0,
    pane: "markerPanelBottom",
    label: "mining territory"
};
var supraDistrictMarkerOptions = {
    radius: 10,
    fillColor: "#7d1d20",
    color: "#7d1d20",
    weight: 3,
    opacity: 1,
    fillOpacity: 0,
    pane: "markerPanelBottom",
    label: "patrimonial supra district"
};
var modernPlaceMarkerOptions = {
    radius: 5,
    fillColor: "#E9682C",
    color: "#E9682C",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    pane: "markerPanelTop",
    label: "village, area, modern place"
};
var administrativeMarkerOptions = {
    radius: 10,
    fillColor: "#E9682C",
    color: "#323aa8",
    weight: 3,
    opacity: 1,
    fillOpacity: 0,
    pane: "markerPanelBottom",
    label: "patrimonial district"
};

var ousiaMarkerOptions = {
    radius: 8,
    fillColor: "#E9682C",
    color: "#323aa8",
    weight: 2,
    opacity: 1,
    fillOpacity: 0,
    pane: "markerPanelBottom",
    label: "ousia"
};
var ethnicRegionMarkerOptions = {
    radius: 5,
    fillColor: "#00A5F1",
    color: "#00000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    pane: "markerPanelBottom",
    label: "ethnic region"
};
var militaryCampMarkerOptions = {
    radius: 5,
    fillColor: "#207D1D",
    color: "#207D1D",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    panel: "markerPanelHighest",
    label: "military camp/outpost"
};
var landedEstateCampMarkerOptions = {
    radius: 5,
    fillColor: "#717D1D",
    color: "#000000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    pane: "markerPanelHighest",
    label: "landed estate camp"
};

var mineCampMarkerOptions = {
    radius: 5,
    fillColor: "#BC9F9C",
    color: "#000000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    pane: "markerPanelHighest",
    label: "mine camp"
};
var workshopCampMarkerOptions = {
    radius: 5,
    fillColor: "#A0D9F3",
    color: "#000000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    pane: "markerPanelHighest",
    label: "workshop camp"
};
var untypedPlaceOptions = {
    radius: 5,
    fillColor: "#f7f700",
    color: "#f7f700",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8,
    pane: "markerPanelBottom",
    label: "untyped place"
};

var productionUnitOptions = {
   panel: "markerPanelHighest"
};
var leafIcon= L.Icon.extend({
    options: {
        iconSize: [30,35],
        shadowUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-shadow.png",
        shadowAnchor: [8, 20],
        shadowSize: [25, 18],
        iconSize: [20, 25],
        iconAnchor: [8, 30], // horizontal puis vertical
    opacity: 0.2

    }
});

var greyIcon = L.Icon.extend({
    options: {
        iconUrl : "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-grey.png"
    }
}
    );    

var redIcon = L.Icon.extend({
    options: {
        iconUrl : "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-red.png"
    }
}
    );    

var blueIcon= L.Icon.extend({
    options: {
        iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-icon-2x.png",
        iconSize: [30,35],
/*        shadowUrl: "../resources/img/map/icons/shadow.png",*/
        shadowAnchor: [8, 20],
        shadowSize: [25, 18],
        iconSize: [20, 25],
        iconAnchor: [8, 30] // horizontal puis vertical
    }
});

var placeIcon = L.Icon.extend({
    options: {
        iconSize: [26,40],
        shadowSize: [26, 50],
        shadowAnchor: [13, 60],
        iconAnchor: [13, 40], // horizontal puis verticalshadowSize: [26, 12],
        popupAnchor:  [0, -40], // point from which the popup should open relative to the iconAnchor
        
        shadowUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/marker-shadow.png",
    pane: "markerPanelTop"
        
    //opacity: 0.2
    }
});

var pigIcon = new placeIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/icons-placetypes/pig.png"
            
        });
var wheatIcon = new placeIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/icons-placetypes/wheat.png",
            shadowUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/icons-placetypes/icon-shadow.png",
            opacity: 0.2
        });
var provinceIcon = new leafIcon({ 

            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-2x-red.png",
            opacity: 0.2
        }) ;
var productionUnitIcon = new leafIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-2x-grey.png"
        }) ;

var areaIcon = new leafIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-2x-violet.png"
        }) ;
var cityIcon = new leafIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-2x-yellow.png"
        }) ;
var adminIcon = new leafIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-2x-orange.png"
        }) ;
var defaultIcon = new leafIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-2x-blue.png"
        }) ;
var greyIcon = new leafIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-grey.png"
        }) ;
var raaIcon = new leafIcon({ 
            iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-red.png"
        }) ;
var redIcon= L.Icon.extend({
    options: {
        iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-red.png",
        iconSize: [30,35],
/*        shadowUrl: "../resources/img/map/icons/shadow.png",*/
        shadowAnchor: [8, 20],
        shadowSize: [25, 18],
/*        iconSize: [20, 25],*/
        iconAnchor: [8, 30], // horizontal puis vertical
        opacity: 1
    }
});

/*var markersID = {};*/
function onEachFeatureProjectCluster(feature, layer) {
if (feature){

/*                    console.log("Feature: " + feature);*/
                    // does this feature have a property named popupContent?
                   // if (feature.properties
                            //&& feature.properties.popupContent
                  //          ) {
                        var placeType = feature.properties.placeType;
                        var formattedPlaceType ="";
                        var productionType ="";
                        if(feature.properties.placeType) {formattedPlaceType = " (" + placeType + ")";}
                        if(feature.properties.productionType) {productionType ="<div>Production: " + feature.properties.productionType + "</div>" } 
                        
                        var placeDetails =
                         "<dl><dt><strong>" + feature.properties.name + "</strong>"
                                    + formattedPlaceType +"</dt>"
                            + '<dt><span class="uri">' + feature.properties.uri +"</span></dt>"
                            + "<hr/>"
                            + productionType
                            // + "<hr/>" 
                            //+ '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">Read more...</span>'
                            + "</dl>"
                           
                        
                        
                            
            if(feature.properties.uri !=getCurrentPlaceUri()){layer.bindPopup(placeDetails);}
                else {layer.bindPopup(placeDetails
/*                        feature.properties.popupCmontent.toString().replace("&lt;", "<").replace("&gt;", ">"*/
/*                        ) */
                            
                            );
                
            };
            var permanentToolip;
             if(feature.properties.uri ===getCurrentPlaceUri()){permanentToolip = true} else {permanentToolip = false}
                      
           layer.bindTooltip( placeDetails,
/*                         " " + feature.properties.popupContent, */
                                           {
                                               permanent: false, 
                                               direction: 'top'
                                           }
                                       );

                        layer.id=    feature.properties.id;
                        layer.uri =  feature.properties.uri;
                        
                        var newLatLng = [];
       if(feature.geometry.coordinates.length > 1)
            {
                        var lngLat = feature.geometry.coordinates;
                        
                        lngLat.forEach(function(e){
                                                        array = [e[1], e[0]]
                                                        newLatLng.push(array);
                                                        }
                                                        );
            /*            console.log(lngLat);*/
            /*            console.log(newLatLng);*/
                         var bounds =  new L.LatLngBounds(newLatLng);
                         var boundCenter = bounds.getCenter();
                         
                        layer.coordinates = boundCenter; 
                     }
                     else{
                          layer.coordinates =feature.geometry.coordinates;
                     }
                     var label = String(feature.properties.name);
                     var uri = String(feature.properties.uri);
                     var id = uri.toString().substring(uri.toString().lastIndexOf("/")+1);
                     var isMadeOf;
                     if(feature.properties.isMadeOf != null){
                        isMadeOf = feature.properties.isMadeOf}
                            else {isMadeOf=""}
                     
                
                layer.on('click', function (e) {
                    
                    
                        // e = event
                        surroundingBounds = markerMap[uri].getLatLng().toBounds(10);
                        //console.log(surroundingBounds);
                     var count = 0;
                     var surroundingPlaces =[];
                  /*atlasMap.eachLayer(function(layer) {
                            if (layer instanceof L.Marker) {
                                if (surroundingBounds.contains(layer.getLatLng()))
                                    console.log(Object.keys(layer).toString());
                                    
                                    count++;
                                //    surroundingPlaces.push(layer.properties.uri);
                                  
                                    
                             }
                        });*/
                   //console.log(surroundingPlaces);
                        
                        
                        
                        //var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPlaceHTML2&resource=" + encodeURIComponent(uri);
                            if($("#placeEditor").length) {
                                                    $("#placeEditor").load("/places/get-record/" + id);
                                                        if($("#placeManagerMap").length){ history.pushState(null, null,  "/edit-places/" + id);}
                                                        else {history.pushState(null, null,  "/places/" + id);}
                                                      
                                                      document.title = "Place " + " - " + id;
                                                        }
                            else if($("#mapPlaceRecord").length){
                                        if($("#placeRecordContainer").length) {$("#placeRecordContainer").removeClass("hidden");};
                                        $("#mapPlaceRecord").html("Loading...")
                                        //$("#loaderBig").show();
                                        $("#mapPlaceRecord").load("/places/get-place-record/" + id, function( ) {
                                        //$("#loaderBig").hide();
                                        /*$("#relatedPlacesListHolder").load("/places/get-related-places/" + id);
                                        $("#relatedPeopleListHolder").load("/places/get-related-people/" + id);*/
                                        });
                                //document.title = "APC Place " + " - " + id;
                         }
                         /*console.log(markerMap[uri].getLatLng());
                         console.log(isMadeOf.split(" ").length > 1);
                         console.log(" placeType=" + placeType);*/
                         //console.log(isMadeOf);
                     if(isMadeOf.split(" ").length > 0 && placeType != "Province"){
                                     /*var popup = L.popup({keepInView: true, closeButton: true, autoClose: false, autoPan: false, closeOnClick: true })
                                                     .setLatLng([markerCoordinates.lat, markerCoordinates.lng])
                                                     .setContent(markerMap[uri].getPopup().getContent())
                                                     .openOn(atlasMap);*/
                                   $(isMadeOf.split(" ")).each(function(i, IsMadeOfUri){
                                             var isMadeOfMarker = markerMap[IsMadeOfUri];
                                           
                                             var latlngs =[[markerMap[uri].getLatLng().lat, markerMap[uri].getLatLng().lng],
                                                                   isMadeOfMarker.getLatLng() ]
                                             var polyline = L.polyline(latlngs, {color: 'red', weight: 1, opacity: 0.8});
                                             tempLayerGroup.addLayer(polyline);
                                          
                                         });
                                        
                        if($("#atlasMap").length){
                        atlasMap.addLayer(tempLayerGroup);
                        if($(".removeLineControl").length ===0){
                                            L.control.removeLinesControl({position: 'topleft'}).addTo(atlasMap);
                                            }
                        }
                    
                    if($("#placeManagerMap").length){
                    displayMap.addLayer(tempLayerGroup);
                                      if($(".removeLineControl").length ===0){
                                            L.control.removeLinesControl({position: 'topleft'}).addTo(displayMap);
                                            }
}
                    
                                      
                                     }    
   
             
     });
            layer.on("mouseover", function () {
                layer.openTooltip();
        });
        layer.on("mouseout", function () {
          //layer.closeTooltip();
        });               
     
    }
    
    
};



function onEachFeatureProductionUnitsCluster(feature, layer) {
if (feature){

/*                    console.log("Feature: " + feature);*/
                    // does this feature have a property named popupContent?
                    //if (feature.properties) {
                        var placeType ="";
                        var productionType ="";
                            if(feature.properties.placeType) {placeType = " (" + feature.properties.placeType + ")" }
                            if(feature.properties.productionType) {productionType =
                            "<div>Production: " + feature.properties.productionType + "</div>" } 
                        
                        var placeDetails =
                         "<dl><dt><strong>" + feature.properties.name + "</strong>"
                                    + placeType +"</dt>"
                            + '<dt><span class="uri">' + feature.properties.uri +"</span></dt>"
                            + "<hr/>" 
                            + '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">See more...</span>'
                            + "<hr/>"
                            + productionType
                            + "</dl>"
                           
                        
                        layer.bindPopup(placeDetails
/*                        feature.properties.popupContent */
                            
                            );
                        layer.bindTooltip( placeDetails,
/*                         feature.properties.popupContent, */
                                           {
                                               permanent: false, 
                                               direction: 'top'
                                           }
                                       );

                        layer.id=    feature.properties.id;
                       
                       
                       layer.coordinates = feature.geometry.coordinates;
                        
                                      
/*/\*                        Icons*\/*/
                     /*       var iconName = feature.properties.icon;
                      
                         if (layer instanceof L.Marker) {
                            layer.setIcon(new placeIcon({ 
                               iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + iconName,
                             }));
                        }*/
                        
                        /*if (feature.properties.placeType == "province") {
                          layer.setIcon(provinceIcon);
                        }
                        else if (feature.properties.placeType == "area") {
                          layer.setIcon(areaIcon);
                        }
                        else if (feature.properties.placeType == "city") {
                          layer.setIcon(wheatIcon);
                        }
                        else if (feature.properties.placeType == "administrative") {
                          layer.setIcon(adminIcon);
                        }
                        else if (feature.properties.placeType == "Landed estate") {
                          layer.setIcon(pigIcon);
                        }
                        else 
                          layer.setIcon(defaultIcon);
                        */
                 //}
                   
                   var label = String(feature.properties.name);
                     var uri = String(feature.properties.uri);
                     var id = uri.toString().substring(uri.toString().lastIndexOf("/")+1);
                   
                   
                layer.on('click', function (e) {
                            // e = event
                            //console.log(id);
                             //var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPlaceHTML2&resource=" + encodeURIComponent(uri);
                      if($("#placeEditor").length)
                        {
                            $("#placeEditor").load("/places/get-record/" + id);
                            history.pushState(null, null,  "/places/" + id);
                            document.title = "Place " + " - " + id;
                         }
                         else if($("#mapPlaceRecord").length){
                             if($("#placeRecordContainer").length) {
                             console.log("OK");
                            $("#placeRecordContainer").removeClass("hidden");
                            };
                            $("#mapPlaceRecord").html("Loading")
                            //$("#loaderBig").show();
                             $("#mapPlaceRecord").load("/places/get-place-record/" + id,
                                    function( ) {
                                    //$("#loaderBig").hide();
                                    
                                });
                             //document.title = "APC Place " + " - " + id;
                         }
                     //    $("#collection-tree").fancytree("getTree").activateKey(uri);
                                           // layer.setIcon(new blueIcon);
                                             // this.setIcon(new redIcon);
                                              
                                             // console.log(this); 
                          });
                     
                     
    }
    
    
};


function onEachFeatureProject(feature, layer) {
if (feature){


/*                    console.log("Feature: " + feature);*/
                    // does this feature have a property named popupContent?
                    if (feature.properties && feature.properties.popupContent) {
                        layer.bindPopup(
                         feature.properties.popupContent
                          /*  "<dl><dt>" + feature.properties.name + " (" + feature.properties.placeType + ")</dt>"
                            + "</dl>"*/
                            
                            );
                        layer.bindTooltip( 
                         feature.properties.popupContent,
                            /*"<dl><dt>" + feature.properties.name + " (" + feature.properties.placeType + ")</dt>"
                            + "</dl>",*/ 
                                           {
                                               permanent: false, 
                                               direction: 'right'
                                           }
                                       );

                        layer.id=    feature.properties.id;
                        
                        
                                      
/*/\*                        Icons*\/*/
                       
/*                          layer.setIcon(greyIcon);*/
                      /*  var iconName = feature.properties.icon;
                            layer.setIcon(new placeIcon({ 
                               iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + iconName,
                             }));*/
                        
                 }
                     var label = String(feature.properties.name);
                     var uri = String(feature.properties.uri) + "#this";
                     
                                     
    }
    
                    
};

function onEachFeatureDocument(feature, layer) {
if (feature){
 var placeType = feature.properties.placeType;
                        var formattedPlaceType ="";
                        var productionType ="";
                        if(feature.properties.placeType) {formattedPlaceType = " (" + placeType + ")";}
                        if(feature.properties.productionType) {productionType ="<div>Production: " + feature.properties.productionType + "</div>" } 
                        
                        var placeDetails =
                         "<dl><dt><strong>" + feature.properties.name + "</strong>"
                                    + formattedPlaceType +"</dt>"
                            + '<dt><span class="uri">' + feature.properties.uri +"</span></dt>"
                            + "<hr/>"
                            + productionType
                            // + "<hr/>" 
                            //+ '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">Read more...</span>'
                            + "</dl>"
                           
                        

/*                    console.log("Feature: " + feature);*/
                    // does this feature have a property named popupContent?
                    
                        layer.bindPopup(placeDetails
                             //feature.properties.popupContent
                            /*"<dl><dt>" + feature.properties.name + " (" + feature.properties.placeType + ")</dt>"
                            + "<p><a href='" + feature.properties.uri + "' target='_blank'>" + feature.properties.uri + "</a><p>"
                            + "</dl>"*/
                            
                            );
                        layer.bindTooltip(placeDetails,
                        // feature.properties.popupContent,
                          /*  "<dl><dt>" + feature.properties.name + " (" + feature.properties.placeType + ")</dt>"
                            + "<p><a href='" + feature.properties.uri + "' target='_blank'>" + feature.properties.uri + "</a><p>"
                            + "</dl>",*/ 
                                           {
                                               permanent: false, 
                                               direction: 'right'
                                           }
                                       );

                        layer.id=    feature.properties.id;
                        
                        
                                      
/*/\*                        Icons*\/*/
                       
/*                          layer.setIcon(raaIcon);*/
/*                        layer.setZIndexOffset(10);*/
                 
                     var label = String(feature.properties.name);
                     var uri = String(feature.properties.uri) + "#this";
                     
                     
    }
    
    
};


function onEachFeature(feature, layer) {
/*console.log("dans EachFeature");*/
    // does this feature have a property named popupContent?
    if (feature.properties && feature.properties.popupContent) {
        layer.bindPopup(feature.properties.popupContent);
/*        layer.setIcon(myIconReplc);*/
        }
     var label = String(feature.properties.name) 
     layer.bindTooltip(label, {permanent: true, opacity: 0.5}).openTooltip();

     
};


function onEachFeatureProductionUnits(feature, layer) {
if (feature){
        
            if (feature.properties && feature.properties.popupContent) {
                layer.bindPopup(feature.properties.popupContent);
        /*        layer.setIcon(myIconReplc);*/
                };
             var label = String(feature.properties.name) 
             layer.bindTooltip(label, {permanent: false, opacity: 0.5}).openTooltip();
             layer.id=    feature.properties.id;
            /*/\*                        Icons*\/*/
                            var iconName = feature.properties.icon;
                            layer.setIcon(new placeIcon({ 
                               iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + iconName
                             }));
                        
}     
};



/*function getProjectPlacesGeoJSon()
{
        var geojsonMarkerProjectPlaces;
 
 
 $.getJSON("/geo/places/json", function(json){
            
            geojsonFeatureProject = json[0].places;
            console.log("json dans FeatureProject: " + geojsonFeatureProject[1].properties.popupContent);
            geojsonMarkerProjectPlaces = {
                radius: 4,
                fillColor: "#428bca",
                color: "#000",
                weight: 1,
                opacity: 1,
                fillOpacity: 0.8
            };
            console.log(geojsonMarkerProjectPlaces);
               

});
 return geojsonMarkerProjectPlaces;
}*/

/*function getProjectPlacesGeoJSon( projectGeoJSonPlaces ){
/\*    var url = "http://patrimonium.localhost/geo/places/json";*\/
    var url = "http://patrimonium.localhost/geo/production-units/";
    $.getJSON(url, function(geojson){
            console.log(projectGeoJSonPlaces);
            JSON.stringify(projectGeoJSonPlaces(geojson));
                         
                       });
                       }*/
                      

                       
function getDocumentPlacesGeoJSon(geojson, callback){
    
    console.log("DocId: " + getCurrentDocId());
    var url = "/geo/document/" + getCurrentDocId();
    $.getJSON(url, function(json){
            geojsonFeatureDocument = json[0];
                           callback(geojsonFeatureDocument);
                           });
        }
        
/*function getDocumentPlacesGeoJSon(docId){
    console.log("DocId: " + docId);
    var url = "/geo/document/" + docId;
    $.getJSON(url, function(json){
            return  json[0];});
}*/                       
function getProjectPlaces(geojson, callback){
/*     var url = "/geo/places/json";*/
     var url="/geo/gazetteer/all";
    /*    var url = "/geo/production-units";*/
    /*var url = "/geo/project-places/" ;*/
        $.getJSON(url, function(json){
                geojsonFeatureProject = json[0];
                           callback(geojsonFeatureProject);  
                           });
};



function getDocumentPlaces(geojson, callback){
    var docId = getCurrentDocId();
    var url2getPlaces = "/geo/document/" + docId;
    $.getJSON(url2getPlaces, function(json){
            geojsonFeatureDocument = json[0];               
             callback(geojsonFeatureDocument);  
            });
};

function getProdUnitsPlaces(geojson, callback){
/*    var url2getPlaces = "/geo/production-units" ;*/
    var url2getPlaces = "/geo/gazetteer/production-units";
    $.getJSON(url2getPlaces, function(json){
            geojsonFeatureProdUnits = json[0];               
             callback(geojsonFeatureProdUnits);  
            });
};

/*function getProductionUnitsPlaces(geojson, callback){
    var url2getPlaces = "/geo/production-units";
    
    $.getJSON(url2getPlaces, function(json){
            var clusters = L.markerClusterGroup();
            var productionUnits = L.geoJson(json, {
                     pointToLayer: function(feature, latlng) {
            var marker = L.marker(latlng);
            marker.bindPopup('Trial' + feature.properties.name);
            return marker;
            },
            onEachFeature: function (feature, layer) {
            layer.addTo(clusters);
          }
        });
        displayMap.addLayer(clusters);
      });
      
      
/\*
            
            
            
            geojsonFeatureProductionUnits = json[0];               
             callback(geojsonFeatureProductionUnits);  
                       }
                       
                       );
         *\/                
};
*/
function getGeonamesCitiesBound(east, west, north, south, geojson, callback){
var geonamesUrl = "https://secure.geonames.org/citiesJSON?north=" + north
                                                    + "&south=" + south + "&east=" + east + "&west=" + west
                                                   + "&lang=en&" + "&maxRows=100"+ "&username=vrazanajao";


    $.getJSON(geonamesUrl, function(json){
    
/*    var geojson = {};*/
    geojson["type"] = "FeatureCollection";
     geojson["features"] = [];
                        console.log("Geonames :" + JSON.stringify(json));
               
            for(var i = 0; i < json.geonames.length; i++)
                        {
                            console.log("Geonames :" + json.geonames[i].geonameId);
                            var place = json.geonames[i];//change
                            
                           var newFeature = {
                                 "type": "Feature",
                                 "geometry": {
                                   "type": "MultiPoint",
                                   "coordinates": [[parseFloat(place.lng), parseFloat(place.lat)]]
                                         },
                                 "properties": {
                                   "name": place.name,
                                   "popupContent": "<p>"
                                    + "<strong>" + place.name + "</strong><br/>"
                                    + "<span class='pullright'>Geoname ID : " + place.geonameId + "</span>"
                                    + "<br/>"
                                    + " lat. " + place.lat + "- long. " + place.lng
                                    +  "<br/>"
                                    + "<a href='http://geonames.org/" + place.geonameId + "' target='_about'><i class='glyphicon glyphicon-new-window'/>http://geonames.org/" + place.geonameId + "</a>"
                                    +"</p>"
                                 }
                               }
                         geojson['features'].push(newFeature);
                       };
                       console.log("return = " + JSON.stringify(geojson));
                       callback(geojson);  
                       }
                       
                       );
                         
}


function getAjax() {
console.log("a" );
  $.ajax({
       type: "POST",
       url: '/geo/places/json',
       async: true,
       success: function(response) {
        
        return response;
        console.log("a" + response)
        
  }});
};

/*function showGeonames(map, layer){
    layer.remove;
}*/

/*
Commented on 21/05/2019
 *
 */ 
console.log($('#xml-editor-file'));
var geonamesControl = L.control.geonames({
    //position: 'topcenter', // In addition to standard 4 corner Leaflet control layout, this will position and size from top center.
    position: 'topleft',
    geonamesSearch: 'https://secure.geonames.org/searchJSON', // Override this if using a proxy to get connection to geonames.
    geonamesPostalCodesSearch: 'https://secure.geonames.org/postalCodeSearchJSON', // Override this if using a proxy to get connection to geonames.
    username: 'vrazanajao', // Geonames account username.  Must be provided.
    maxresults: 10, // Maximum number of results to display per search.
    zoomLevel: null, // Max zoom level to zoom to for location. If null, will use the map's max zoom level.
    className: 'leaflet-geonames-icon', // Class for icon.
    workingClass: 'leaflet-geonames-icon-working', // Class for search underway.
    featureClasses: ['A', 'H', 'L', 'P', 'R', 'T', 'U', 'V'], // Feature classes to search against.  See: http://www.geonames.org/export/codes.html.
    baseQuery: 'isNameRequired=true', // The core query sent to GeoNames, later combined with other parameters above.
    showMarker: true, // Show a marker at the location the selected location.
    showPopup: true, // Show a tooltip at the selected location.
    adminCodes: {}, // Filter results by the specified admin codes mentioned in `ADMIN_CODES`. Each code can be a string or a function returning a string. `country` can be a comma-separated list of countries.
    bbox: {}, // An object in form of {east:..., west:..., north:..., south:...}, specifying the bounding box to limit the results to.
    lang: 'en', // Locale of results.
    alwaysOpen: false, // If true, search field is always visible.
    enablePostalCodes: true, // If true, use postalCodesRegex to test user provided string for a postal code.  If matches, then search against postal codes API instead.
    postalCodesRegex: POSTALCODE_REGEX_US, // Regex used for testing user provided string for a postal code.  If this test fails, the default geonames API is used instead.
    title: 'Search in Geonnames.org by location name or postcode', // Search input title value.
    placeholder: 'Enter a location name' // Search input placeholder text.
});


function searchByAjax(text, callResponse)//callback for 3rd party ajax requests
	{
		return $.ajax({
			url: 'https://peripleo.pelagios.org/peripleo/search?object_type=place',	//read comments in search.php for more information usage
			type: 'GET',
			data: {query: text},
			dataType: 'json',
			success: function(json) {
                          			 //console.log(JSON.stringify(json));
                          			     var geojson = {};
                          			     geojson["type"] = "FeatureCollection";
                                                               geojson["features"] = [];
                          		                  for(var i = 0; i < json.items.length; i++)
                                                                             {  var place = json.items[i];//change
                                                                                 console.log(JSON.stringify(place));
                                                                                var newFeature = {
                                                                                      "type": "Feature",
                                                                                      "geometry": {
                                                                                        "type": "Point",
                                                                                        "coordinates": [parseFloat(place.geo_bounds.min_lat), parseFloat(place.geo_bounds.min_lon)]
                                                                                              },
                                                                                      "properties": {
                                                                                        "name": place.title,
                                                                                        "popupContent": "<p>"
                                                                                         + "<strong>" + place.title + "</strong>"
                                                                                         + "<span class='pullright'>Pleiades ID : " + place.identifier + "</span>"
                                                                                         + "<lb/>"
                                                                                         + " lat. " + place.geo_bounds.min_lat + " - long. " + place.geo_bounds.min_lon
                                                                                         +"</p>"
                                                                                      }
                                                                                    }
                                                                              geojson['features'].push(newFeature);
                                                                              };
                                                                                console.log(JSON.stringify(geojson));
                                              			callResponse(geojson);
                                              	              }
                    		});
	};

/*Commented on 21/05/2019
 * 
 */
 var peripleoSearchControl = L.control.search({
		url: 'https://peripleo.pelagios.org/peripleo/search?object_type=place&query=',
		textPlaceholder: 'Search Peripleo',
		position: 'topleft',
		hideMarkerOnCollapse: true,
		marker: {
			icon: new L.Icon({iconUrl:'data/custom-icon.png', iconSize: [20,20]}),
			circle: {
				radius: 20,
				color: '#0a0',
				opacity: 1
			}
		}
	});





function editValue(xmlElementNickname, index, cardinality){
/*          xmlElementNickname --> used as prefix of input name
 *          index -->   index no of corresponding xml div/@type='textpart'; default = 1
 *          cardinality  --> used when a cardinality of field is > 1
 * */

        if(cardinality != null) {var card = "_" + cardinality} else{var card =""};
        console.log("card : " + card);
        console.log("Input Element Value: " + "#" +xmlElementNickname+"_display_"+ index + card);
        console.log("Input Element Input: " + "#" +xmlElementNickname+"_edit_" + index + card);
        
        var idElementValue= "#" +xmlElementNickname+"_display_"+ index + card;
        var idElementInput= "#" +xmlElementNickname+"_edit_" + index + card;
        console.log("idElementValue= " + idElementValue);
        /*console.log("idElementValue= " + idElementValue);
        console.log("idElementInput= " + idElementInput);*/
        $(idElementValue).toggleClass("xmlElementHidden");
        $(idElementInput).toggleClass("xmlElementHidden");

};


function cancelEdit(xmlElementNickname, index, originalValue, type, cardinality){
        console.log("Cancel edit")
        if(index == null) { ind =""} else {var ind = index}
        if(cardinality != null) {var card = "_" + cardinality} else{var card =""};
        var idElementDisplay= "#" +xmlElementNickname+"_display_"+ ind + card;
        var idElementEdit= "#" +xmlElementNickname+"_edit_" + ind + card;
        var elementInput= $("#" + xmlElementNickname + "_" + ind + card);
        /*console.log("idElementValue= " + idElementValue);
        console.log("idElementInput= " + idElementInput);*/
        console.log ("idElementDisplay: " + idElementDisplay);
        $(idElementDisplay).toggleClass("xmlElementHidden");
        $(idElementEdit).toggleClass("xmlElementHidden");
        if(type=='input'){
        elementInput.val(originalValue);
        elementInput.html(originalValue);
        }

};

function cancelEditLocation(){
    $("#placeLocation_display").toggleClass("hidden");
    $("#placeLocation_edit").toggleClass("hidden");
}

function addData(element,
                            placeUri,
                            input,
                            xmlElementNickname,
                            xpath,
                            contentType,
                            index,
                            topConceptId){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
console.log("contentType: " + contentType);
/*    console.log("element (normally this): " + element);*/
    var elementInput;
/*  console.log("UsRI= " + $(element).siblings().children().find('.elementWithValue').prop("tagName"));*/
/*  console.log("Textual value= " );*/

  // if(index == null) { ind =""} else {var ind = index}
  //         var elementDisplay= $("#" +inputName +"_display_" + ind.toString()+ "_" + cardinality);
  //         var elementValue= $("#" + inputName +"_value_"+ ind.toString()+ "_" + cardinality);
  //         var elementEdit= $("#" +inputName +"_edit_" + ind.toString()+ "_" + cardinality);
  //         var elementInput= $("#" +inputName + "_" + ind.toString() + "_" + cardinality);

      switch(contentType){
                      case "textNodeAndAttribute":
                            var elementGroup = $(element).parents().closest('.xmlElementGroup');
                            var elementInput =$("#" + input).find("button.elementWithValue");
/*                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input varaible: " + input);
*/                            
                            var tagName = elementInput.prop("tagName");
                          break;
                      case "attribute":
                            var elementGroup = $(element).parents().closest('.xmlElementGroup');
                            var elementInput =$("#" + input);
                                    //.find("button.elementWithValue");
                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input varaible: " + input);
                            
                            var tagName = elementInput.prop("tagName");
                            console.log("tagName: " + tagName);
                      break;
                      case "text":
                                console.log("Case text!!!!!!");
                            var elementGroup = $(element).parents().closest('.xmlElementGroup');
                            var elementInput =$("#" + input);
/*                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input : " + input);
*/                            
                            var tagName = elementInput.prop("tagName");
                          break;
                      default:
                      
/*                      var elementInput = $(element).siblings().children().find('.elementWithValue');*/
                        var elementGroup = $(element).parents().closest('.xmlElementGroup');
                        var elementAddGroup = $(element).parents().closest('.xmlElementAddItem');
                        var elementGroupId = $(elementGroup).attr('id');
                        var elementGroupAddId = $(elementAddGroup).attr('id');
                /*        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        console.log("Input: " + $("#" + elementGroupId).find('.elementWithValue').text());*/
                       elementInput = $(elementAddGroup).find('.elementWithValue');
                       
                       var tagName = elementInput.prop("tagName");
                                     console.log("tagName in Default: " + tagName)
                        var newValue = elementInput.attr('value');
                      
                        var newValueTxt =  elementInput.text().trim();
/*                        console.log("test with prop" + elementInput.prop("value");)*/
                        break;
                }//End switch(contentType)
      
      if($("#lang_" + xmlElementNickname + "_add"))
                            {
                                if($("#lang_" + xmlElementNickname + "_add option:selected"))
                                            {var lang =$("#lang_" + xmlElementNickname + "_add option:selected").text().trim();}                            
/*                                    Case there is a skosThesau DropDown*/
                                    var lang = $("#lang_" + xmlElementNickname + "_add").find("button.elementWithValue").val();
                            
                            }
      
      /*console.log("Tagname: " + tagName);
      console.log("contentType: " + contentType);*/
               switch(tagName){
                   case "BUTTON":
                      var newValue = elementInput.attr('value');
                      
                        var newValueTxt =  elementInput.text().trim();
                        console.log("NewValueTxt in button: " +newValueTxt );
                      console.log("newValue:" + newValue);
                      break;
                      
                   case "INPUT":
                            switch(contentType){
                               case "text": 
                                 newValue = elementInput.val();
                                 newValueTxt = elementInput.val();
                                 break;
                               
                               case "textNodeAndAttribute":
                                 newValue = $("#" + xmlElementNickname + "_add_attrib_" + index + "_1").val();
                                 newValueTxt = $("#" + xmlElementNickname + "_add_text_" + index + "_1").val();
/*                                 console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                                 break;
                               case "attribute":
/*                                 console.log("attribute: " +  "#" + xmlElementNickname + "_add_attrib_" + index + "_1")*/
                                 newValue = elementInput.val();
                                 
/*                                 console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                                 break;
                               default: 
                                 newValue = elementInput.val();
                                 break;
                            }
                        break;
                       
                   case "SELECT":
                      newValue = elementInput.val();
                      break;
                    case "DIV":  /*Case dropdown thesau*/
                    
                    break;
                   default:
                      newValue = elementInput.attr('value') ;
                      break;
               }
      //console.log("Value:: " + newValue);
                if (newValueTxt != "") {var valueText = newValueTxt}
                else {var valueText = elementInput.text()}
/*                console.log("newValueTxt: " + newValueTxt);*/
/*                console.log("valueText: " + valueText);*/
/*                console.log("elementInput.text(): " + elementInput.text().trim);*/
   // console.log("value textual value= " + input.text());
        var xmlData = "<xml>"
                        + "<placeUri>" + placeUri + "</placeUri>"
                        + "<inputName>" + input + "</inputName>"
                        + "<value>" + newValue + "</value>"
                        + "<valueTxt>" + valueText + "</valueTxt>"
                        + "<langNewData>" + $("#selectDropDownc21856_1_9999").val() + "</langNewData>"
                        + "<xmlElementNickname>" + xmlElementNickname + "</xmlElementNickname>"
                        + "<xpath>" + xpath + "</xpath>"
                        + "<contentType>" + contentType + "</contentType>"
                        + "<topConceptId>" + topConceptId + "</topConceptId>"
                        + "<lang>" + lang + "</lang>"
                        +"</xml>";
         console.log("xmlData = " + xmlData);

         //var input = inputName;
         //var inputId = "#" + inputName.name.toString();

         var request = new XMLHttpRequest();
         request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=addData" , true);
         /*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                    //+ "&project=" + "patrimonium" + "&xpath=" + xpath
         /*                , true);*/
         var xmlDoc;

         request.onreadystatechange = function() {


           //TODOAPPEND TO GROUP
            if (request.readyState == 4 && request.status == 200) {
                var select = elementInput;
                 xmlDoc = request.responseText;
                 $(elementGroup).replaceWith(xmlDoc);
                 $("body").css("cursor", "default");
                 $("body").css("opacity", "1");
/*                  console.log("xmlDoc: " + xmlDoc);*/
/*                 $(elementGroup).replaceWith(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')));
                 console.log("xmlDoc: " + xmlDoc);
                 var tagName = elementInput.prop("tagName");
                 switch(tagName){
                     case "BUTTON":
                        newValue2Display = elementInput.text();
                        break;
                     case "INPUT":
                        newValue2Display = elementInput.val();
                        console.log("NEW VAlUE: " + newValue2Display);
                        break;
                     case "SELECT":
                        //var el = document.getElementById(inputName.name.toString());
                        newValue2Display = elementInput.find(":selected").text();
                        break;
                     default:
                        newValue2Display = elementInput.attr('value') ;
                        break;
                 }
*/


                 //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*                 elementDisplay.toggleClass("xmlElementHidden");*/
                 //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
                 //console.log("Response : Value of xmlDoc" + xmlDoc);
                 //console.log("Id of element" + idElementValue);

                 //$(idElementValue).text(xmlDoc.xml.value)
/*                 elementEdit.toggleClass("xmlElementHidden");*/
/*                 if(inputName == "docTitle"){$("#docMainTitle").html(newValue2Display)};*/
                }

                };

         request.setRequestHeader('Content-Type', 'text/xml');

            request.send(xmlData);




};

function addItem(element, item, index){
/*          xmlElementNickname --> used as prefix of input name
 *          index -->   index no of corresponding xml div/@type='textpart'; default = 1
 *
 * */

        $(element).parents().closest(".xmlElementGroup").find('.xmlElementAddItem').toggleClass("xmlElementHidden");

};


function saveData(element,
                                resourceURI,
                                inputName_text,
                                input_name_attrib,
                                elementNickName,
                                xpath,
                                contentType,
                                index, 
                                cardinality){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

/*    console.log("Value of " + inputName.name.toString()  + ": " + $(inputName).val());*/
/*console.log("contentType" + contentType);*/
/*console.log("#" + inputName_text + "_" + index + "_" + cardinality);*/
/*console.log("#" + input_name_attrib+ "_" + index + "_" + cardinality);*/
/*var inputElementForText = $("#" + inputName_text + "_" + index + "_" + cardinality);*/
var inputElementForText = $("#" + elementNickName+ "_" + index + "_" + cardinality);
console.log("INPUT ID:   " +"#" + inputName_text + "_" + index + "_" + cardinality);
var inputElementForAttrib = $("#" + input_name_attrib+ "_" + index + "_" + cardinality);
if(index == null) { ind =""} else {var ind = index}
if(inputElementForText.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = inputElementForText.prop("tagName");
                            };
/*                    var elementGroup = $(inputElementForText).parents().closest('.xmlElementGroup');*/
                    var elementGroup = $(element).parents().closest('.xmlElementGroup');
                    
                            
        console.log("Tagnme: " + tagName);
        console.log($(elementGroup).attr('id'));
        
        var elementDisplay= $("#" +elementNickName +"_display_" + ind.toString()+ "_" + cardinality);
        var elementValue= $("#" + elementNickName +"_value_"+ ind.toString()+ "_" + cardinality);
        var elementEdit= $("#" +elementNickName +"_edit_" + ind.toString()+ "_" + cardinality);
        var elementInput= $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality);
        
        /*switch(contentType){
                      case "textNodeAndAttribute":
                        //var elementGroup = $(inputName).parents().closest('.xmlElementGroup');
                        //console.log("elementGroup: " + $(elementGroup).attr('id'));
                       //console.log("tagname loop" + tagName);
                      break;
                      
                      default:
/\*                        var tagName = elementInput.prop("tagName");*\/
                        console.log("Tganame: " + tagName);              
                        };      */        
        
             switch(tagName){
                 case "BUTTON":
                    newValue = inputElementForText.attr('value');
                    console.log("new value: " + newValue);
                    newValueTxt = inputElementForText.text().trim();
/*                    console.log("newValueTxt: " + newValueTxt + "newValue: " +newValue);*/
                    break;
                 case "INPUT": case "TEXTAREA":
                    switch(contentType){
                      case "text": 
                        newValue = elementInput.val();
                        newValueTxt = elementInput.val();  
/*                        console.log("New value in 470" + newValueTxt);*/
                      break;
                    case "textNodeAndAttribute":
                        newValue = inputElementForAttrib.val();
                        newValueTxt = inputElementForText.val();
/*                        console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                        break;
                      case "nodes":
                        newValue = inputElementForText.val();
                        newValueTxt = inputElementForText.val();
/*                        console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                        break;
                      default: 
                        newValue = elementInput.val();
/*                        console.log("In switch tagname default return: " + newValueTxt );*/
                        break;
                        }  
                    break;
                 case "SELECT":
                        switch(contentType){
                        case("textNodeAndAttribute"):
                            newValue = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').val();
                            newValueTxt = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').attr("textValue");
/*                            console.log("newValue: " + newValue );*/
/*                            console.log("newValueTxt: " + newValueTxt );*/
                          break;}
                    break; //for case select
                 default:
                    newValue = elementInput.val() ;
                    newValueTxt = elementInput.val();
                    break;
             };
             
    //console.log("Value:: " + newValue);
    //console.log("Input Id:: " + elementNickName + "_" + index + "_" + cardinality );
    var xmlData = "<xml>"
                    + "<elementNickname>" + elementNickName + "</elementNickname>"
                    + "<inputName>" + inputName_text + "</inputName>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<value>" + newValue + "</value>"
                    + "<valueTxt>" + newValueTxt + "</valueTxt>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<contentType>" + contentType + "</contentType>"
                    + "<index>" + cardinality + "</index>"
                    +"</xml>";
/*     console.log("xmlData = " + xmlData);*/

     //var input = inputName;
     //var inputId = "#" + inputName.name.toString();

     var request = new XMLHttpRequest();
/*     console.log("docURI = " + resourceURI);*/
/*     request.open("POST", "/$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=saveData", true);*/
     request.open("POST", "/getfunction/?type=stsaveData", true);
     
     
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
/*             console.log("newElement2Display: " + newElement2Display);*/
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
/*             console.log("oldValueTxt:" + oldValueTxt);*/
/*             console.log("TEST element name: " + elementInput.prop("tagName"));*/
/*             console.log("newElement2Display" + newElement2Display);*/
             var tagName = elementInput.prop("tagName");
             switch(tagName){
                 case "BUTTON":
                    newValue2Display = elementInput.text();
                    break;
                 case "INPUT":
                    switch(contentType){
                            case "text":
                               newValue2Display = elementInput.val();
/*                               console.log("NEW VAlUE in case Input: " + newValue2Display);*/
/*                               console.log("new content" + xmlString) ; */
                            break;
                            case "textNodeAndAttribute":
                                newValue = $("#" + elementNickName + "_attrib_" + index + "_" + cardinality).val();
                                newValueTxt = $("#" + elementNickName + "_text_" + index + "_" + cardinality).val();
                                newValue2Display = newValueTxt + " " + newValue;
                            break;};
                       break;
                    case "TEXTAREA":
                        newValue2Display = elementInput.val();
/*                        console.log("NEW VALUE: " + newValue2Display);*/
                        break;
                   case "SELECT":
                    //var el = document.getElementById(inputName.name.toString());
                    newValue2Display = elementInput.find(":selected").text();
                    break;
                 default:
                    newValue2Display = elementInput.attr('value') ;
                    break;
             }
/*            var xmlFile =  */


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
             
             
             /*elementValue.html(function(i,t){
                            return t.replace(oldValueTxt, newValue2Display)});*/
/*             console.log("newElement2Display: " + newElement2Display);*/
             elementGroup.html(newElement2Display);
             
/*             console.log("newValue2Display: " + newValue2Display);*/
             elementDisplay.toggleClass("xmlElementHidden");
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
             elementEdit.toggleClass("xmlElementHidden");
             if(elementNickName == "title"){$("#resourceTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
             $("body").css("cursor", "default");
             $("body").css("opacity", "1");

            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function saveDataSimple(resourceURI,
                                            inputName,
                                            xpath,
                                            contentType,
                                            index,
                                            cardinality){
/*    console.log("Value of " + inputName.name.toString()  + ": " + $(inputName).val());*/
        console.log("contentType" + contentType);
        if(index == null) { ind =""} else {var ind = index};
        var elementDisplay= $("#" +inputName +"_display_" + ind.toString()+ "_" + cardinality);
        var elementValue= $("#" + inputName +"_value_"+ ind.toString()+ "_" + cardinality);
        var elementEdit= $("#" +inputName +"_edit_" + ind.toString()+ "_" + cardinality);
        var elementInput= $("#" +inputName + "_" + ind.toString() + "_" + cardinality);
        /*
        if($(inputName).parents().closest('.xmlElementGroup')) {
                        var elementGroup = $(inputName).parents().closest('.xmlElementGroup');}
                        else {var elementGroup = $("#" + inputName + "_group_" +  ind.toString() )};
        */
        console.log("elementInput: " + $(elementInput).attr('id'));
        
        var elementGroup = $("#" + inputName + "_group_" +  ind.toString() );
        switch(contentType){
                      case "textNodeAndAttribute":
                      case "attribute":
                        //var elementGroup = $(inputName).parents().closest('.xmlElementGroup');
                        console.log("inputName: " + inputName);
                        console.log("elementInput.prop('tagName')" + elementInput.prop("tagName"));
                        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        if(elementInput.prop("tagName") === undefined || elementInput.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = elementInput.prop("tagName");
                                
                            };
                            
                      break;
                      
                      
                      default:
                        var tagName = elementInput.prop("tagName");
                        console.log("Tganame: " + tagName);              
                        }              
        console.log("tagname " + tagName);
             switch(tagName){
                 case "BUTTON":
                    newValue = elementInput.attr('value');
                    newValueTxt = elementInput.text()
                    break;
                 case "INPUT":
                    switch(contentType){
                      case "text":
                        newValue = $("#" + inputName + "_" + index + "_" + cardinality).val();
                        
                        newValueTxt = $("#" + inputName + "_" + index + "_" + cardinality).val(); 
/*                        console.log("text= " + newValueTxt + " | newValue= " + newValue);*/
                        break;
                        case "attribute":
                        newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                        
                        newValueTxt = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val(); 
                        console.log("text= " + newValueTxt + " | newValue= " + newValue);
                      break;
                      case "textNodeAndAttribute":
                        newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                        newValueTxt = $("#" + inputName + "_text_" + index + "_" + cardinality).val();
                        console.log("text= " + newValueTxt + " | attrib= " + newValue);
                        break;
                        
                      default: 
                        newValue = elementInput.val();
                        break;
                        }  
                    break;
                 case "SELECT":
                    newValue = elementInput.val();
                    newValueTxt = elementInput.val();
                    break;
                 default:
                    newValue = elementInput.val() ;
                    newValueTxt = elementInput.val();
                    break;
             }
             
    console.log("Value:: " + newValue);
    console.log("Input Id:: " + inputName + "_" + index + "_" + cardinality );
    var xmlData = "<xml>"
                    + "<elementNickname>" + inputName + "</elementNickname>"
                    + "<inputName>" + inputName + "_" + index + "_" + cardinality + "</inputName>"
                    + "<resourceURI>" + encodeURI(resourceURI) + "</resourceURI>"
                    + "<value>" + newValue + "</value>"
                    + "<valueTxt>" + newValueTxt + "</valueTxt>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<contentType>" + contentType + "</contentType>"
                    + "<index>" + cardinality + "</index>"
                    +"</xml>";
     console.log("xmlData = " + xmlData);

     //var input = inputName;
     //var inputId = "#" + inputName.name.toString();

     var request = new XMLHttpRequest();
     
/*     request.open("POST", "/$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=saveData", true);*/
     request.open("POST", "/getfunction/?type=stsaveData", true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
/*             console.log("newElement2Display: " + newElement2Display);*/
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
             
             elementIdToReplace = xmlDoc.getElementsByTagName('elementIdToReplace')[0].textContent;
             newElement = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
              newValue2Display = xmlDoc.getElementsByTagName('newValue2Display')[0].textContent;
             console.log("newElement (updated element): " + newElement);
             console.log("elementIdToReplace ="+ elementIdToReplace);
             $("#" +elementIdToReplace).html(newElement);
             
             /*console.log("elementIdToReplace:" + elementIdToReplace);
             console.log("TEST element name: " + elementInput.prop("tagName"));
             var tagName = elementInput.prop("tagName");
             switch(tagName){
                 case "BUTTON":
                    newValue2Display = elementInput.text();
                    break;
                 case "INPUT":
                    switch(contentType){
                      case "text":
                        newValue2Display = elementInput.val();
                        console.log("NEW VAlUE: " + newValue2Display);
                        
                        console.log("new content" + xmlString) ; 
                        
                        
                        break;
                      case "textNodeAndAttribute":
                          newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                          newValueTxt = $("#" + inputName + "_text_" + index + "_" + cardinality).val();
                          newValue2Display = nexValueTxt + " " + newValue;
                      break;}
                    case "TEXTAREA":
                    newValue2Display = elementInput.val();
                    console.log("NEW VAlUE: " + newValue2Display);
                    break;
                   case "SELECT":
                    //var el = document.getElementById(inputName.name.toString());
                    newValue2Display = elementInput.find(":selected").text();
                    break;
                 default:
                    newValue2Display = elementInput.attr('value') ;
                    break;
             }*/
/*            var xmlFile =  */


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
             
             /*
             elementValue.html(function(i,t){
                            return t.replace(oldValueTxt, newValue2Display)});
                            */
                            
                            
/*             elementGroup.html(newElement2Display);*/
/*             console.log("elementGroup " + elementGroup.html());*/
             //console.log("newValue2Display: " + newValue2Display);
             elementDisplay.toggleClass("xmlElementHidden");
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
             elementEdit.toggleClass("xmlElementHidden");
             if(inputName === "title"){$("#resourceTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');
        
        request.send(xmlData.toString());


};

function saveXmlFile(resourceURI){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
console.log(getXmlEditorContent());
var xmlData = "<xml>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<newContent>" + getXmlEditorContent() + "</newContent>"
                    +"</xml>";
        console.log("NEw content to be saved: " + xmlData);
     var request = new XMLHttpRequest();
     request.open("POST", "/$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=saveXmlFile", true);
     
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             newFile2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedFile')[0]);
             $("#placeEditor").html(newFile2Display);
             
             $("body").css("cursor", "default");
             $("body").css("opacity", "1");

            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function saveTextarea(resourceUri, textareaId, elementNickName, xpath, index){
    
    var no = index;
/*    console.log("Index= " + index + " *** no= " + no);*/
  var elementInput= $("#" +textareaId);  
  var newText = newValueTxt = elementInput.val().replace('<br>', '<br/>').replace('&nbsp;', ''); 
  
  var oParser = new DOMParser();
  var oDOM = oParser.parseFromString("<text>" + newText + "</text>", "text/xml");
    
    if(isParseError(oDOM)) {
            alert(getXMLError(oDOM.documentElement));
    }
    else{
    $("body").css("cursor", "wait");
console.log("newText: " + newText);
    var xmlData = "<xml>"
                    + "<inputName>" + textareaId + "</inputName>"
                    + "<resourceUri>" + resourceUri + "</resourceUri>"
                    + "<elementNickName>" + elementNickName  + "</elementNickName>"
                    + "<index>" + no + "</index>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<newText>" + newText + "</newText>"
                    +"</xml>";

    var request = new XMLHttpRequest();
    request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=saveTextarea" , true);

var xmlDoc;
var xmlDocXML;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
            refreshXmlFile(xmlString);
            $("#body").removeClass('overlap');

            $("#" + textareaId + "_message").css("display", "block");
            $("#" + textareaId + "_message").html("Text has been saved...");
            $("#" + textareaId + "_message").css('background-color', '#a8fa78');
/*            $("#" + textareaId + "_message").css('color', 'white');*/
/*            $("#messageZone").css('top', '0');*/
            $("#" + textareaId + "_message").fadeOut(3000);
/*            $("#editionAlert" + no).fadeOut(500);*/
            
/*            $("#saveTextButton" + no).fadeOut(1000);*/
/*            $("#messageZone").css("display", "none");*/


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*             $(idElementValue).html(newValue2Display);*/


/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/
            $("body").css("cursor", "default");

            } // END of (request.readyState == 4 && request.status == 200) {

        if (request.status == 400) {
            alert("Text could not be saved. \n" + "Error " + request.status + ".\n" + request.responseText);
        }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
};
};



function isParseError(parsedDocument) {
    // parser and parsererrorNS could be cached on startup for efficiency
    var parser = new DOMParser(),
        errorneousParse = parser.parseFromString('<', 'text/xml'),
        parsererrorNS = errorneousParse.getElementsByTagName("parsererror")[0].namespaceURI;

    if (parsererrorNS === 'http://www.w3.org/1999/xhtml') {
        // In PhantomJS the parseerror element doesn't seem to have a special namespace, so we are just guessing here :(
        return parsedDocument.getElementsByTagName("parsererror").length > 0;
    }

    return parsedDocument.getElementsByTagNameNS(parsererrorNS, 'parsererror').length > 0;
};


function refreshXmlFile(newContent){
    var xmlFileEditor = ace.edit("xml-editor-file");
    xmlFileEditor.setValue(newContent);
            $("#messageZone").fadeOut(1);
            $("#fileModifiedAlert" ).fadeOut(1);
            $("#saveFileButton" ).fadeOut(1);
/*             $("#body").toggleClass('overlap');*/
                $("#messageZone").css('background-color', '#8c0000');
            $("#messageZone").css('color', 'white');
    
};

function openDialog(dialogId){
    dialogElement = "#" + dialogId;
    console.log("dialogId= " + dialogId)
    $(dialogElement).modal('show');
    if (dialogId ="addSubPlace"){ $("#placeTypeSelection").val("hasInItsVincinity")}
    else if (dialogId =="addSubPlace"){$("#placeTypeSelection").val("IsInVincinityOf")}
    };
function openDialog(dialogId, option){
    dialogElement = "#" + dialogId;
    console.log("dialogId= " + dialogId)
    $(dialogElement).modal('show');
    $("#placeTypeSelection").val(option)
    
    };
 
function removeItem(resourceURI,
                                    elementNickname, 
                                    xpathBase,
                                    xpathSelector,
                                    index){
     
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<elementNickname>" + elementNickname + "</elementNickname>"
                    + "<xpathBase>" + xpathBase +"</xpathBase>"
                    + "<xpathSelector>" + xpathSelector +"</xpathSelector>"
                    + "<index>" + index +"</index>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=removeItem" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
/*             console.log("xmlDoc: " + xmlDocXml);*/
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
            newElement2Display = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedElement')[0]);
/*            $("#placeEditor").html(updatedPlace);*/
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            console.log("GoupID: " + "#" + elementNickname + "_group_1");
            console.log("updated element: " + newElement2Display)
            $("#" + elementNickname + "_group_1").html(newElement2Display);
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


 };

function removeResourceFromList(resourceURI,
                                    type, 
                                    xpathBase,
                                    xpathSelector,
                                    index){
   event.preventDefault();  
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
$("button").attr("disabled", true);
    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<type>" + type + "</type>"
                    + "<xpathBase>" + xpathBase +"</xpathBase>"
                    + "<xpathSelector>" + xpathSelector +"</xpathSelector>"
                    + "<index>" + index +"</index>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=removeResourceFromList" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
/*             console.log("xmlDoc: " + xmlDocXml);*/
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
            newElement2Display = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedElement')[0]);
/*            $("#placeEditor").html(updatedPlace);*/
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            
            console.log("updated element: " + newElement2Display)
            $("#resourcesManager" + type ).html(newElement2Display);
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
        $("button").attr("disabled", false);

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


 };
 
function removeSubPlace(element, currentPlaceUri,
                                    subPlaceUri, 
                                    placeRelationType
                                    ){
     
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<currentPlaceUri>" + currentPlaceUri + "</currentPlaceUri>"
                    + "<subPlaceUri>" + subPlaceUri + "</subPlaceUri>"
                    + "<placeRelationType>" + placeRelationType +"</placeRelationType>"
                    +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=removeSubPlace" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
/*             console.log("xmlDoc: " + xmlDocXml);*/
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
/*            $(element).parents().closest('.xmlElementGroup').remove();*/
            $("#placeEditor").html(updatedPlace);
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


 };
    
$( ".zoteroLookup" ).attr('autocomplete','on');
$( ".zoteroLookup" ).autocomplete({
      source: function( request, response ) {
        var zoteroGroup = $("#zoteroGroupNo").text();
        
        $.ajax({
            url : 'https://api.zotero.org/groups/' + zoteroGroup + '/items?',
            dataType : 'json',
            data : {
                q: $('#zoteroLookupInputModal').val()
                //types: "place"

            },

            success : function(data){
            console.log("group: " +zoteroGroup);
                console.log("sucess: " + JSON.stringify(data));
                response(
                $.map(
                    data, function(object){
                    
                           /*if(object.data.creators!=undefined) 
                                    { if(object.data.creators[0].lastName[0] != undefined)
                                            
                                            {var author = object.data.creators[0].lastName} else {var author=""};
                                    }
                                    else {var author =""};
                                     * */
                           if(typeof object.data.title!= undefined) {var title = object.data.title};

/*                           console.log("title: " + title);*/
/*                           console.log("Author: " + author);*/
/*                           console.log("ID: " + object.key);*/
                    console.log("Fulldata de Zotero: " + JSON.stringify(object.data));
                    console.log("OWLSAMEAS: " + JSON.stringify(object.data.relations["owl:sameAs"]));
                           return {
                                label: title + ' (Zotero key: ' + object.key + ')',
                                //author: author,
                                //author: object.data.creators[0].lastName,
                                date: object.data.date,
                                title: title,
                                //title: object.data.title,
                                value: object.key,
                                key: object.data.key,
                                fullData: object.data
                                };

                       }
                    )
                  );

            },
            error: console.log("Erreur")
        });

      },
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
            var zoteroGroup = $("#zoteroGroupNo").text();
            $('#zoteroLookupInputModal').val(ui.item.label);


/*              $("#selectedBiblioAuthor").html("Author: " + ui.item.fullData.creator[0].firstName + " " + ui.item.fullData.creator[0].lastName);*/
              //$("#selectedBiblioAuthor").html("Author: " + ui.item.author);
              //$("#selectedBiblioDate").html("Date: " + ui.item.fullData.date);
              $("#selectedResourceTitle").append('Title: <em>' + ui.item.title + '</em>')
              $("#selectedResourceUri").html("https://www.zotero.org/groups/"+ zoteroGroup + "/" + getCurrentProject() + "/items/itemKey/" + ui.item.value);
              $("#selectedResourceId").html(ui.item.value);
              ;

            }
    } );


function addResourceToPlace(zoteroGroup, type){
    event.preventDefault();  
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");
    $("button").attr("disabled", true);
    
/*    if($('#addResourceForm').valid() == true) { */
    
    var resourceId = $('#selectedResourceId').html();
    var citedRange = $('#citedRange').val();
    var request = new XMLHttpRequest();
    var placeUri = getCurrentPlaceUri();

    var xmlData="<xml>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    + "<zoteroGroup>" + zoteroGroup + "</zoteroGroup>"
                    + "<type>" + type + "</type>"
                    + "<resourceId>" + resourceId + "</resourceId>"
                    + "<citedRange>" + citedRange + "</citedRange>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=addResourceToPlace" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             console.log("xmlDocXML: " + JSON.stringify(xmlDocXML));
             console.log("xmlDocText: " + xmlDoc);
             responseStatus = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('status')[0]);
             console.log("responseStatus : " + responseStatus);
             
             if(responseStatus.includes("errorAlready")){
                    $("body").css("cursor", "default");
                    $("body").css("opacity", "1");
                    $("button").attr("disabled", false);
                    alert("This reference is already in your document");
                                
                    }
                 else{
                        
/*                        xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);*/
                        newContent= (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
                        /*console.log(newContent);*/
                        $("#zoteroLookupInputModal").val("")
                        $("#citedRange").val("")
                        $(".valueField").html("");
                        $("body").css("cursor", "default");
                        $("body").css("opacity", "1");
                        $("button").attr("disabled", false);
                        $('#dialogInsertResource' + type).modal('hide');
           /*            $('#mainBiblioList').html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))*/
           /*            $('#mainBiblioList').html(newBiblList);*/
/*                       console.log("New biblio list: " + newBiblList);*/
                  
                  $('#resourcesManager' + type).replaceWith(newContent);
                        //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
           
           /*             $(idElementValue).html(newValue2Display);*/
           
           
           /*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*                        refreshXmlFile(xmlString);*/
           /*             console.log("Id of element" + idElementValue);*/
                  
                 
    
                  };

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
        
};

function addResourceRef(docId, zoteroGroup, type){
    
/*    if($('#addResourceForm').valid() == true) { */
    
    var resourceId = $('#selectedResourceId').html();
    var citedRange = $('#citedRange').val();
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<docId>" + docId + "</docId>"
                    + "<zoteroGroup>" + zoteroGroup + "</zoteroGroup>"
                    + "<type>" + type + "</type>"
                    + "<resourceId>" + resourceId + "</resourceId>"
                    + "<citedRange>" + citedRange + "</citedRange>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=addResource" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             console.log("xmlDocXML: " + JSON.stringify(xmlDocXML));
             console.log("xmlDocText: " + xmlDoc);
             responseStatus = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('status')[0]);
             console.log("responseStatus : " + responseStatus);
             if(responseStatus.includes("errorAlready")){
             alert("This reference is already in your document")}
             else{
                        
                        xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
                        newBiblList= (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newBiblList')[0]);
                       $('#dialogInsertResource' + type).modal('hide');
           /*            $('#mainBiblioList').html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))*/
           /*            $('#mainBiblioList').html(newBiblList);*/
                       console.log("New biblio list: " + newBiblList);
                       $('#mainBiblioList').html(newBiblList);
                        //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
           
           /*             $(idElementValue).html(newValue2Display);*/
           
           
           /*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
                        refreshXmlFile(xmlString);
           /*             console.log("Id of element" + idElementValue);*/
                    };

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
        
/*}//End of valid form*/
/*else {console.log("Not OK")};*/
};

function changePlaceToNearTo(resourceUri, placeUri){
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");

    var xmlData="<xml>"
                    + "<resourceUri>" + resourceUri + "</resourceUri>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    +"</xml>";
     var request = new XMLHttpRequest();
     request.open("POST", "$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=changePlaceToNearTo" , true);
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             
             responseStatus = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('status')[0]);
             console.log("respoqnseStatus : " + responseStatus);
                       newContent = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
                       console.log(newContent);
                       $("#placeEditor").html(newContent);
            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
        $("body").css("opacity", "1");
        $("body").css("cursor", "default");
};

function openPlaceFromLink(uri){
 $("body").toggleClass("wait");
 var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPlaceHTML&resource=" + encodeURIComponent(uri);
    var conceptFromXqlWithURI = "/place-record/" + encodeURI(uri); 
    $("#placeEditor").load(sourceFromXql);
  var id = uri.toString().substring(uri.toString().lastIndexOf("/")).replace("#this", "");
  history.pushState(null, null,  "/places" + id);
    document.title = "Place " + " - " + id;
  $("body").removeClass("wait");
};

/*
****************************
*     Dropdown menus       *
****************************
*/
 $(function(){
$( "#content" ).on( "click", ".dropdown-menu li a", function( event ) {
    //console.log("menu: " + $(this).attr('menu'));
                  console.log("v: " + $(this).attr('value'));
                  console.log("text: " + $(this).text());
        /*        var menu = "#" + $(this).attr('id');*/
                var menu = $(this).attr('menu');
                 $(menu).html($(this).text()  + '<span class="caret"></span>');
                 $(menu).attr('value', $(this).attr('value'));
        
});
});

function selectPeripleoPlace(){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    var placeUri = $('#newPlaceUri').val();
    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<docId>" + docId + "</docId>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPeripleoPlaceDetails" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            longitude= xmlDocXml.getElementsByTagName('geo:long')[0].childNodes[0].nodeValue;
            latitude= xmlDocXml.getElementsByTagName('geo:lat')[0].childNodes[0].nodeValue;
          
          altLabels= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('altLabels')[0]);
            placeLabel= xmlDocXml.getElementsByTagName('placeLabel')[0].childNodes[0].nodeValue;
           exactMatch= xmlDocXml.getElementsByTagName('exactMatch')[0].childNodes[0].nodeValue;
          console.log("altLabels: " + altLabels);
          
          $("#dialogSearchPeripleo").modal('hide');    
           
            $("#newPlaceStandardizedNameEn").val(placeLabel);
            $("#exactMatch").val(exactMatch);
            $("#altLabelImport").replaceWith(altLabels);
            $("#latNewPlace").val(latitude);
            $("#longNewPlace").val(longitude);
            $("#geometryType").val("Point");
            $("#addPlaceButtonDocPlaces").toggleClass("hidden");
            $("#newPlaceTypeContainer").toggleClass("hidden");
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function addDrawnFeatureToPlace(geojson){
    
    var featureType = geojson.geometry.type;
console.log(featureType);
console.log(geojson);

if($("#newPlaceStandardizedNameEn").length){
            $("#geometryType").val(featureType);
                if(featureType == "Point") {
                    $("#longNewPlace").val(geojson.geometry.coordinates[0]);
                    $("#latNewPlace").val(geojson.geometry.coordinates[1]);
                } else if(featureType == "Polygon") {
                    console.log(geojson.geometry.coordinates)  
/*                    $("#geometryType").val("Polygon");*/
            var coordinates = geojson.geometry.coordinates[0].toString();
                      var firstCornerLong = coordinates.substr(0, coordinates.indexOf(','));
                      var firstCornerLat = coordinates.substr(coordinates.indexOf(',')+1, coordinates.indexOf(',', 2));
                    $("#polygonCoordinatesNewPlace").val(geojson.geometry.coordinates[0]);
                    
                }
    }//end If
if($("#placeLocationTypeValue").length){
            $("#placeLocationTypeValue").val(featureType);
                if(featureType == "Point") {
                $("#geometryType").val("POINT");
                    $("#placeLocationLongitudeValue").val(geojson.geometry.coordinates[0]);
                    $("#placeLocationLatitudeValue").val(geojson.geometry.coordinates[1]);
                } else if(featureType == "Polygon") {
                            console.log("geojson.geometry.coordinates[0]; " +geojson.geometry.coordinates[0]);
                      var coordinates = geojson.geometry.coordinates[0].toString();
                      var firstCornerLong = coordinates.substr(0, coordinates.indexOf(','));
                      var firstCornerLat = coordinates.substr(coordinates.indexOf(',')+1, coordinates.indexOf(',', 2));
                      $("#placeLocationLongitudeValue").val(firstCornerLong);
                    $("#placeLocationLatitudeValue").val(firstCornerLat);
                    $("#geometryType").val(featureType );
                    $("#polygonCoordinatesValue").val(geojson.geometry.coordinates[0]);
                    
                }
    }//end If    
    
    
    
};

function updateFeature(geojson){
    
    var featureType = geojson.geometry.type;
console.log(featureType);
console.log(geojson);
$("#featureType").val(featureType);
    if(featureType == "Point") {
        $("#placeLocationLongitudeValue").val(geojson.geometry.coordinates[0]);
        $("#placeLocationLatitudeValue").val(geojson.geometry.coordinates[1]);
    } else if(featureType == "Polygon") {
        console.log(geojson.geometry.coordinates)  
        $("#geometryType").val("Polygon");
        $("#polygonCoordinatesValue").val(geojson.geometry.coordinates[0]);
        
    }
    
    
    
    
};

function createNewPlace(){
    var coordinates= $("#polygonCoordinatesNewPlace").val();
    var longitude = $("#longNewPlace").val();
    var latitude = $("#latNewPlace").val();
    var title = $("#newPlaceStandardizedNameEn").val();
    var exactMatch= $("#exactMatch").val();
    var geometryType =$("#geometryType").val();
    var prefLabelLa = $("#prefLabelLa").val();
    var prefLabelGrc = $("#prefLabelGrc").val();
    
    /*$( ".alt" ).each(function(i, el) {
                el = $(el);
                
      });
    */
/*    var = $("").val();*/
    
    var placeType =$("#hasFeatureTypeMain_1_").val();
    var productionType=$("#productionType_1_").val();
    var request = new XMLHttpRequest();

        if(title != ""){
         if(
         (((latitude !== "") || (longitude!== "")
         ) 
           && 
           (
           latitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g)) && (longitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g))
           )==null
           )
                {alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111" );}
      else {
      if( (latitude.match(/(°|\')/g)) || (longitude.match(/(°|\')/g))){
        alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111\n"
        +"They must NOT contain ° or ' characters");
        return false;
        };
      $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        
        var xmlData="<xml>"
                    + "<title>" + title + "</title>"
                    + "<prefLabelLa>" + prefLabelLa + "</prefLabelLa>"
                    + "<prefLabelGrc>" + prefLabelGrc + "</prefLabelGrc>"
                    + "<geometryType>" + geometryType + "</geometryType>"
                    + "<coordinates>" + coordinates + "</coordinates>"
                    + "<longitude>" + longitude + "</longitude>"
                    + "<latitude>" + latitude+ "</latitude>"
                    + "<placeTypeMain>" + placeType + "</placeTypeMain>"
                    + "<productionType>" + productionType + "</productionType>"
                    + "<exactMatch>" + exactMatch + "</exactMatch>"
                    
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=createNewPlace" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
             
             
            console.log(xmlDocXml.getElementsByTagName('newHtml')[0].getElementsByTagName( 'div' )[0].childNodes);
            newHtml= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newHtml')[0]);
            newPlaceId= xmlDocXml.getElementsByTagName('newId')[0].childNodes[0].nodeValue;
            
            $("#placeEditor").html(newHtml);
              history.pushState(null, null,  "/edit-places/" + newPlaceId);
        
        
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        var tree = $("#collection-tree").fancytree("getTree");
        var newSourceOption = {
                            url: '/geo/build-tree/'};
        tree.reload(newSourceOption);
        $("#collection-tree").fancytree("getTree").activateKey(newPlaceId);
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
   }

    } else {alert("Please enter at least one standardized name in English");}

};
function createNewPlace(type){
    var coordinates= $("#polygonCoordinatesNewPlace").val();
    var longitude = $("#longNewPlace").val();
    var latitude = $("#latNewPlace").val();
    var title = $("#newPlaceStandardizedNameEn").val();
    var exactMatch= $("#exactMatch").val();
    var geometryType =$("#geometryType").val();
    var prefLabelLa = $("#prefLabelLa").val();
    var prefLabelGrc = $("#prefLabelGrc").val();
    
    /*$( ".alt" ).each(function(i, el) {
                el = $(el);
                
      });
    */
/*    var = $("").val();*/
    
    var placeType =$("#hasFeatureTypeMain_1_").val();
    var productionType=$("#productionType_1_").val();
    var request = new XMLHttpRequest();

        if(title != ""){
         if(
         (((latitude !== "") || (longitude!== "")
         ) 
           && 
           (
           latitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g)) && (longitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g))
           )==null
           )
                {alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111" );}
      else {
      if( (latitude.match(/(°|\')/g)) || (longitude.match(/(°|\')/g))){
        alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111\n"
        +"They must NOT contain ° or ' characters");
        return false;
        };
      $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        
        var xmlData="<xml>"
                    + "<type>" + type + "</type>"
                    + "<title>" + title + "</title>"
                    + "<prefLabelLa>" + prefLabelLa + "</prefLabelLa>"
                    + "<prefLabelGrc>" + prefLabelGrc + "</prefLabelGrc>"
                    + "<geometryType>" + geometryType + "</geometryType>"
                    + "<coordinates>" + coordinates + "</coordinates>"
                    + "<longitude>" + longitude + "</longitude>"
                    + "<latitude>" + latitude+ "</latitude>"
                    + "<placeTypeMain>" + placeType + "</placeTypeMain>"
                    + "<productionType>" + productionType + "</productionType>"
                    + "<exactMatch>" + exactMatch + "</exactMatch>"
                    
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=createNewPlace" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
             
             
            console.log(xmlDocXml.getElementsByTagName('newHtml')[0].getElementsByTagName( 'div' )[0].childNodes);
            newHtml= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newHtml')[0]);
            newPlaceId= xmlDocXml.getElementsByTagName('newId')[0].childNodes[0].nodeValue;
            
            $("#placeEditor").html(newHtml);
            if(type = "archaeo-manager"){history.pushState(null, null,  "/archaeo/" + newPlaceId);}
            else{history.pushState(null, null,  "/edit-places/" + newPlaceId);}
        
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        var tree = $("#collection-tree").fancytree("getTree");
        var newSourceOption = {
                            url: '/geo/build-tree/'};
        tree.reload(newSourceOption);
        $("#collection-tree").fancytree("getTree").activateKey(newPlaceId);
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
   }

    } else {alert("Please enter at least one standardized name in English");}

};
function createNewSubPlace(){
    var coordinates= $("#polygonCoordinatesNewPlace").val();
    var longitude = $("#longNewPlace").val();
    var latitude = $("#latNewPlace").val();
    var title = $("#newPlaceStandardizedNameEn").val();
    var exactMatch= $("#exactMatch").val();
    var geometryType =$("#geometryType").val();
    var prefLabelLa = $("#prefLabelLa").val();
    var prefLabelGrc = $("#prefLabelGrc").val();
    
    /*$( ".alt" ).each(function(i, el) {
                el = $(el);
                
      });
    */
/*    var = $("").val();*/
    
    var placeType =$("#hasFeatureTypeMainSubPlace_1_").val();
    var productionType=$("#productionType_1_").val();
    var request = new XMLHttpRequest();

        if(title != ""){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

var xmlData="<xml>"
                    + "<title>" + title + "</title>"
                    + "<parentPlaceUri>" + getCurrentPlaceUri() + "</parentPlaceUri>"
                    + "<prefLabelLa>" + prefLabelLa + "</prefLabelLa>"
                    + "<prefLabelGrc>" + prefLabelGrc + "</prefLabelGrc>"
                    + "<geometryType>" + geometryType + "</geometryType>"
                    + "<coordinates>" + coordinates + "</coordinates>"
                    + "<longitude>" + longitude + "</longitude>"
                    + "<latitude>" + latitude+ "</latitude>"
                    + "<placeTypeMain>" + placeType + "</placeTypeMain>"
                    + "<productionType>" + productionType + "</productionType>"
                    + "<exactMatch>" + exactMatch + "</exactMatch>"
                    
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=createNewSubPlace" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
             
             
            console.log(xmlDocXml.getElementsByTagName('newHtml')[0].getElementsByTagName( 'div' )[0].childNodes);
            newHtml= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newHtml')[0]);
            newPlaceId= xmlDocXml.getElementsByTagName('newId')[0].childNodes[0].nodeValue;
              $("#placeEditor").html(newHtml);
              history.pushState(null, null,  "/places/" + newPlaceId);
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        $("#dialogAddNewSubPlace").modal('hide');
        var tree = $("#collection-tree").fancytree("getTree");
        var newSourceOption = {
                            url: '/geo/build-tree/'};
        tree.reload(newSourceOption);
        $("#collection-tree").fancytree("getTree").activateKey(newPlaceId);
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
} else {alert("Please enter at least one standardized name in English");}

};


function addPlaceToPlace(updatedPlaceURI){
event.preventDefault();
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    var placeUri = $('#newPlaceUri').val();
    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<currentPlaceUri>" + getCurrentPlaceUri() + "</currentPlaceUri>"
                    + "<placeToBeAddedUri>" + $("#selectedPlaceUri").val() + "</placeToBeAddedUri>"
                    + "<placeRelationType>" + $("#placeTypeSelection").val() +"</placeRelationType>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=addPlaceToPlace" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
            
            
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            $("#addPlaceButtonDocPlaces").toggleClass("hidden");
            $("#newPlaceTypeContainer").toggleClass("hidden");
            $("#dialogAddSubPlace").modal('hide');
            $("#placeEditor").html(updatedPlace);
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function editLocation(longitude, latitude){
    $("#editLocationButton").click();
    /*$("#placeLocation_display").toggleClass("hidden");
    $("#placeLocation_edit").toggleClass("hidden");
    */
/*addEditionMarker(longitude, latitude);    */
    
};


function saveLocation(){
    event.preventDefault();
    var latitude = $("#placeLocationLatitudeValue").val(); 
    var longitude = $("#placeLocationLongitudeValue").val() ;
        
    if( latitude.match(/(°|\')/g) ||
     longitude.match(/(°|\')/g)){
        alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111\n"
        +"They must NOT contain ° or ' characters");
        return false;
        };
if( (latitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g)) && (longitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g))){
            
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");

    var placeUri = getCurrentPlaceUri();
    
    var request = new XMLHttpRequest();


    var xmlData=
                 "<xml>"
                    + "<type>" + $("#placeLocationTypeValue").val() + "</type>"
                    + "<longitude>" + $("#placeLocationLongitudeValue").val() + "</longitude>"
                    + "<latitude>" + $("#placeLocationLatitudeValue").val() + "</latitude>"
                    + "<coordinates>" + $("#polygonCoordinatesValue").val() + "</coordinates>"
                    + "<placeUri>" + placeUri +"</placeUri>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
       request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=updateLocation" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
       var xmlDoc;

        request.onreadystatechange = function() {
           if (request.readyState == 4 && request.status == 200) {
   /*            var el = document.getElementById(inputName.name.toString());*/
                xmlDoc = request.responseText;
                xmlDocXml = request.responseXML;
                console.log("xmlDoc: " + xmlDocXml);
   /*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
               updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
               
               $("#placeEditor").html(updatedPlace);
                /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
               $("#addPlaceButtonDocPlaces").toggleClass("hidden");
               $("#newPlaceTypeContainer").toggleClass("hidden");
               $("#dialogAddSubPlace").modal('hide');
               $("body").css("cursor", "default");
               $("body").css("opacity", "1");
               var url = window.location.href;
               if(url.includes("places")) {var newSourceOption = {
                                    url: '/geo/build-tree/'};}
               else if (url.includes("archaeo")) {var newSourceOption = {
                                    url: '/geo/build-archaeotree/'};}
               
                var tree = $("#collection-tree").fancytree("getTree");
                
                tree.reload(newSourceOption);
                $("#collection-tree").fancytree("getTree").activateKey(placeUri);

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);

} else {alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111" );}
    
};


function openBiblioDialog(){
    $('#dialogInsertBiblio').modal('show');
};

/*$( ".zoteroLookup" ).attr('autocomplete','on');*/
$( ".zoteroLookup" ).autocomplete({
        source: function( request, response ) {
                    var zoteroGroup = $("#zoteroGroupNo").text();
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        url : 'https://api.zotero.org/groups/' + zoteroGroup + '/items?',
                        dataType : 'json',
                        data : {
                                    q: $('#zoteroLookupInputModal' + type).val(),
                                    qmode: "everything"
                                    //types: "place"
                                    },
                        
                        success : function(data){
                    
                    console.log("group: " +zoteroGroup);
                            console.log("sucess: " + JSON.stringify(data));
                            response(
                            $.map(
                                data, function(object){
                                    console.log(JSON.stringify(object.data));
                                       if(object.data['creators'][0])
                                        {if(object.data.creators[0].lastName){var author = object.data.creators[0].lastName}
                                            else if (object.data.creators[0].surname){var author = object.data.creators[0].surname}
                                        }
                                        else{var author =""}
                                       if(object.data.title!='') {var title = object.data.title}
            
            /*                           console.log("title: " + title);*/
            /*                           console.log("Author: " + author);*/
            /*                           console.log("ID: " + object.key);*/
                                            console.log("Fulldata de Zotero: " + JSON.stringify(object.data));
                                            console.log("OWLSAMEAS: " + JSON.stringify(object.data.relations["owl:sameAs"]));
                                              
                                       return {
                                                    label: author + "  " + object.data.date + ", " + title + ' (Zotero key: ' + object.key + ')',
                                                    author: author,
                                                    //author: object.data.creators[0].lastName,
                                                    date: object.data.date,
                                                    title: title,
                                                    //title: object.data.title,
                                                    value: object.key,
                                                    key: object.data.key,
                                                    fullData: object.data,
                                                    refType : type
                                                    };
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
                                            console.log("refType: " + ui.item.refType); 
            var type = ui.item.refType;
            event.preventDefault();
            $('#zoteroLookupInputModal' + type).val(ui.item.label);


/*              $("#selectedBiblioAuthor").html("Author: " + ui.item.fullData.creator[0].firstName + " " + ui.item.fullData.creator[0].lastName);*/
              $("#selectedResourceAuthor" + type).html("Author: " + ui.item.author);
              $("#selectedResourceDate"+ type).html("Date: " + ui.item.fullData.date);
              $("#selectedResourceTitle"+ type).append('Title: <em>' + ui.item.title + '</em>')
              $("#selectedResourceUri"+ type).html("URI: " + ui.item.uri);
              $("#selectedResourceId"+ type).html(ui.item.value);
              ;

            }
    } );

function displayPlace(placename, uri){

    var id = uri.toString().substring(uri.toString().lastIndexOf("/")+1).replace("#this", "");
    var currentZoom = displayMap.getZoom();
    if(currentZoom > 7) { var zoom = currentZoom} else {var zoom = 9}
   /* if(lat != undefined || lng != undefined )
            { if(lat != "" || lng != "" ) {displayMap.setView([lat, lng], 12);}};*/
    //console.log(uri.replace("#this", ""));
     var regex = '#this';
     console.log("Test regec: " + uri.replace(regex, ""));
        
     var markerCoordinates = markerMap[uri.replace(regex, "")].getLatLng();
    displayMap.setView([markerCoordinates.lat, markerCoordinates.lng], zoom);
    $("#placeEditor").load("/places/get-record/" + id);
    history.pushState(null, null,  "/edit-places/" + id);
    document.title = placename + " - " + id;
    
};
function openNewPlaceForm(){
    $("#placeEditor").load("$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=newPlaceForm");
    history.pushState(null, null,  "/places/new");
    document.title = "Creation of a new place";
};

function toDegreesMinutesAndSeconds(coordinate) {
    var absolute = Math.abs(coordinate);
    var degrees = Math.floor(absolute);
    var minutesNotTruncated = (absolute - degrees) * 60;
    var minutes = Math.floor(minutesNotTruncated);
    var seconds = Math.floor((minutesNotTruncated - minutes) * 60);

    return degrees + "° " + minutes + "' " + seconds + "''";
}

function convertDMS(lat, lng) {
    var latitude = toDegreesMinutesAndSeconds(lat);
    var latitudeCardinal = lat >= 0 ? "N" : "S";

    var longitude = toDegreesMinutesAndSeconds(lng);
    var longitudeCardinal = lng >= 0 ? "E" : "W";

    return latitude + " " + latitudeCardinal + "\n" + longitude + " " + longitudeCardinal;
};

                       

function showPlaceOnMapAndDisplayRecord(uri){
        if($("#atlasMap").length){
        
        atlasMap.closePopup();
        //atlasMap.removeLayer(tempLayerGroup);
        tempLayerGroup.clearLayers()
    var id = uri.toString().substring(uri.toString().lastIndexOf("/")+1).replace("#this", "");
    var currentZoom = atlasMap.getZoom();
    if(currentZoom > 7) { var zoom = currentZoom} else {var zoom = 9}
   /* if(lat != undefined || lng != undefined )
            { if(lat != "" || lng != "" ) {displayMap.setView([lat, lng], 12);}};*/
    
     var markerCoordinates = markerMap[uri].getLatLng();
//console.log(markerMap[uri].id)

     atlasMap.setView([markerCoordinates.lat, markerCoordinates.lng], zoom);
       if($("#placeRecordContainer").length) {
                $("#placeRecordContainer").removeClass("hidden");
              };
       $("#mapPlaceRecord").load("/places/get-place-record/" + id,
                            function( ) {
                                $("#loaderBig").hide();
                                $("#mapPlaceRecord").load("/places/get-place-record/" + id);
                                //document.title = "APC Place " + id + " - " + placename;
                            });
                            
       //markerMap[uri].getPopup().openOn(atlasMap);
console.log(markerMap[uri].__parent._bounds);
/*var rectangle = new L.rectangle(markerMap[uri].__parent._bounds, {fillColor: "green",
                                                  weight: 0,
                                                  fillOpacity: .1
                                                  
                                                  }).addTo(atlasMap);*/
    if(markerMap[uri].options.isMadeOf== null || markerMap[uri].options.placeType != "Province"){
                                        var popup = L.popup({keepInView: false, closeButton: true, autoClose: false, autoPan: false, closeOnClick: false })
                                            .setLatLng([markerCoordinates.lat, markerCoordinates.lng])
                                            .setContent(markerMap[uri].getPopup().getContent())
                                            .openOn(atlasMap);
                                    }
     if(markerMap[uri].options.isMadeOf != null){
         if(markerMap[uri].options.isMadeOf.split(" ").length > 1 && markerMap[uri].options.placeType != "Province"){
            var popup = L.popup({keepInView: false, closeButton: true, autoClose: false, autoPan: false, closeOnClick: true })
                            .setLatLng([markerCoordinates.lat, markerCoordinates.lng])
                            .setContent(markerMap[uri].getPopup().getContent())
                            .openOn(atlasMap);
          $(markerMap[uri].options.isMadeOf.split(" ")).each(function(i, uri){
                    var tempMarker = markerMap[uri];
                    var latlngs =[[markerCoordinates.lat, markerCoordinates.lng],
                                          tempMarker.getLatLng()  ]
                    var polyline = L.polyline(latlngs, {color: 'red', weight: 1, opacity: 0.8});
                    tempLayerGroup.addLayer(polyline);
                    //tempClusterMarkers.addLayer(tempMarker);      
                });
             
             //var parentMarker = L.marker([markerCoordinates.lat, markerCoordinates.lng]);
              //tempClusterMarkers.addLayer(parentMarker);
              
           atlasMap.addLayer(tempLayerGroup);
              }
              }
    
    }
    else {
        window.open(uri, "_blank");
    }
};

L.Control.removeLinesControl = L.Control.extend({
              onAdd: function(map) {
                var el = L.DomUtil.create('div', 'leaflet-bar removeLineControl');
            
                el.type="button";
                el.style.border = "2px solid rgba(0,0,0,0.2)";
                el.style.padding = "2px";
                el.style.backgroundClip = "padding-box";
                el.style.color = "white";
                el.style.backgroundColor = '#7d1d20';     
                el.innerHTML = 'Remove lines';
                
                el.onclick = function(){
                      tempLayerGroup.clearLayers();
                      el.remove(atlasMap);
                          }
                return el;
              },
            
              onRemove: function(map) {
                // Nothing to do here
              }
            });
            
            L.control.removeLinesControl = function(opts) {
              return new L.Control.removeLinesControl(opts);
            }
            
function closeAtlasSearchPanel(){    $("#atlasSearchPanel").addClass("hidden");};
function closeAtlasLegendPanel(){    $("#atlasMapLegend").addClass("hidden");};            