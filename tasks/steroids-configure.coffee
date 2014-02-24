
SteroidsConfigure = require '../lib/SteroidsConfigure'

module.exports = (grunt)->

  grunt.registerTask "steroids-configure", "Read XML configuration files from www/ and output a JSON to dist/", ->
    configPath = "www/config.xml"
    if not grunt.file.isFile configPath
      grunt.log.writeln "No file found at #{configPath}, skipping."
      return

    done = @async()

    configXml = grunt.file.read configPath
    SteroidsConfigure.fromXml configXml, (err, json) ->
      throw new Error err if err?
      grunt.file.write "dist/config.json", json
      
      done()
