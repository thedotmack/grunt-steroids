
module.exports = (grunt) ->

  grunt.registerTask "steroids-make", "Create the dist/ folder that is copied to the device.", [
    "steroids-clean-dist"
    "steroids-copy-js-from-app"
    "steroids-copy-www"
    "steroids-compile-coffee"
    "steroids-concat-models"
    "steroids-compile-views"
    "steroids-cordova-merges"
    "steroids-configure"
  ]
