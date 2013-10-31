chalk = require "chalk"

fs = require "fs"
wrench = require "wrench"

module.exports = (grunt)->
  grunt.registerTask 'steroids-make', "Create the dist/ folder that is copied to the device.", [
    'steroids-clean-dist',
    'steroids-build-controllers',
    'steroids-build-models',
    'steroids-build-statics',
    'steroids-compile-models',
    'steroids-compile-views',
    'steroids-cordova-merges'
  ]

  # -------------------------------------------
  # CLEAN TASKS

  grunt.registerTask 'steroids-clean-dist', 'Removes dist/ recursively and creates it again ', ->
    wrench.rmdirSyncRecursive "dist/", true
    grunt.file.mkdir "dist/"

  # -------------------------------------------
  # BUILD TASKS

  copyFilesSyncRecursive = (options)->
    grunt.verbose.writeln "Copying files from #{options.sourcePath} to #{options.destinationDir} using #{options.relativeDir} as basedir"

    for filePath in grunt.file.expand options.sourcePath when fs.statSync(filePath).isFile()

      relativePath = path.relative options.relativeDir, filePath
      destinationPath = path.join options.destinationDir, relativePath

      grunt.verbose.writeln "Copying file #{filePath} to #{destinationPath}"

      grunt.file.copy filePath, destinationPath

  grunt.registerTask 'steroids-build-controllers', "Build controllers", ->
    copyFilesSyncRecursive {
      sourcePath: "app/controllers"
      destinationDir: "dist/"
      relativeDir: "."
    }

  grunt.registerTask 'steroids-build-models', "Build models", ->
    copyFilesSyncRecursive {
      sourcePath: "app/models"
      destinationDir: "dist/models"
      relativeDir: "."
    }

  grunt.registerTask 'steroids-build-statics', "Build static files", ->
    copyFilesSyncRecursive {
      sourcePath: Paths.application.sources.statics
      destinationDir: Paths.application.distDir
      relativeDir: Paths.application.sources.staticDir
    }

  # -------------------------------------------
  # COMPILE TASKS

  grunt.registerTask 'steroids-compile-models', "Compile models", ->
    javascripts = []
    sourceFiles = grunt.file.expand Paths.application.compiles.models

    for filePath in sourceFiles when fs.statSync(filePath).isFile()
      grunt.verbose.writeln "Compiling model file at #{filePath}"
      javascripts.push grunt.file.read(filePath, "utf8").toString()
      fs.unlinkSync filePath

    grunt.file.write Paths.application.compileProducts.models, javascripts.join("\n\n")

  grunt.registerTask 'steroids-compile-views', "Compile views", ->

    projectDirectory          = Paths.applicationDir

    buildDirectory            = path.join projectDirectory, "dist"
    buildViewsDirectory       = path.join buildDirectory, "views"
    buildModelsDirectory      = path.join buildDirectory, "models"
    buildcontrollersDirectory = path.join buildDirectory, "controllers"
    buildStylesheetsDirectory = path.join buildDirectory, "stylesheets"

    appDirectory              = path.join projectDirectory, "app"
    appViewsDirectory         = path.join appDirectory, "views"
    appModelsDirectory        = path.join appDirectory, "models"
    appControllersDirectory   = path.join appDirectory, "controllers"
    appLayoutsDirectory       = path.join appDirectory, "views", "layouts"

    vendorDirectory           = path.join projectDirectory, "vendor"
    wwwDirectory              = path.join projectDirectory, "www"

    viewDirectories = []

    # get each view folder (except layout)
    for dirPath in grunt.file.expand(path.join(appViewsDirectory, "*")) when fs.statSync(dirPath).isDirectory()
      basePath = path.basename(dirPath)
      unless basePath is "layouts" + path.sep or basePath is "layouts"
        viewDirectories.push dirPath
        grunt.file.mkdir path.join(buildViewsDirectory, path.basename(dirPath))


    for viewDir in viewDirectories
      # resolve layout file for these views
      layoutFileName = "";

      # Some machines report folder/ as basename while others do not
      viewBasename = path.basename viewDir

      unless viewBasename.indexOf(path.sep) is -1
        viewBasename = viewBasename.replace path.sep, ""

      layoutFileName = "#{viewBasename}.html"

      layoutFilePath = path.join appLayoutsDirectory, layoutFileName

      unless fs.existsSync(layoutFilePath)
        layoutFilePath = path.join appLayoutsDirectory, "application.html"

      applicationLayoutFile = grunt.file.read layoutFilePath, "utf8"

      for filePathPart in grunt.file.expand(path.join(viewDir, "**", "*")) when fs.statSync(filePathPart).isFile()

        filePath = path.resolve filePathPart

        buildFilePath = path.resolve filePathPart.replace("app"+path.sep, "dist"+path.sep)

        resourceDirName = filePathPart.split("/").splice(-2,1)[0]

        buildFilePath = path.join(buildDirectory, "views", resourceDirName, path.basename(filePathPart))

        # skip "partial" files that begin with underscore
        if /^_/.test path.basename(filePath)
          yieldedFile = grunt.file.read(filePath, "utf8")
        else

          controllerName = path.basename(viewDir).replace(path.sep, "")
          controllerBasenameWithPath = path.join(buildcontrollersDirectory, "#{controllerName}")



          unless fs.existsSync "#{controllerBasenameWithPath}.js"
            warningMessage = "#{chalk.red('Warning:')} There is no controller for resource '#{controllerName}'.  Add file app/controllers/#{controllerName}.{js|coffee}"
            grunt.log.writeln warningMessage

          yieldObj =
            view: grunt.file.read(filePath, "utf8")
            controller: controllerName

          # put layout+yields together
          yieldedFile = grunt.util._.template(
            applicationLayoutFile.toString()
          )({ yield: yieldObj })

        # write the file
        grunt.file.mkdir path.dirname(buildFilePath)
        grunt.file.write buildFilePath, yieldedFile

  grunt.registerTask 'steroids-cordova-merges', "Handle cordova merges", ->

    projectDirectory  = Paths.applicationDir
    distDirectory     = Paths.application.distDir

    mergesDirectory         = path.join projectDirectory, "merges"
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

        grunt.log.writeln "#{filePath.replace(androidMergesDirectory+'/', '')} -> dist#{filePathInDistWithAndroidExtensionPrefix.replace(distDirectory, '')}"

        if fs.existsSync filePathInDistWithAndroidExtensionPrefix
          grunt.log.writeln "#{chalk.red('Overwriting:')} dist#{filePathInDistWithAndroidExtensionPrefix.replace(distDirectory, '')}"

        fs.writeFileSync filePathInDistWithAndroidExtensionPrefix, fs.readFileSync(filePath)

      # iOS
      for filePath in grunt.file.expand(path.join(iosMergesDirectory, "*")) when fs.statSync(filePath).isFile()
        filePath = path.normalize(filePath) # fix windows path syntax
        grunt.log.writeln chalk.yellow("Copying iOS Merges:")

        # setup proper paths for file copy
        filePathInDist = filePath.replace(iosMergesDirectory, distDirectory)

        grunt.log.writeln "#{filePath.replace(iosMergesDirectory+'/', '')} -> dist#{filePathInDist.replace(distDirectory, '')}"

        if fs.existsSync filePathInDist
          grunt.log.writeln "#{chalk.red('Overwriting:')} dist#{filePathInDist.replace(distDirectory, '')}"

        fs.writeFileSync filePathInDist, fs.readFileSync(filePath)
