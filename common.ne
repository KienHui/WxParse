@builtin "whitespace.ne" # `_` means arbitrary amount of whitespace

main -> ICAO __ ddhhmmZ __ Wind __ skycon {% 
	function(d,l,reject) {
		return {
			station: d[0],
			time: d[2],
			wind: d[4],
			cloud: d[6]
		};
	}
%}
#wind values
Wind -> direction speed gust:? speedunit {%
	function(d,l,reject) {
		if (d[2] && d[2]<d[1]) {
			return reject;
		}
		return {
			dir: d[0],
			spd: d[1],
			gst: d[2],
			unit: d[3]
		};
	}
%}
direction ->digit2 "0" {% ([fst, _],l,r) => fst <36 ? fst*10 : r %}
	| "VRB" {% id %}
speed -> digit2 {% id %} | nzdigit3 {% id %}
gust -> "G" speed {% ([_,speed]) => speed %}
speedunit -> "KT" {% id %} | "MPS" {% id %}

# times
ddhhmmZ -> ddhhmm "Z" {% ([t,_]) => t %}

ddhhmm -> digit2 digit2 digit2 {% 
	function(d,l,reject) {
		if (d[0] > 31 || d[1] > 23 || d[2] > 59) {
			return reject;
		}
		return {
			day: d[0],
			hour: d[1],
			min: d[2]
		};
	}
%}

# clouds

skycon -> "SKC" __ {% () => [{coverage: "SKC", okta: 0, height: 0}] %}
	| "CLR" __ {% () => [{coverage: "CLR", okta: 0, height: 0}] %}
	| "VV" height __{% ([c,h]) => [{coverage: "VV", okta: 8, height: h}] %}
	| cldlyr:+ {% id %}

cldlyr -> cldcov height __ {% ([cov,hgt,_])=> ({coverage: cov.cov, okta:cov.okta, height: hgt}) %}

cldcov -> "FEW" {% ([d]) => ({cov: d, okta:1}) %}
	| "SCT" {% ([d]) => ({cov: d, okta:3}) %}
	| "BKN" {% ([d]) => ({cov: d, okta:5}) %}
	| "OVC" {% ([d]) => ({cov: d, okta:8}) %}

height -> digit3 {% id %}

ICAO -> alpha alphanum alphanum alphanum {% (d) => d.join("") %}

# common
alphanum -> alpha | digit
alpha -> [a-zA-Z]
nonzero -> [1-9]
digit -> [0-9] 
digit2 -> digit digit {% (d) => d.join("")|0 %}
digit3 -> digit digit digit {% (d) => d.join("")|0 %}
nzdigit3 -> nonzero digit digit {% (d) => d.join("")|0 %}
