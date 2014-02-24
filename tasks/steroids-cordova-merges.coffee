chalk = require "chalk"

fs = require "fs"
path = require "path"

module.exports = (grunt)->

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