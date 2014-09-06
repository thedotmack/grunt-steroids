module.exports = (grunt)->

  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-extend-config'

  grunt.registerTask 'steroids-compile-less', "Compile LESS files if they exist", ->

    grunt.extendConfig
      less:
        dist:
          files: [
            # .less files
            {
              expand: true
              cwd: 'app/'
              src: ['**/!(_*|*.android).less']
              dest: 'dist/'
              ext: '.css'
            }
            {
              expand: true
              cwd: 'www/'
              src: ['**/!(_*|*.android).less']
              dest: 'dist/'
              ext: '.css'
            }

            # .android.less and .android.less files
            {
              expand: true
              cwd: 'app/'
              src: ['**/*.android.less']
              dest: 'dist/'
              ext: '.android.css'
            }
            {
              expand: true
              cwd: 'www/'
              src: ['**/*.android.less']
              dest: 'dist/'
              ext: '.android.css'
            }
          ]

    lessFiles = grunt.file.expand(["www/**/*.less", "app/**/*.less"])

    if lessFiles.length > 0
      grunt.log.writeln("LESS files found, attempting to compile them to dist/...")
      grunt.task.run("less:dist")

    else
      grunt.log.writeln("No .less files found in app/ or www/, skipping.")
