chalk = require "chalk"
wrench = require "wrench"

fs = require "fs"
path = require "path"

SteroidsConfigure = require '../lib/SteroidsConfigure'

module.exports = (grunt)->

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-extend-config"


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

  grunt.registerTask "steroids-configure", "Read XML configuration files from www/ and output a JSON to dist/", ->
    done = @async()

    configXml = grunt.file.read "www/config.xml"
    SteroidsConfigure.fromXml configXml, (err, json) ->
      throw new Error err if err?
      grunt.file.write "dist/config.json", json
      
      done()
