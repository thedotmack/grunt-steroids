
SteroidsConfigure = require '../lib/SteroidsConfigure'

module.exports = (grunt)->

  grunt.registerTask "steroids-configure", "Read XML configuration files from www/ and output a JSON to dist/", ->
    done = @async()

    configXml = grunt.file.read "www/config.xml"
    SteroidsConfigure.fromXml configXml, (err, json) ->
      throw new Error err if err?
      grunt.file.write "dist/config.json", json
      
      done()
