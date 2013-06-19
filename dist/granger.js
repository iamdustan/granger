(function() {
  var CanvasRenderer, DomRenderer, Granger, Renderer, fireEvent, _ref, _ref1,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Granger = (function() {
    Granger.version = '0.1.0';

    function Granger(element, options) {
      var value;
      this.element = element;
      this.options = options != null ? options : {};
      if (typeof this.element === 'string') {
        this.element = document.getElementById(this.element);
      }
      this.data = {
        min: Number(this.element.getAttribute('min')),
        max: Number(this.element.getAttribute('max'))
      };
      value = this.element.value || (this.data.max - this.data.min) / 2 + this.data.min;
      if (this.options.renderer === 'canvas') {
        this.renderer = new CanvasRenderer(this, value);
      } else {
        this.renderer = new DomRenderer(this, value);
      }
    }

    Granger.prototype.sync = function(value) {
      this.element.value = Math.round(value);
      fireEvent(this.element, 'change');
      return this;
    };

    return Granger;

  })();

  fireEvent = (function() {
    if (__indexOf.call(Element.prototype, 'fireEvent') >= 0) {
      return function(element, event) {
        return element.fireEvent("on" + event);
      };
    }
    return function(element, event) {
      var e;
      e = document.createEvent("HTMLEvents");
      e.initEvent(event, true, true);
      return element.dispatchEvent(e);
    };
  })();

  window.Granger = Granger;

  window.emit = fireEvent;

  Renderer = (function() {
    function Renderer(granger, startValue) {
      var start,
        _this = this;
      this.granger = granger;
      this.options = this.granger.options;
      this._createElements();
      this._calculateDimensions();
      this._bindEvents();
      start = this.pointByValue(startValue);
      this.update(start.x, start.y);
      this.granger.element.addEventListener('change', function(e) {
        var point;
        console.log('changed', _this.granger.element.value);
        point = _this.pointByValue(_this.granger.element.value);
        return _this.draw(point.x, point.y);
      }, false);
    }

    Renderer.prototype._createElements = function() {
      this.granger.element.style.display = 'none';
      this.canvas.style.cursor = 'pointer';
      this.canvas.style.mozUserSelect = 'none';
      this.canvas.style.webkitUserSelect = 'none';
      this.granger.element.parentNode.insertBefore(this.canvas, this.element);
      return this;
    };

    Renderer.prototype._calculateDimensions = function() {
      return console.error('Error: _calculateDimensions not available. Renderer should not be instantiated directly');
    };

    Renderer.prototype._bindEvents = function() {
      var isTap, lastCoords, onCancel, onDrag, onEnd, onStart, startCoords,
        _this = this;
      isTap = false;
      startCoords = void 0;
      lastCoords = void 0;
      onStart = function(e) {
        isTap = true;
        startCoords = _this._eventCoordinates(e);
        _this.canvas.addEventListener('mousemove', onDrag, false);
        _this.canvas.addEventListener('mouseup', onEnd, false);
        _this.canvas.addEventListener('mousecancel', onCancel, false);
        _this.canvas.addEventListener('touchmove', onDrag, false);
        _this.canvas.addEventListener('touchend', onEnd, false);
        _this.canvas.addEventListener('touchcancel', onCancel, false);
        document.documentElement.addEventListener('mouseup', onEnd, false);
        document.documentElement.addEventListener('touchend', onEnd, false);
        return false;
      };
      onDrag = function(e) {
        var result;
        if (e.target !== _this.canvas) {
          return;
        }
        lastCoords = _this._eventCoordinates(e);
        result = _this.getPoint(lastCoords.x, lastCoords.y);
        if (Math.abs(startCoords.x - lastCoords.x) > 10 || Math.abs(startCoords.y - lastCoords.y) > 10) {
          isTap = false;
        }
        _this.sync(result.x, result.y);
        _this.draw(result.x, result.y);
        e.preventDefault();
        return false;
      };
      onEnd = function(e) {
        var coords, result;
        if (isTap) {
          coords = _this._eventCoordinates(e);
          result = _this.getPoint(coords.x, coords.y);
          _this.sync(result.x, result.y);
          _this.draw(result.x, result.y);
        }
        onCancel();
        return false;
      };
      onCancel = function(e) {
        _this.canvas.removeEventListener('mousemove', onDrag);
        _this.canvas.removeEventListener('mouseup', onEnd);
        _this.canvas.removeEventListener('mousecancel', onCancel);
        _this.canvas.removeEventListener('touchmove', onDrag);
        _this.canvas.removeEventListener('touchend', onEnd);
        _this.canvas.removeEventListener('touchcancel', onCancel);
        document.documentElement.removeEventListener('mouseup', onEnd);
        document.documentElement.removeEventListener('touchend', onEnd);
        return startCoords = lastCoords = void 0;
      };
      this.canvas.addEventListener('mousedown', onStart, false);
      return this.canvas.addEventListener('touchstart', onStart, false);
    };

    Renderer.prototype.sync = function(x, y) {
      var value;
      value = this.valueByPoint(x, y);
      this.granger.sync(value);
      return this;
    };

    Renderer.prototype.update = function(x, y) {
      this.draw(x, y);
      this.sync(x, y);
      return this;
    };

    Renderer.prototype.limit = function(value) {
      return Math.max(Math.min(value, this.granger.data.max), this.granger.data.min);
    };

    Renderer.prototype.valueByPoint = function(x, y) {
      var abs, offset, percentage, radians;
      if (this.isSingleVector) {
        percentage = x / (this.dim.radius * 2);
      } else {
        abs = this.pointByAngle(x, y);
        offset = -Math.PI / 2;
        radians = Math.atan2(this.dim.centerY - abs.y, this.dim.centerX - abs.x);
        if (radians < Math.PI / 2) {
          radians = Math.PI * 2 + radians;
        }
        percentage = (radians + offset) / (Math.PI * 2);
      }
      return this.limit(percentage * (this.granger.data.max - this.granger.data.min) + this.granger.data.min);
    };

    Renderer.prototype.pointByValue = function(value) {
      var percentage, radians, x, y;
      percentage = (value - this.granger.data.min) / (this.granger.data.max - this.granger.data.min);
      radians = (percentage * 2 + 0.5) * Math.PI;
      x = -1 * this.dim.radius * Math.cos(radians) + this.dim.centerX;
      y = -1 * this.dim.radius * Math.sin(radians) + this.dim.centerY;
      return {
        x: x,
        y: y
      };
    };

    Renderer.prototype.pointByAngle = function(x, y) {
      var radians;
      radians = Math.atan2(this.dim.centerY - y, this.dim.centerX - x);
      x = -1 * this.dim.radius * Math.cos(radians) + this.dim.centerX;
      y = -1 * this.dim.radius * Math.sin(radians) + this.dim.centerY;
      return {
        x: x,
        y: y
      };
    };

    Renderer.prototype.pointByLimit = function(x, y) {
      var distance, distanceSquared, dx, dy, ratio;
      if (this.isSingleVector()) {
        return {
          x: x,
          y: y
        };
      }
      dx = x - this.dim.centerX;
      dy = y - this.dim.centerY;
      distanceSquared = (dx * dx) + (dy * dy);
      if (distanceSquared <= this.dim.radius * this.dim.radius) {
        return {
          x: x,
          y: y
        };
      }
      distance = Math.sqrt(distanceSquared);
      ratio = this.dim.radius / distance;
      x = dx * ratio + this.dim.centerX;
      y = dy * ratio + this.dim.centerY;
      return {
        x: x,
        y: y
      };
    };

    Renderer.prototype.getPoint = function(x, y) {
      if (this.options.freeBounds || this.isSingleVector()) {
        return this.pointByLimit(x, y);
      }
      return this.pointByAngle(x, y);
    };

    Renderer.prototype.isSingleVector = function() {
      return /^(x|y)/.test(this.options.type);
    };

    Renderer.prototype._eventOffset = function(e) {
      var node, x, y;
      x = y = 0;
      if (!e.offsetParent) {
        return {
          x: x,
          y: y
        };
      }
      node = this.canvas;
      while ((node = node.offsetParent)) {
        x += node.offsetLeft;
        y += node.offsetTop;
      }
      return {
        x: x,
        y: y
      };
    };

    Renderer.prototype._eventCoordinates = function(e) {
      var offset, x, y;
      offset = this._eventOffset(e);
      if (e.type === 'touchmove') {
        x = e.touches[0].pageX - offset.x;
        y = e.touches[0].pageY - offset.y;
      } else {
        x = e.layerX - offset.x;
        y = e.layerY - offset.y;
      }
      return {
        x: x,
        y: y
      };
    };

    return Renderer;

  })();

  CanvasRenderer = (function(_super) {
    __extends(CanvasRenderer, _super);

    function CanvasRenderer() {
      _ref = CanvasRenderer.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    CanvasRenderer.prototype._createElements = function() {
      this.canvas = document.createElement('canvas');
      this.canvas.setAttribute('class', 'granger');
      this.ctx = this.canvas.getContext('2d');
      if (this.options.height) {
        this.canvas.height = this.options.height;
      }
      if (this.options.width) {
        this.canvas.width = this.options.width;
      }
      return CanvasRenderer.__super__._createElements.call(this);
    };

    CanvasRenderer.prototype._calculateDimensions = function() {
      this.dim = {
        width: this.canvas.width,
        height: this.canvas.height,
        top: this.canvas.offsetTop,
        left: this.canvas.offsetLeft
      };
      this.dim.centerX = this.dim.width / 2;
      this.dim.centerY = this.dim.height / 2;
      this.dim.radius = this.dim.width / 2 - 6;
      this.draw(this.dim.centerX, this.dim.centerY);
      return this;
    };

    CanvasRenderer.prototype.draw = function(x, y) {
      this.canvas.width = this.canvas.width;
      this.ctx.strokeStyle = '#cccccc';
      this.ctx.lineWidth = 12;
      if (this.isSingleVector()) {
        this.ctx.lineCap = 'round';
        this.ctx.beginPath();
        this.ctx.moveTo(this.dim.centerX - this.dim.radius, this.ctx.lineWidth / 2);
        this.ctx.lineTo(this.dim.centerX + this.dim.radius, this.ctx.lineWidth / 2);
        this.ctx.stroke();
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 12;
        this.ctx.beginPath();
        this.ctx.arc(x, this.ctx.lineWidth / 2, this.ctx.lineWidth / 2, 0, Math.PI * 2, true);
        return this.ctx.fill();
      } else {
        this.ctx.beginPath();
        this.ctx.arc(this.dim.centerX, this.dim.centerY, this.dim.radius, 0, Math.PI * 2, true);
        this.ctx.stroke();
        this.ctx.strokeStyle = '#000000';
        this.ctx.lineWidth = 12;
        this.ctx.beginPath();
        this.ctx.arc(x, y, this.ctx.lineWidth / 2, 0, Math.PI * 2, true);
        return this.ctx.fill();
      }
    };

    return CanvasRenderer;

  })(Renderer);

  DomRenderer = (function(_super) {
    __extends(DomRenderer, _super);

    function DomRenderer() {
      _ref1 = DomRenderer.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    DomRenderer.prototype._createElements = function() {
      this.canvas = document.createElement('div');
      this.pointer = document.createElement('div');
      this.canvas.appendChild(this.pointer);
      this.canvas.setAttribute('class', 'granger');
      this.pointer.setAttribute('class', 'granger-pointer');
      if (this.options.height) {
        this.canvas.style.height = this.options.height;
      }
      if (this.options.width) {
        this.canvas.style.width = this.options.width;
      }
      return DomRenderer.__super__._createElements.call(this);
    };

    DomRenderer.prototype._calculateDimensions = function() {
      var borderWidth;
      borderWidth = parseInt(getComputedStyle(this.canvas).getPropertyValue('border-top-width'));
      this.dim = {
        width: this.canvas.offsetWidth + borderWidth,
        height: this.canvas.offsetHeight + borderWidth,
        offset: this.pointer.offsetWidth
      };
      this.dim.centerX = (this.dim.width - borderWidth) / 2;
      this.dim.centerY = (this.dim.height - borderWidth) / 2;
      this.dim.radius = this.dim.width / 2 - this.dim.offset;
      this.draw(this.dim.centerX, this.dim.centerY);
      return this;
    };

    DomRenderer.prototype.draw = function(x, y) {
      this.pointer.style.left = x + 'px';
      if (this.isSingleVector()) {
        y = 0;
      } else {
        y = y - this.dim.offset;
      }
      return this.pointer.style.top = y + 'px';
    };

    return DomRenderer;

  })(Renderer);

}).call(this);
