# Include vendor JS
#= require 'vendor/jquery.masonry'
#= require 'vendor/jquery.lazyload'


# Declare the main application object...
Gallery =
	# ...and some misc vars
	$body: $ 'body'
	$main: $ '#main'
	imageWidth: 612
	imageHeight: 612


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
		url = @.gsx$url.$t
		name = @.gsx$name.$t
		caption = @.gsx$caption.$t

		console.log 'URL: ', url
		console.log 'Name: ', name
		console.log 'Caption: ', caption

		# Create elements
		$nameOverlay = $('<div />').attr('class', 'nameOverlay').text name
		$captionOverlay = $('<div />').attr('class', 'captionOverlay').append '<h2>' + name + '</h2><p>' + caption + '</p>'
		$container = $('<div />').attr
			class: 'img-container'
			id: 'img-' + i
		$img = $('<img />').attr(
			src: 'img/trans.png'
			width: Gallery.imageWidth
			height: Gallery.imageHeight)
			.data
				original: url
				name: name
				caption: caption

		$container.append($nameOverlay, $captionOverlay, $img).appendTo Gallery.$main

		# Initiate Masonry and Lazy Load when all elements have been created in the DOM
		if i is data.feed.entry.length-1
			Gallery.init()


Gallery.init = ->
	Gallery.lazyLoad(
		effect: 'fadeIn'
		threshold: 100
	)

	Gallery.$main.masonry(
		itemSelector: '.img-container'
		isAnimated: not Modernizr.csstransitions
		isFitWidth: true
	)


# Lazy Load function
Gallery.lazyLoad = (opts) ->
	$('.img-container img').lazyload opts

# Refresh lazy load on window (smart) resize
$(window).smartresize(->
	# A bit dirty with a timer but Masonry doesn't supply a reLayout callback like Isotope does
	setTimeout Gallery.lazyLoad, 1500
)


# Image click handler
$('#main').on 'click', '.img-container', ->
	$this = $ this
	$id = '#' + $this.attr 'id'

	if $this.hasClass 'active'
		$this.removeClass 'active'
		Gallery.$main.masonry 'reload'

	else
		$('.img-container.active').removeClass 'active'
		$this.addClass 'active'
		Gallery.$main.masonry 'reload'

		# Scroll the element nicely in to view
		$scrollOffset = $(window).scrollTop()+100
		$elementOffset = Math.floor $($id).offset().top
		console.log '$scrollOffset: ', $scrollOffset
		console.log '$elementOffset: ', $elementOffset

		unless $scrollOffset is $elementOffset
			setTimeout (->
				console.log 'scrolling'
				$('html, body').animate
					scrollTop: $elementOffset-100
				, 'slow'
			), 1000