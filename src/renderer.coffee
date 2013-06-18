class Renderer
  constructor: (@granger, startValue) ->
    @options = @granger.options
    @_createElements()
    @_bindEvents()
    start = @pointByValue(startValue)
    @draw(start.x, start.y)
    @sync(start.x, start.y)
    @granger.element.addEventListener('change', (e) =>
      point = @pointByValue(@granger.element.value)
      @draw point.x, point.y
    , false)

  _createElements: () ->
    console.log('Error: _createElements not available. Renderer should not be instantiated directly')

  _bindEvents: () ->
    console.log('Error: _bindEvents not available. Renderer should not be instantiated directly')

  sync: (x, y) ->
    # + 1/2 Math.PI === @data.min
    value = @valueByPoint(x, y)
    @granger.sync value
    @

  valueByPoint: (x, y) ->
    abs = @pointByAngle x, y
    offset = - Math.PI / 2
    radians = Math.atan2(@dim.centerY - abs.y, @dim.centerX - abs.x)
    if radians < Math.PI / 2
      radians = Math.PI * 2 + radians

    percentage = (radians + offset) / (Math.PI * 2)
    (@granger.data.min / percentage)

    value = percentage * (@granger.data.max - @granger.data.min) + @granger.data.min

  pointByValue: (value) ->
    percentage = (value - @granger.data.min) / (@granger.data.max - @granger.data.min)
    radians = (percentage * 2 + 0.5) * Math.PI
    x = -1 * @dim.radius * Math.cos(radians) + @dim.centerX
    y = -1 * @dim.radius * Math.sin(radians) + @dim.centerY
    return { x, y }

  pointByAngle: (x, y) ->
    radians = Math.atan2(@dim.centerY - y, @dim.centerX - x)
    x = -1 * @dim.radius * Math.cos(radians) + @dim.centerX
    y = -1 * @dim.radius * Math.sin(radians) + @dim.centerY
    return { x, y }

  pointByLimit: (x, y) ->
    dx = x - @dim.centerX
    dy = y - @dim.centerY
    distanceSquared = (dx * dx) + (dy * dy)

    return { x, y } if distanceSquared <= @dim.radius * @dim.radius

    distance = Math.sqrt(distanceSquared)
    ratio = @dim.radius / distance
    x = dx * ratio + @dim.centerX
    y = dy * ratio + @dim.centerY
    return { x, y }

  getPoint: (x, y) ->
    return @pointByLimit x, y if @options.freeBounds or @isSingleVector()
    @pointByAngle x, y

  isSingleVector: () ->
    /^(x|y)/.test @options.type


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
        x = e.touches[0].pageX - e.touches[0].target.offsetLeft
        y = e.touches[0].pageY - e.touches[0].target.offsetTop
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
    @pointer.style.left = x + 'px'
    if @isSingleVector()
      y = 0
    else
      y = y - @dim.offset
    @pointer.style.top = y + 'px'



class CanvasRenderer extends Renderer
  _createElements: () ->
    @canvas = document.createElement 'canvas'
    @canvas.setAttribute 'class', 'granger'
    @ctx = @canvas.getContext '2d'
    fontSize = parseInt(getComputedStyle(@granger.element).getPropertyValue('font-size'), 10)
    @canvas.width = @options.width or 15 * fontSize
    @canvas.height = @options.height or 15 * fontSize

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
        x = e.touches[0].pageX - e.touches[0].target.offsetLeft
        y = e.touches[0].pageY - e.touches[0].target.offsetTop
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

    if @isSingleVector()
      @ctx.lineCap = 'round'

      @ctx.beginPath()
      @ctx.moveTo @dim.centerX - @dim.radius, @ctx.lineWidth / 2
      @ctx.lineTo @dim.centerX + @dim.radius, @ctx.lineWidth / 2
      @ctx.stroke()

      @ctx.strokeStyle = '#000000'
      @ctx.lineWidth = 12

      @ctx.beginPath()
      @ctx.arc x, @ctx.lineWidth / 2, @ctx.lineWidth / 2, 0, Math.PI*2, true
      @ctx.fill()
    else
      @ctx.beginPath()
      @ctx.arc @dim.centerX, @dim.centerY, @dim.radius, 0, Math.PI*2, true
      @ctx.stroke()

      @ctx.strokeStyle = '#000000'
      @ctx.lineWidth = 12

      @ctx.beginPath()
      @ctx.arc x, y, @ctx.lineWidth / 2, 0, Math.PI*2, true
      @ctx.fill()

