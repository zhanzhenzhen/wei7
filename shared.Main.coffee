fail = (errorMessage) -> throw new Error(errorMessage)
# 这个类既可表示一个“点”，也可表示一个“向量”，因本质上都是两个数字（有序对）
class Point
    constructor: (@x, @y) ->
    equal: (p) -> p.x == @x and p.y == @y
    add: (p) -> new Point(@x + p.x, @y + p.y)
    multiply: (n) -> new Point(@x * n, @y * n)
    vectorToTarget: (p) -> new Point(p.x - @x, p.y - @y)
    magnitude: ->
        # 如果在x或y轴上，那么不计算平方根。这不是为了性能，而是为了避免出现近似值。
        # 当然，现在的所有浏览器都已经很智能，不可能出现近似值了，但这是以防万一。
        if @x == 0
            Math.abs(@y)
        else if @y == 0
            Math.abs(@x)
        else
            Math.sqrt(@x * @x + @y * @y)
    distance: (p) -> @vectorToTarget(p).magnitude()
    cross: (p) -> @x * p.y - @y * p.x
    clone: -> new Point(@x, @y)
    opposite: -> new Point(-@x, -@y)
    oppositeTo: (p) -> p.x == -@x and p.y == -@y
    direction: -> Math.atan2(@y, @x) # 方向值来源于atan2函数
    directionInDegrees: ->
        d = @direction() / Math.PI * 180
        rd = Math.round(d) # 当度为整数时避免出现近似值
        if Math.abs(d - rd) < 0.0001
            if rd == -180 then 180 else rd
        else
            d
    directionInDegreesTo: (p) ->
        d = p.directionInDegrees() - @directionInDegrees()
        if d > 180
            d - 360
        else if d <= -180
            d + 360
        else
            d
