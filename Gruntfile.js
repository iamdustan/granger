module.exports = function(grunt) {
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  grunt.initConfig({
    watch: {
      coffee: {
        files: ['src/**/*.coffee'],
        tasks: ['coffee:compile']
      },
      karma: {
        files: ['src/**/*.coffee'],
        tasks: ['karma:unit:run']
      }
    },
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      options: {
        join: true
      },
      compile: {
        files: {
          'dist/granger.js': ['src/**/*.coffee']
        }
      }
    },
    karma: {
      unit: {
        configFile: 'karma.conf.js',
        background: true
      },
      test: {
        configFile: 'karma.conf.js',
        background: false
      }
    }
  })

  grunt.registerTask('test', ['karma:test'])
  grunt.registerTask('develop', ['karma:unit', 'watch:coffee'])
}

