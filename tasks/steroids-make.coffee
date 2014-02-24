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

  grunt.registerTask "steroids-cordova-merges", "Handle Cordova merges", ->

    grunt.log.write("Moving platform-specific files from the merges/ directory to dist/...")

    distDirectory           = "dist"

    mergesDirectory         = "merges"
    androidMergesDirectory  = path.join mergesDirectory, "android"
    iosMergesDirectory      = path.join mergesDirectory, "ios"

    mergesExist = fs.existsSync mergesDirectory
    if mergesExist
      # Android
      for filePath in grunt.file.expand(path.join(androidMergesDirectory, "*")) when fs.statSync(filePath).isFile()
        filePath = path.normalize(filePath) # fix windows path syntax
        grunt.log.writeln chalk.yellow("Copying Android Merges:")

        # setup proper paths and filenames to steroids android comptible syntax: index.html to index.android.html
        origFileName  = path.basename filePath
        origFileExtension = path.extname origFileName
        androidPrefixedExtension = ".android#{origFileExtension}"
        androidFileName = origFileName.replace origFileExtension, androidPrefixedExtension
        filePathInDist = filePath.replace(androidMergesDirectory, distDirectory)
        filePathInDistWithAndroidExtensionPrefix = filePathInDist.replace(origFileName, androidFileName)

        grunt.log.writeln "#{filePath.replace(androidMergesDirectory+"/", "")} -> dist#{filePathInDistWithAndroidExtensionPrefix.replace(distDirectory, "")}"

        if fs.existsSync filePathInDistWithAndroidExtensionPrefix
          grunt.log.writeln "#{chalk.red("Overwriting:")} dist#{filePathInDistWithAndroidExtensionPrefix.replace(distDirectory, "")}"

        fs.writeFileSync filePathInDistWithAndroidExtensionPrefix, fs.readFileSync(filePath)

      # iOS
      for filePath in grunt.file.expand(path.join(iosMergesDirectory, "*")) when fs.statSync(filePath).isFile()
        filePath = path.normalize(filePath) # fix windows path syntax
        grunt.log.writeln chalk.yellow("Copying iOS Merges:")

        # setup proper paths for file copy
        filePathInDist = filePath.replace(iosMergesDirectory, distDirectory)

        grunt.log.writeln "#{filePath.replace(iosMergesDirectory+"/", "")} -> dist#{filePathInDist.replace(distDirectory, "")}"

        if fs.existsSync filePathInDist
          grunt.log.writeln "#{chalk.red("Overwriting:")} dist#{filePathInDist.replace(distDirectory, "")}"

        fs.writeFileSync filePathInDist, fs.readFileSync(filePath)

    grunt.log.writeln "#{chalk.green("OK")}"

  grunt.registerTask "steroids-configure", "Read XML configuration files from www/ and output a JSON to dist/", ->
    done = @async()

    configXml = grunt.file.read "www/config.xml"
    SteroidsConfigure.fromXml configXml, (err, json) ->
      throw new Error err if err?
      grunt.file.write "dist/config.json", json
      
      done()
