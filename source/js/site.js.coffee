# Include vendor JS via Sprockets
#= require 'vendor/jquery.masonry'
#= require 'vendor/jquery.lazyload'
#= require 'vendor/history'
#= require 'vendor/history.adapter.jquery'
#= require 'vendor/jquery.easing.1.3'

Gallery =
	$body: $ 'body'
	$main: $ '#main'
	$permaLinkBtn: $ '#copy-permalink'
	defaultPageTitle: document.title
	defaultPagePath: window.baseUrl or window.location.href
	imgOrigWidth: 612
	imgOrigHeight: 612
	imgThumbWidth: 306
	imgThumbHeight: 306
	currentImage: undefined
	pushState: History.enabled # Does the browser support pushState?

# console.log 'window.baseUrl: ', window.baseUrl
# console.log 'window.location.href: ', window.location.href
# console.log 'Gallery.defaultPagePath: ', Gallery.defaultPagePath


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
	# console.log 'Google Spreadsheet JSON data: ', data

	$.each data.feed.entry, (i) ->
		id = i+1
		url = @.gsx$url.$t
		name = @.gsx$name.$t
		caption = @.gsx$caption.$t

		# console.log 'URL: ', url
		# console.log 'Name: ', name
		# console.log 'Caption: ', caption

		# Create elements
		$nameOverlay = $('<div />').attr('class', 'nameOverlay').text name
		$captionOverlay = $('<div />').attr('class', 'captionOverlay').append '<h2>' + name + '</h2><p>' + caption + '</p>'
		$container = $('<div />').attr(
			class: 'img-container'
			id: 'img-' + id)
			.data
				id: id
				name: name
		$img = $('<img />').attr(
			src: 'img/trans.png'
			width: Gallery.imgOrigWidth
			height: Gallery.imgOrigHeight)
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

	Gallery.urlHandler()


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
	$data = $this.data()
	$id = $data.id
	$name = $data.name
	$elem = $('#img-' + $id)

	# Enlarge the clicked image (unless it's already active)
	# The reason for using $.animate() for these animations is because transitioning CSS transforms (like "scale")
	# still suffers from flickering/visual artifacts in Webkit and all the workarounds produce other
	# problems like blurry, stretched images and text (due to rasterization), when put in an OpenGL 3D context.
	# Safari on the Mac has gotten a bit better with this lately but Chrome is still quite problematic.
	if $this.hasClass 'active'
		$this.children('.nameOverlay')
		.hide()
		.end()
		.removeClass('active')
		.stop(true,true)
		.animate
			width: Gallery.imgThumbWidth
			height: Gallery.imgThumbHeight
		, 'fast', 'easeInOutExpo', ->
			$this.children('.nameOverlay').show()
			Gallery.$main.masonry 'reload'

		# Reset state
		Gallery.currentImage = undefined
		if Gallery.pushState
			History.pushState(
				id: 'default',
				Gallery.defaultPageTitle, Gallery.defaultPagePath)

		# Hide button to copy permalink
		Gallery.$permaLinkBtn.removeClass()

	else
		if $('.img-container.active').length is 0
			$this.addClass('active').stop(true,true).animate
				width: Gallery.imgOrigWidth
				height: Gallery.imgOrigHeight
			, 'fast', 'easeInOutExpo', ->
				Gallery.$main.masonry 'reload'
		else
			$('.img-container.active').removeClass('active').stop(true,true).animate
				width: Gallery.imgThumbWidth
				height: Gallery.imgThumbHeight
			, 'fast', 'easeInOutExpo', ->
				$this.addClass('active').stop(true,true).animate
					width: Gallery.imgOrigWidth
					height: Gallery.imgOrigHeight
				, 'fast', 'easeInOutExpo', ->
					Gallery.$main.masonry 'reload'

		# Update state
		Gallery.currentImage = $id
		if Gallery.pushState
			History.pushState(
				id: $id,
				$name + ' | ' + Gallery.defaultPageTitle, Gallery.defaultPagePath+$id)

		# Show button to copy permalink
		Gallery.$permaLinkBtn.removeClass().addClass 'visible'

		# Scroll the element nicely in to view
		$scrollOffset = $(window).scrollTop()+100
		$elemOffset = Math.floor $elem.offset().top
		# console.log '$scrollOffset: ', $scrollOffset
		# console.log '$elemOffset: ', $elemOffset

		unless $scrollOffset is $elemOffset
			setTimeout (->
				$('html, body').animate
					scrollTop: $elemOffset-100
				, 'slow', 'easeInOutQuint', ->
					# console.log 'Scrolled to image ', $id
			), 1000


# Handle browser back/forward button clicks
$(window).on 'statechange', ->
	# console.log 'Gallery.currentImage: ', Gallery.currentImage
	state = History.getState()
	# console.log 'state: ', state
	if state.data.id is Gallery.currentImage
		false
	else if state.data.id is 'default'
		$('.img-container.active').trigger 'click'
	else
		$('#img-' + state.data.id).trigger 'click'

	Gallery.$permaLinkBtn.children('input').val window.location.href


# Handle initial URL state for permalinks
Gallery.urlHandler = ->
	id = window.location.pathname.split('/').pop()
	$('#img-' + id).trigger 'click'
	Gallery.$permaLinkBtn.children('input').val window.location.href


# Copy permalink
Gallery.$permaLinkBtn.on
	mouseenter: ->
		$(this).children('input').select().addClass 'visible'
	mouseleave: ->
		$(this).children('input').removeClass()