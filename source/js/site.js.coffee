# Include vendor JS
#= require 'vendor/jquery.isotope'
#= require 'vendor/jquery.lazyload'


# Declare the main application object...
Gallery = {}

# ...and some misc vars
$body = $ 'body'
$main = $ '#main'


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

	$.each data.feed.entry, (i) ->
		console.log "URL: ", @.gsx$url.$t
		console.log "Name: ", @.gsx$name.$t
		console.log "Caption: ", @.gsx$caption.$t


		# Create elements
		$overlay = $('<div />').attr('class', 'overlay').text @.gsx$name.$t
		$container = $('<div />').attr
			class: 'img-container'
			id: 'img-' + i
		$img = $('<img />').attr(
			src: 'img/trans.png'
			width: 612
			height: 612)
			.data
				original: @.gsx$url.$t
				name: @.gsx$name.$t
				caption: @.gsx$caption.$t

		$container.append($overlay, $img).appendTo $main

		# Initiate Isotope when all images have loaded
		if i is data.feed.entry.length-1

			Gallery.lazyLoad(
				effect: 'fadeIn'
				threshold: 100
			)

			$main.isotope(
				itemSelector: '.img-container'
				onLayout: ->
					Gallery.lazyLoad()
				)


# Lazy load function
Gallery.lazyLoad = (opts) ->
	$('.img-container img').lazyload( opts )


# Image click handler
$('#main').on 'click', '.img-container', ->
	$this = $ this
	$id = '#' + $this.attr 'id'

	if $this.hasClass 'active'
		console.log 'hej'
		$this.removeClass 'active'
		$main.isotope 'reLayout'

	else
		$('html, body').animate
			scrollTop: $($id).offset().top
		, 'slow', ->
			console.log 'da'
			$('.img-container.active').removeClass 'active'
			$this.addClass 'active'
			$main.isotope 'reLayout'