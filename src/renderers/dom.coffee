class DomRenderer extends Renderer
  _createElements: () ->
    @canvas = document.createElement 'div'
    @pointer = document.createElement 'div'
    @canvas.appendChild @pointer
    @canvas.setAttribute 'class', 'granger'
    @pointer.setAttribute 'class', 'granger-pointer'

    @canvas.style.height = @options.height if @options.height
    @canvas.style.width = @options.width if @options.width

    super()

  _calculateDimensions: () ->
    borderWidth = parseInt(getComputedStyle(@canvas).getPropertyValue('border-top-width'))
    # left/top offset
    @dim = @_offset()
    @dim.width = @canvas.offsetWidth + borderWidth
    @dim.height = @canvas.offsetHeight + borderWidth
    @dim.offset = @pointer.offsetWidth
    @dim.centerX = (@dim.width - borderWidth) / 2
    @dim.centerY = (@dim.height - borderWidth) / 2
    @dim.radius = @dim.width / 2 - @dim.offset

    @draw @dim.centerX, @dim.centerY
    @

  draw: (x, y) ->
    @pointer.style.left = x + 'px'
    if @isSingleVector()
      y = 0
    else
      y = y - @dim.offset
    @pointer.style.top = y + 'px'




