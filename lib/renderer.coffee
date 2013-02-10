class Renderer
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
    @canvas.appendChild @pointer
    borderWidth = parseInt(getComputedStyle(@canvas)['border-width'])
    @dim =
      width: @canvas.offsetWidth + borderWidth
      height: @canvas.offsetHeight + borderWidth
      offset: @pointer.offsetWidth

    @dim.centerX = (@dim.width - borderWidth) / 2
    @dim.centerY = (@dim.height - borderWidth) / 2
    @dim.radius = @dim.width / 2 - @dim.offset

    @draw(@dim.centerX, @dim.centerY)
    @

  _bindEvents: () ->
    onStart = (e) =>
      @isDragging = true
      return false

    onDrag = (e) =>
      return unless @isDragging
      if e.type is 'touchmove'
        x = e.touches[0].offsetX
        y = e.touches[0].offsetY
      else
        x = e.offsetX
        y = e.offsetY

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

  draw: (x, y) ->
    @pointer.style.left = x - @dim.offset + 'px'
    @pointer.style.top = y - @dim.offset + 'px'



class CanvasRenderer extends Renderer
  _createElements: () ->
    @canvas = document.createElement 'canvas'
    @canvas.setAttribute 'class', 'granger'
    @ctx = @canvas.getContext '2d'
    fontSize = parseInt(getComputedStyle(@granger.element).getPropertyValue('font-size'), 10)
    @canvas.width = 15 * fontSize
    @canvas.height = 15 * fontSize

    @granger.element.style.display = 'none'
    @canvas.style.cursor = 'pointer'
    @canvas.style.mozUserSelect = 'none'
    @canvas.style.webkitUserSelect = 'none'

    @granger.element.parentNode.insertBefore @canvas, @element
    @dim =
      width: @canvas.width
      height: @canvas.height,
      top: @canvas.offsetTop,
      left: @canvas.offsetLeft

    @dim.centerX = @dim.width / 2
    @dim.centerY = @dim.height / 2
    # 6 is the line Width / 2
    @dim.radius = @dim.width / 2 - 6


    @draw(@dim.centerX, @dim.centerY)
    @

  _bindEvents: () ->
    onStart = (e) =>
      @isDragging = true
      return false

    onDrag = (e) =>
      return unless @isDragging
      if e.type is 'touchmove'
        x = e.touches[0].offsetX
        y = e.touches[0].offsetY
      else
        x = e.offsetX
        y = e.offsetY

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
    @canvas.addEventListener 'touchstart', onStart, false
    @canvas.addEventListener 'touchmove', onDrag, false
    @canvas.addEventListener 'touchend', onEnd, false

  draw: (x, y) ->
    # reset canvas
    @canvas.width = @canvas.width

    @ctx.strokeStyle = '#cccccc'
    @ctx.lineWidth = 12

    @ctx.beginPath()
    @ctx.arc @dim.centerX, @dim.centerY, @dim.radius, 0, Math.PI*2, true
    @ctx.stroke()

    @ctx.strokeStyle = '#000000'
    @ctx.lineWidth = 12

    @ctx.beginPath()
    @ctx.arc x, y, @ctx.lineWidth / 2, 0, Math.PI*2, true
    @ctx.fill()

window.DomRenderer = DomRenderer
window.CanvasRenderer = CanvasRenderer

