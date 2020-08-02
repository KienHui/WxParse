@builtin "whitespace.ne" # `_` means arbitrary amount of whitespace

UpToThree[x] -> null {% id %}
	| $x {% id %} 
	| $x $x {% (d => [d[0][0], d[1][0]]) %}
	| $x $x $x {% d => [d[0][0], d[1][0], d[2][0]] %}

#wind values
Wind -> direction speed gust:? speedunit wndvar:? __ {%
		function([dir,spd,g,unit,wvar],l,reject) {
			if (g && g<spd) {
				return reject;
			}
			if (dir == "VRB") {
				wvar = true;
			}
			return {
				dir: dir,
				spd: spd,
				gst: g,
				unit: unit,
        var: wvar
			};
		}
	%}
	| "M" __ {% ()=>(null) %}
	| "00000" speedunit __ {% ([calm,unit])=> ({dir:"000",spd:"00",unit:unit})%}
direction -> wndnonvrbdir {% id %}
	| "VRB" {% id %}
wndnonvrbdir -> "0" nonzero "0" {% (d) => d.join("")|0 %}
	| [1-2] digit "0" {% (d) => d.join("")|0 %}
	| "3" [0-6] "0" {% (d) => d.join("")|0 %}
speed -> digit2 {% id %} | nzdigit3 {% id %}
gust -> "G" speed {% ([_,speed]) => speed %}
speedunit -> "KT" {% id %} | "MPS" {% id %}
wndvar -> __ wndnonvrbdir "V" wndnonvrbdir 
  {% ([_,dir1,v, dir2]) => ({dir1:dir1, dir2:dir2})%}

# times
ddhhmmZ -> ddhhmm "Z" __ {% ([t,_]) => t %}

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

# viswx

viswx -> vis wx:? {% ([v,w]) => ({vis:v, wx:w})%}

vis -> vissm __ {% ([v]) => ({range: v, unit: "SM"})%}
	| vismeter __ {% ([v]) => ({range: v, unit: "meter"})%}
	| "M" __ {% ()=>(null) %}

vissm -> digit2 "SM" {% id %}
	| digit "SM" {% (d) => d[0][0] %}
	| digit __ fraction "SM" {% ([m,_,f]) => (m|0)+f %}
	| "M":? fraction "SM" {% (d) => d.join("")|0 %}

vismeter -> "M":? digit2 "00" {% (d) => d.join("")|0 %}
  | "9999"  {% id %}

rvr -> "R" runway "/"
	
wx -> "BR" __

wxtor -> "+FC" __
  | "FC" __

wxts -> "VCTS"
  | wxintensity "TS" UpToThree[wxprecip]

wxsh -> "VCSH"
  | wxintensity "SH" UpToThree[wxprecip]

wxprecip -> "DZ" {% id %} 
  | "RA"{% id %} 
  | "SN"{% id %} 
  | "SG"{% id %} 
  | "IC"{% id %} 
  | "PL"{% id %}
  | "GR"{% id %} 
  | "GS"{% id %} 

wxintensity -> "+" {% id %} 
  | "-" {% id %} 
  | null {% id %}

# clouds

skycon -> "SKC" __ {% () => [{coverage: "SKC", okta: 0, height: 0}] %}
	| "CLR" __ {% () => [{coverage: "CLR", okta: 0, height: 0}] %}
	| "VV" height __{% ([c,h]) => [{coverage: "VV", okta: 8, height: h}] %}
	| cldlyr:+ {% id %}
	| "M" __ {% ()=>(null) %}

cldlyr -> cldcov height __ {% ([cov,hgt,_])=> ({coverage: cov.cov, okta:cov.okta, height: hgt}) %}

cldcov -> "FEW" {% ([d]) => ({cov: d, okta:1}) %}
	| "SCT" {% ([d]) => ({cov: d, okta:3}) %}
	| "BKN" {% ([d]) => ({cov: d, okta:5}) %}
	| "OVC" {% ([d]) => ({cov: d, okta:8}) %}

height -> digit3 {% id %}

ICAO -> alpha alphanum alphanum alphanum __ {% (d) => d.join("") %}

# temp

tempdewpt -> temp "/" temp __ {% ([t,s,d,_],l,r) => (t<d?r:{temp:t, dewpt:d}) %}

temp -> digit2 {% id %}
	| "M" digit2 {% ([m,t]) => -t %}
	
# altimeter

obAlt -> "A" digit4 __{% (d) => ({stg: d[1]/100, unit: "inHg"}) %}
	| "Q" digit4 __{% (d) => ({stg: d[1], unit: "mb"}) %}

# common
alphanum -> alpha | digit
alpha -> [a-zA-Z]
nonzero -> [1-9]
digit -> [0-9] 
digit2 -> digit digit {% (d) => d.join("")|0 %}
digit3 -> digit digit digit {% (d) => d.join("")|0 %}
digit4 -> digit digit digit digit {% (d) => d.join("")|0 %}
nzdigit3 -> nonzero digit digit {% (d) => d.join("")|0 %}
fraction -> nonzero "/" ("2"|"4"|"8"|"16") {% ([n,s,d],l,r) => n<d?n[0]/d[0]:r %}
