class Renderer
  @version: '0.1.0'

  constructor: (@granger) ->
    @options = @granger.options
    @_createElements()
    @_bindEvents()

  _createElements: () ->
    console.log('Error: _createElements not available. Renderer should not be instantiated directly')

  _bindEvents: () ->
    console.log('Error: _bindEvents not available. Renderer should not be instantiated directly')

  sync: (x, y) ->
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

  getPoint: (x, y) ->
    return @pointByLimit x, y if @options.freeBounds
    @pointByAngle x, y


class DomRenderer extends Renderer
  _createElements: () ->
    @canvas = document.createElement 'div'
    @pointer = document.createElement 'div'
    @canvas.setAttribute 'class', 'granger'
    @pointer.setAttribute 'class', 'granger-pointer'
    @granger.element.style.display = 'none'
    @canvas.style.cursor = 'pointer'
    @canvas.style.mozUserSelect = 'none'
    @canvas.style.webkitUserSelect = 'none'

    @granger.element.parentNode.insertBefore @canvas, @element
    @granger.element.parentNode.insertBefore @pointer, @element
    @dim =
      width: @canvas.offsetWidth
      height: @canvas.offsetHeight,
      top: @canvas.offsetTop,
      left: @canvas.offsetLeft

    @dim.centerX = @dim.left + @dim.width / 2
    @dim.centerY = @dim.top + @dim.height / 2
    @dim.radius = @dim.width / 2 - @pointer.offsetWidth / 2

    @draw(@dim.centerX, @dim.centerY)
    @

  _bindEvents: () ->
    onStart = (e) =>
      @isDragging = true
      return false

    onDrag = (e) =>
      return unless @isDragging
      if e.type is 'touchmove'
        x = e.touches[0].pageX
        y = e.touches[0].pageY
      else
        x = e.x
        y = e.y

      result = @getPoint x, y
      @sync result.x, result.y
      @draw result.x, result.y
      e.preventDefault()
      return false

    onEnd = (e) =>
      @isDragging = false
      return false

    @canvas.addEventListener 'mousedown', onStart, false
    @canvas.addEventListener 'mousemove', onDrag, false
    @canvas.addEventListener 'mouseup', onEnd, false
    @pointer.addEventListener 'mousedown', onStart, false
    @pointer.addEventListener 'mousemove', onDrag, false
    @pointer.addEventListener 'mouseup', onEnd, false
    @canvas.addEventListener 'touchstart', onStart, false
    @canvas.addEventListener 'touchmove', onDrag, false
    @canvas.addEventListener 'touchend', onEnd, false


window.DomRenderer = DomRenderer

