# Google-Spreadsheet-Image-Gallery
### Experiment with an image gallery populated by a Google Spreadsheet.
##### Using [Middleman](http://middlemanapp.com) with Haml, Sass/Compass and CoffeeScript. 

# 

### [View demo](http://dev.deepfriedmind.com/google-spreadsheet-image-gallery)

# 

Main features:

- Loading external image data as JSON from a Google Spreadsheet, via the Google Data API. The Spreadsheet can be accessed [here](https://docs.google.com/spreadsheet/pub?key=0AlCvCeRvw0lbdDJFclJsRE5PczJXbndubUlpd0FjMEE&output=html).
- Lazy loading of images for fastest possible initial load time (i.e. images are only loaded once they are in the viewport).
- Completely responsive layout using [jQuery Masonry](http://masonry.desandro.com/).
- Single image view with permalink structure and fully functional browser forward/back button, using pushState via the HTML5 History API. The only server-side code needed is some mod_rewrites in .htaccess and getting the folder URL with PHP (to support having the site in a sub-folder).

Photos borrowed from Instagram user @dew