fail = (errorMessage) -> throw new Error(errorMessage)
class Point
    constructor: (@x, @y) ->
    equal: (p) -> p.x == @x and p.y == @y
    add: (p) -> new Point(@x + p.x, @y + p.y)
    multiply: (n) -> new Point(@x * n, @y * n)
