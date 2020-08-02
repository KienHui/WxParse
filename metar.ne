@import "common.ne"

metar -> obId ICAO ddhhmmZ AUTOtag:? Wind viswx skycon tempdewpt obAlt {% 
	function(d,l,reject) {
		return {
			type: d[0],
			station: d[1],
			time: d[2],
			auto: d[3],
			wind: d[4],
			viswx: d[5],
			cloud: d[6],
			temp: d[7],
			alstg: d[8]
		};
	}
%}

# line starter
obId -> "METAR" __ {% id %} | "SPECI" __ {% id %}
AUTOtag -> "AUTO" __ {% () => true %}