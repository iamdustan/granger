
# @param {Object} options options object
# @prop {Boolean} [options.freeBounds] if true, will draw target anywhere within the bounds
# @prop {String} [options.type] if dial, point, vector
class Granger
  @version: '0.1.5'

  constructor: (@element, @options = {}) ->
    @element = document.getElementById(@element) if typeof @element == 'string'
    @data =
      min: Number @element.getAttribute('min')
      max: Number @element.getAttribute('max')
    value = @element.value or (@data.max - @data.min) / 2 + @data.min

    if @options.renderer is 'canvas'
      @renderer = new CanvasRenderer @, value
    else @renderer = new DomRenderer @, value

  sync: (value) ->
    @element.value = Math.round value
    fireEvent @element, 'change'
    @

fireEvent = (() ->
  if 'fireEvent' in Element.prototype
    #todo. make sure this propagates in oldIE
    return (element, event) ->
      element.fireEvent("on#{ event }")

  (element, event) ->
    e = document.createEvent("HTMLEvents")
    e.initEvent(event, true, true)
    element.dispatchEvent(e)
)()

window.Granger = Granger
window.emit = fireEvent


