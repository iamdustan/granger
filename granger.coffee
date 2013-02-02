
# @param {Object} options options object
# @prop {Boolean} [options.freeBounds] if true, will draw target anywhere within the bounds
class Granger
  @version: '0.0.1'

  constructor: (@element, @options = {}) ->
    @_createElements()
    @_bindEvents()
    @draw(@dim.centerX, @dim.centerY)

  _createElements: () ->
    @canvas = document.createElement 'div'
    @pointer = document.createElement 'div'
    @canvas.setAttribute 'class', 'granger'
    @pointer.setAttribute 'class', 'granger-pointer'
    @element.style.display = 'none'
    @element.parentNode.insertBefore @canvas, @element
    @element.parentNode.insertBefore @pointer, @element
    @dim =
      width: @canvas.offsetWidth
      height: @canvas.offsetHeight,
      top: @canvas.offsetTop,
      left: @canvas.offsetLeft

    @dim.centerX = @dim.left + @dim.width / 2
    @dim.centerY = @dim.top + @dim.height / 2
    @dim.radius = @dim.width / 2 - @pointer.offsetWidth / 2
    @

  _bindEvents: () ->
    onMousemove = (e) =>
      result = @getPoint e.x, e.y
      @update result.x, result.y
      @draw result.x, result.y

    @canvas.addEventListener 'mousemove', onMousemove, false

  getPoint: (x, y) ->
    return @pointByLimit x, y if @options.freeBounds
    @pointByAngle x, y

  update: (x, y) ->
    # todo. calculate value and update input element

  draw: (x, y) ->
    @pointer.style.left = x + 'px'
    @pointer.style.top = y + 'px'

  pointByAngle: (x, y) ->
    radians = Math.atan2(@dim.centerY - y, @dim.centerX - x)
    x = -1 * @dim.radius * Math.cos(radians) + @dim.centerX
    y = -1 * @dim.radius * Math.sin(radians) + @dim.centerY
    return { x, y }

  pointByLimit: (x, y) ->
    dx = x - @dim.centerX
    dy = y - @dim.centerY
    distanceSquared = (dx*dx) +(dy*dy)

    return { x, y } if distanceSquared <= @dim.radius * @dim.radius

    distance = Math.sqrt(distanceSquared)
    ratio = @dim.radius / distance
    x = dx * ratio + @dim.centerX
    y = dy * ratio + @dim.centerY
    return { x, y }

window.Granger = Granger
