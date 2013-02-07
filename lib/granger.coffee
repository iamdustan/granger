
# @param {Object} options options object
# @prop {Boolean} [options.freeBounds] if true, will draw target anywhere within the bounds
class Granger
  @version: '0.1.0'

  constructor: (@element, @options = {}) ->
    @data = {
      min: Number @element.getAttribute('min')
      max: Number @element.getAttribute('max')
    }
    @renderer = new DomRenderer @

  sync: (value) ->
    # todo. update renderer based on value

window.Granger = Granger
