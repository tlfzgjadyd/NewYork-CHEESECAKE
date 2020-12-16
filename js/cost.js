function readTextFile(file) {
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function () {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status == 0)
            {
                var distance = rawFile.responseText;
                $('#receipt_text4').text(distance);
            }
        }
    };
    rawFile.send(null);
}
function initMap() {
    const bounds = new google.maps.LatLngBounds();
    const markersArray = [];
    const origin1 = { lat: 55.93, lng: -3.18 };
    const origin2 = "Greenwich,Park Row, England";
    const destinationA = "Sweden";
    const destinationB = { lat: 50.087, lng: 14.421 };
    const map = new google.maps.Map(document.getElementById("map"), {
      center: { lat: 40.6, lng: -73.9 },
      zoom: 10,
    });
    const geocoder = new google.maps.Geocoder();
    const service = new google.maps.DistanceMatrixService();
    service.getDistanceMatrix(
      {
        origins: [origin1, origin2],
        destinations: [destinationA,destinationB],
        travelMode: google.maps.TravelMode.DRIVING,
        unitSystem: google.maps.UnitSystem.METRIC,
        avoidHighways: false,
        avoidTolls: false,
      },
      (response, status) => {
        if (status !== "OK") {
          alert("Error was: " + status);
        } else {
         console.log(response)
          const originList = response.originAddresses;
          const destinationList = response.destinationAddresses;
          const outputDiv = document.getElementById("output");
          outputDiv.innerHTML = "";
          deleteMarkers(markersArray);
  
          const showGeocodedAddressOnMap = function (asDestination) {

  
            return function (results, status) {
              if (status === "OK") {
                map.fitBounds(bounds.extend(results[0].geometry.location));

              } else {
                alert("Geocode was not successful due to: " + status);
              }
            };
          };
  
          for (let i = 0; i < originList.length; i++) {
            const results = response.rows[i].elements;
            geocoder.geocode(
              { address: originList[i] },
              showGeocodedAddressOnMap(false)
            );
  
            for (let j = 0; j < results.length; j++) {
              geocoder.geocode(
                { address: destinationList[j] },
                showGeocodedAddressOnMap(true)
              );
              outputDiv.innerHTML +=
                parseFloat(results[j].distance.text).toFixed(2);
              let dist=parseFloat(results[j].distance.text).toFixed(2);
              $('#receipt_text4').attr('data-flag', dist)
            }
          }
        }
      }
    );
  }
  
  function deleteMarkers(markersArray) {
    for (let i = 0; i < markersArray.length; i++) {
      markersArray[i].setMap(null);
    }
    markersArray = [];
  }
$(document).ready(function(){
    var select_num=2;
    $('.check_group').click(function(e){
        let num=$('.check_group').index(this);
        select_num=num+1;
        let img_str="#check_image"+select_num;
        $('.check_group img').attr('src', '../images/check_before.png');
        $(img_str).attr('src', '../images/check_after.png');
    })
    $('#play_btn').click(function(){
        $('#receipt_text4').text($('#receipt_text4').attr('data-flag'))
        let starting_point=$('#start_place_text').val();
        let destination=$('#end_place_text').val();
        let time_zone=$('#check_label'+select_num).attr('value');
        $('#receipt_text1').text(starting_point);
        $('#receipt_text2').text(destination);
        $('#receipt_text3').text(time_zone);
        
        //let str="https://www.google.co.kr/maps/dir/"+starting_point+", New York/"+destination+", New York";
        //window.open(str);
        
        //readTextFile("../Analysis/distance.txt");
    })


})