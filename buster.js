/*jshint asi:true*/
var config = module.exports;

config['The tests...'] = {
  rootPath: './',
  environment: 'browser', // or 'node'
  extensions: [require('buster-coffee')],
  sources: [
    'build/renderer.js',
    'build/granger.js'
  ],
  tests: [
    'tests/*.coffee'
  ]
}

