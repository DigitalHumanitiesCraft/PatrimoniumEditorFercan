$(document).ready(function() {
    //var map = L.map("pleiadesPreviewMap");

    /* L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map); */
    
    $(".pleaidesSearchOptionButton").click(function(){
        console.log("test");
    });

    pleiadesPreviewMap.on('popupopen', function(e) {
        var marker = e.popup._source;
        console.log(marker.id);
        $("#pleaidesSearchOptionButton-" + marker.id).prop("checked", true);
      });
});


// Adapted by Tom Elliott for the Pleiades front page from 
// pleiades-static-search by Ryan F. Baumann: https://github.com/ryanfb/pleiades-static-search
(function() {
    var  append_description, append_modern_country, begins_with, geojson_embed, populate_results, search_for,
        __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };
       
     
    var markersGroup = L.featureGroup();
    console.log(pleiadesPreviewMap);
    begins_with = function(input_string, comparison_string) {
        return input_string.toUpperCase().indexOf(comparison_string.toUpperCase()) === 0;
    };

    window.pleiades_link = function(pleiades_id) {
        var link;
        link = $('<a>').attr('href', "https://pleiades.stoa.org/places/" + pleiades_id);
        link.attr('target', '_blank');
        link.text(pleiades_id);
        return link;
    };

    append_pleiades_title = function(div_id, data) {
        var sought_id = "#" + div_id;
        var sought_text = $(sought_id).text();
        var match_term = sought_text.substring(0, sought_text.indexOf(' = '));
        if (data.title != match_term && match_term.indexOf(data.title) == -1) {
            $(sought_id).append(" " + data.title);
        };
    };

    append_pleiades_types = function(div_id, data) {
        var sought_id = "#" + div_id;
        $(sought_id).text(data.placeTypes.join(', '));
    };

    append_pleiades_description = function(div_id, data) {
        var sought_id = "#" + div_id;
        $(sought_id).text(data.description);
    };

    append_pleiades_reprPoint= function(div_id, data) {
        var sought_id = "#" + div_id;
        //var map_id = "pleiadesPlaceMapPreview" + data.id;
        var reprPoint;
        if(data.reprPoint === null){reprPoint = "This place has no location"}
                                    else{reprPoint = data.reprPoint;}
        $(sought_id).text(reprPoint);
        //var map = L.map("pleiadesPreviewMap");
        console.log("id: " + data.id + " - " + JSON.stringify(data.reprPoint));
        if(data.reprPoint !== null){
            var marker = L.marker([data.reprPoint[1], data.reprPoint[0]]).addTo(markersGroup)
                .bindPopup("Pleiades " + data.id + " - " + data.title
                    +"<br/>"
                    + data.description)
                .openPopup();
                marker.id = data.id;
                markersGroup.addTo(pleiadesPreviewMap);
                //console.log(markersGroup.getBounds());
                pleiadesPreviewMap.panTo(markersGroup.getBounds().getCenter());
            }    
    };

    
    
    append_pleiades_details = function(pid) {
        return function(data) {
            append_pleiades_title('hit-' + pid, data);
            append_pleiades_types('types-' + pid, data);
            append_pleiades_description('description-' + pid, data);
            append_pleiades_reprPoint('reprPoint-' + pid, data);
        }
    };

   

    populate_results = function(results) {
        var col, i, result, row, uid, _i, _j, _len, _ref, _ref1, _results, mapdiv;
        var maps = {};
        $('#results').empty();
        markersGroup.clearLayers();
        _results = [];
        
        console.log(results.length);
        for (i = _i = 0, _ref = (results.length -1); _i <= _ref; i = _i += 1) {
            console.log(_i <= _ref);
            row = $('<div>').attr('class', 'row justify-content-center');
            result = results[i];
            console.log(i)
            col = $('<div>').attr('class', 'col-lg-12');
            uid = _.uniqueId('results-col-');
            col.attr('id', uid);
            hitele = $('<span>').attr('class', 'search-hit h4');
            hitele.attr('id', 'hit-' + result[1]);
            hitele.attr('style', 'display: inline-block;');

            hitele.text("" + (result[0].join(', ')) + " = Pleiades ").append(window.pleiades_link(result[1]));
            col.append($('<input>').attr('id', 'pleaidesSearchOptionButton-' + result[1]).attr('class', 'pleaidesSearchOptionButton').attr('type', 'radio').attr('value', result[1]).attr('name', 'selectedPlace'));
            
            col.append(hitele);
            descdiv = $('<div>').attr('class', 'search-description');
            descdiv.attr('id', 'description-' + result[1]);
            reprPointdiv = $('<div>').attr('id', 'reprPoint-' + result[1]);
            col.append(reprPointdiv);
            col.append(descdiv);
            
            row.append(col);
            $.ajax("https://pleiades.stoa.org/places/" + result[1] + "/json", {
                type: 'GET',
                dataType: 'json',
                crossDomain: true,
                error: function(jqXHR, textStatus, errorThrown) {
                    return console.log("AJAX Error: " + textStatus);
                },
                success: append_pleiades_details(result[1])
            })
            $('#results').append(row);
            _results.push($('#results'));
        }
        return _results;
    };

    search_for = function(value, index) {
        var id_url_regex, matches, name_match, name_matches, pleiades_id, unique_id, unique_ids;
        id_url_regex = /(?:https?:\/\/)?(?:pleiades\.stoa\.org\/places\/)?(\d+)\/?/;
        if (id_url_regex.test(value)) {
            pleiades_id = value.match(id_url_regex)[1];
            name_matches = index.filter(function(entry) {
                return __indexOf.call(entry.slice(1), pleiades_id) >= 0;
            });
        } else {
            name_matches = index.filter(function(entry) {
                return begins_with(entry[0], value);
            });
        }
        unique_ids = _.uniq(name_matches.map(function(match) {
            return match[1];
        }));
        matches = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = unique_ids.length; _i < _len; _i++) {
                unique_id = unique_ids[_i];
                _results.push([
                    (function() {
                        var _j, _len1, _results1;
                        _results1 = [];
                        for (_j = 0, _len1 = name_matches.length; _j < _len1; _j++) {
                            name_match = name_matches[_j];
                            if (name_match[1] === unique_id) {
                                _results1.push(name_match[0]);
                            }
                        }
                        return _results1;
                    })(), unique_id
                ]);
            }
            return _results;
        })();
        var results = matches.reverse();
        if (results.length > 0) {
            populate_results(results);
           } else {
            var search_link = '<a href="search_form?SearchableText=' + value + '*">Advanced Search</a>';
            var not_found = '<div class="row justify-content-center"><div class="col-md-8 text-center">We found zero names that start with <b>' + value + '</b> - do an ' + search_link + ' instead?';
            $('#results').html(not_found);
        }
    };

    $(document).ready(function() {

   


        return $.ajax("https://raw.githubusercontent.com/ryanfb/pleiades-geojson/gh-pages/name_index.json", {
            type: 'GET',
            dataType: 'json',
            crossDomain: true,
            error: function(jqXHR, textStatus, errorThrown) {
                return console.log("AJAX Error: " + textStatus);
            },
            success: function(data) {
                var name, names;
                names = (function() {
                    var _i, _len, _results;
                    _results = [];
                    for (_i = 0, _len = data.length; _i < _len; _i++) {
                        name = data[_i];
                        _results.push(name[0]);
                    }
                    return _results;
                    })();
                return $('#pleiadesPlacesLookup').autocomplete({
                    delay: 600,
                    minLength: 4,
                    source: function(request, response) {
                        var matches;
                        matches = names.filter(function(name) {
                            return begins_with(name, request.term);
                        });
                        return response(matches.reverse());
                    },
                    search: function(event, ui) {
                        return search_for($('#pleiadesPlacesLookup').val(), data);
                    },
                    select: function(event, ui) {
                        return search_for(ui.item.value, data);
                    }
                });
            }
        });
    });

}).call(this);

function append_pleiades_preview(pid){
    $("#previewMapDocPlaces").toggleClass("hidden");
    $("#previewMapDocPlaces").load("https://pleiades.stoa.org/places/" + pid)
};

