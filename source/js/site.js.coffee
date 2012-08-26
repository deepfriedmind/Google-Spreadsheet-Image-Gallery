spreadsheetKey = '0AlCvCeRvw0lbdDJFclJsRE5PczJXbndubUlpd0FjMEE'

$.ajax(
	url: 'http://spreadsheets.google.com/feeds/list/' + spreadsheetKey + '/od6/public/values'
	dataType: 'jsonp'
	data:
		alt: 'json-in-script'
).done (data) ->
	console.log 'Google Spreadsheet JSON data: ', data

	$.each data.feed.entry, () ->
		console.log "URL: ", @.gsx$url.$t
		console.log "Name: ", @.gsx$name.$t
		console.log "Caption: ", @.gsx$caption.$t