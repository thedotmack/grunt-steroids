chalk = require "chalk"

fs = require "fs"
wrench = require "wrench"
path = require "path"

module.exports = (grunt)->

  grunt.loadNpmTasks 'grunt-contrib-sass'

  grunt.initConfig

    sass:
      dist:
        files: [
          {
            expand: true
            cwd: 'app/'
            src: ['**/*.scss', '**/*.sass']
            dest: 'dist/'
            ext: '.css'
          }
          {
            expand: true
            cwd: 'www/'
            src: ['**/*.scss', '**/*.sass']
            dest: 'dist/'
            ext: '.css'
          }
        ]

  grunt.registerTask 'steroids-compile-sass', "Compile SASS files if they exist", ->

    sassFiles = grunt.file.expand(["www/**/*.scss", "www/**/*.sass", "app/**/*.scss", "app/**/*.sass"])

    if sassFiles.length > 0
      grunt.log.writeln("SASS files found, attempting to compile them to dist/...")
      grunt.task.run("sass:dist")

    else
      grunt.log.writeln("No .scss or .sass files found in app/ or www/, skipping SASS compile.")
