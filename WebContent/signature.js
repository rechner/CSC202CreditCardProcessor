(function() {
  // VERSION 1
    //TODO move penstrokes variable to private variable
    //TODO store decoded data back into (private) penstrokes
    //TODO decoder always seems to read an extra null at end
    //TODO fall back onto basic base64 encoding if others fail
    //TODO make encoding and decoding process into webworkers
    //TODO remove direct jquery dependency?
    //TODO make Thomas Bradley's format an offical container format
  
  var defaults = {
    strokestyle: "#145394",
    linewidth  : 2
  }

  sig_init = function (canvas) {
    var c = null, d = !1, e = !1, f = canvas.getContext("2d"), h = jQuery(canvas), i = [],
      j = function (a) {
        if ("touchend" == a.type || "touchcancel" == a.type) return c;
        var b = h.offset();
        "undefined" !== typeof a.originalEvent.targetTouches && (a = a.originalEvent.targetTouches[0]);
        return [a.pageX - Math.floor(b.left) - 1, a.pageY - Math.floor(b.top) - 1]
      }, k = function (a) {
        f.lineWidth = canvas.dataset.linewidth || defaults.linewidth;
        f.strokeStyle = canvas.dataset.strokestyle || defaults.strokestyle;
        f.beginPath();
        f.moveTo(c[0], c[1]);
        f.lineTo(a[0], a[1]);
        f.stroke();
        f.closePath();
        i.push(a)
      }, b = function (a) {
        if (d && e) {
          var b = j(a);
          null == c && (c = b);
          a.preventDefault();
          k(b);
          c = b
        } else {
          null != c && (k(j(a)), canvas.penstrokes.push(i), i = []), c = null
        }
      };
      
    canvas.penstrokes = [];
    canvas.encode = function() { return sig_encode(canvas.penstrokes) }
    
    if ("undefined" !== typeof document.ontouchend) {
      h.on({
        touchstart:  function (a) { a.preventDefault(); d = e = !0; b(a) },
        touchend:    function (a) { a.preventDefault(); d = e = !1; b(a) },
        touchcancel: function (a) { a.preventDefault(); d = e = !1; b(a) },
        touchmove:   b
      })
    } else {
      h.on({
        mouseenter:  function (a) { e = !0; b(a) },
        mouseleave:  function (a) { e = !1; b(a) },
        mousemove:   b
      }), $(document).on({
        mousedown:   function (a) { d = !0; b(a) },
        mouseup:     function (a) { d = !1; b(a) }
      })
    }
  }

  clear_canvas = function (canvas) {
      a = canvas.getContext("2d");
      a.clearRect(0, 0, canvas.width, canvas.height);
  }
  
  sig_decode = function (canvas, data) {
    // unwrap data
    data = data || "0"; // should this be changed into a big if statement?
    for (var a = {
      e: b95atob, a: Zlib.inflate,
      b: function (a) { return Zlib.inflate(b95atob(a)) },
      c: function (a) { return Zlib.inflate(atob(a)) },
      f: function (a) { return atob(a) },
      d: function (a) { return a },
      "0": function () { return "\0" }
    }[data[0]](data.slice(1)), i = [], c = 0; c < a.length; c++) {
      i.push((a[c].charCodeAt() & 240) >> 4), i.push(a[c].charCodeAt() & 15)
    }
    
    // prep canvas
    canvas.penstrokes = [];
    a = canvas.getContext("2d");
    a.clearRect(0, 0, canvas.width, canvas.height);
    // pen stroke
    a.lineCap = a.lineJoin = "round";
    a.lineWidth = canvas.dataset.linewidth || defaults.linewidth;
    a.strokeStyle = canvas.dataset.strokestyle || defaults.strokestyle;
    
    // read number
    function d() {
      var a = 0, b;
      do {
        b = i.shift(), a <<= 3, a |= b & 7
      } while (b & 8);
      return a
    }
    
    // draw dots
    for (var c = d(), j = 0; j < c; j++) {
      var e = d(), f = d();
      a.beginPath();
      a.moveTo(e, f);
      a.lineTo(e, f);
      a.stroke();
      a.closePath()
    }
    
    // draw lines
    var lines = []; // debug code
    while (0 < i.length) {
      j = d(), x = d(), y = d();
      a.beginPath();
      a.moveTo(x, y);
      for (c = 0; c < j; c++) {
        var k = i.shift(), b = k & 7,
          g = { "0": 1, 1:  1, 2:  0, 3: -1, 4: -1, 5: -1, 6: 0, 7: 1 }[b],
          b = { "0": 0, 1: -1, 2: -1, 3: -1, 4:  0, 5:  1, 6: 1, 7: 1 }[b];
        k & 8 && (0 != g && (g *= d()), 0 != b && (b *= d()));
        lines.push([x, y, x + g, y + b]); // debug code
        a.lineTo(x += g, y += b);
      }
      a.stroke();
      a.closePath();
    }
    //console.log(lines); // debug code
    console.log(JSON.stringify(lines)); // debug code
  }

  var i = null;
  sig_encode = function (data) {
    if (data.length == 0) return "0";
    
    // write number
    function g(a) {
      if (7 >= a) j(a); else {
        for (var a = a.toString(2), b = 0; b < a.length % 3; b++) 
          a = "0" + a;
        for (var b = [], c = a.length - 1; 0 < c; c -= 3)
          b.unshift(a.substr(c - 2, 3));
        for (a = 0; a < b.length - 1; a++)
          j(parseInt("1" + b[a], 2));
        j(parseInt("0" + b[b.length - 1], 2));
      }
    }
    
    // write nibble
    function j(a) {
      i != k ? (l += String.fromCharCode((k << 4) + a), k = i) : k = a;
    }
    
    // format data
    for (var b = [], e = [], c = 0; c < data.length; c++) {
      for (var d = [data[c][0]], f = data[c][1], m = i, h = 1; h < data[c].length; h++) {
        if (data[c][h][0] != f[0] || data[c][h][1] != f[1]) {
          var n = (data[c][h][1] - f[1]) / (data[c][h][0] - f[0]);
          n != m && m != i && d.push(f);
          m = n;
          f = data[c][h];
        }
      }
      f[0] != d[0][0] || f[1] != d[0][1] ? (d.push(f), e.push(d)) : b.push(d[0])
    }
    
    // write dots
    var l = "", k = i;
    g(b.length);
    for (a = 0; a < b.length; a++)
      g(b[a][0]), g(b[a][1]);
    
    // write lines
    for (b = 0; b < e.length; b++) {
      g(e[b].length - 1);
      g(e[b][0][0]);
      g(e[b][0][1]);
      for (a = 1; a < e[b].length; a++)
        c = e[b][a][0] - e[b][a - 1][0], d = e[b][a][1] - e[b][a - 1][1], f = 0 < c ? 0 < d ? "111" : 0 == d ? "000" : "001" : 0 == c ? 0 < d ? "110" : "010" : 0 < d ? "101" : 0 == d ? "100" : "011", 1 >= Math.abs(c) && 1 >= Math.abs(d) ? j(parseInt("0" + f, 2)) : (j(parseInt("1" + f, 2)), 0 != c && g(Math.abs(c)), 0 != d && g(Math.abs(d)));
    }
    
    // compress
    k != i && j(0);
    e = Zlib.deflate(l);
    return e.length < l.length ? "b" + b95btoa(e) : "e" + b95btoa(l)
  }
})();
