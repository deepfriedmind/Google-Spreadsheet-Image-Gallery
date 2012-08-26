# Declare the main application object
Gallery = {}


# Get spreadsheet JSON from Google Data API
Gallery.spreadsheetOpts =
	feed: 'list'
	key: '0AlCvCeRvw0lbdDJFclJsRE5PczJXbndubUlpd0FjMEE'
	worksheet: 'od6'

Gallery.ajaxOpts =
	url: 'http://spreadsheets.google.com/feeds/' + Gallery.spreadsheetOpts.feed + '/' + Gallery.spreadsheetOpts.key + '/' + Gallery.spreadsheetOpts.worksheet + '/public/values'
	dataType: 'jsonp'
	data:
		alt: 'json-in-script'

$.ajax( Gallery.ajaxOpts ).done (data) ->
	Gallery.loadImages data


# Load the images and insert into DOM
Gallery.loadImages = (data) ->
	console.log 'Google Spreadsheet JSON data: ', data

	$.each data.feed.entry, () ->
		console.log "URL: ", @.gsx$url.$t
		console.log "Name: ", @.gsx$name.$t
		console.log "Caption: ", @.gsx$caption.$t

		overlay = $('<div />').attr('class', 'overlay').text @.gsx$name.$t

		container = $('<div />').attr('class', 'img-container').append overlay

		img = $('<img />').attr('src', @.gsx$url.$t)
			.data 'info',
				name: @.gsx$name.$t
				caption: @.gsx$caption.$t
			.load(->
				if not @complete or typeof @naturalWidth is "undefined" or @naturalWidth is 0
					console.log 'Broken image'
				else
					container.append img

					$('#main').append container
			)