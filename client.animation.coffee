# 基于并改进了window.requestAnimationFrame，使之不用在回调函数中再写一次window.requestAnimationFrame。
# callback的参数time变为更直观的意思：调用animate之后经过的时间。当callback返回false时，停止动画。
# callback具有1个参数。
animate = (callback) ->
    f = (time) -> if callback(time - startTime) != false then window.requestAnimationFrame(f)
    startTime = window.performance.now()
    window.requestAnimationFrame(f)
# 基于animate。callback具有1个参数time，指的是startTime之后经过的时间。
timespanAnimate = (startTime, duration, callback) ->
    endTime = startTime + duration
    animate((time) ->
        if time >= endTime
            callback(duration)
            false
        else if time >= startTime
            callback(time - startTime)
    )
# 基于timespanAnimate。callback具有1个参数value，指的是动画所针对的值，该值的动态变化形成动画。
valueAnimate = (startValue, endValue, startTime, duration, timingFunction, callback) ->
    timespanAnimate(startTime, duration, (time) ->
        callback(animatedValue(startValue, endValue, duration, time, timingFunction))
    )
# 基于timespanAnimate
translateAnimate = (element, startTranslate, endTranslate, startTime, duration, timingFunction) ->
    timespanAnimate(startTime, duration, (time) ->
        setElementTranslate(element,
                animatedPoint(startTranslate, endTranslate, duration, time, timingFunction))
    )
translateToAnimate = (element, translate, startTime, duration, timingFunction) ->
    translateAnimate(element, getElementTranslate(element), translate, startTime, duration, timingFunction)
animatedValue = (startValue, endValue, duration, currentTime, timingFunction) ->
    startValue + (endValue - startValue) * timingFunction(currentTime / duration)
animatedPoint = (startPoint, endPoint, duration, currentTime, timingFunction) ->
    new Point(
        animatedValue(startPoint.x, endPoint.x, duration, currentTime, timingFunction),
        animatedValue(startPoint.y, endPoint.y, duration, currentTime, timingFunction)
    )
linearTimingFunction = (x) -> x
# 参数a指的是振动的快速程度，b指的是阻尼的大小，c指的是最多允许的振动次数（即周期数。
# 但因为每个周期我们以cos函数值为0时的点为起始点和终点，所以第一次只有3/4个周期）。
# a,b>0，c必须是正整数，且(2*pi*c-pi/2)/a必须小于等于1。
elasticTimingFunctionGenerator = (a, b, c) ->
    (x) -> 1 - (if x < (2 * Math.PI * c - Math.PI / 2) / a then Math.cos(a * x) / (1 + b * x * x) else 0)
# 对于一条三次贝塞尔曲线，如要消去参数t，从而可以通过x直接求y，理论上似乎做不到或是需要极大量的运算（我不太清楚）。
# 对于在缓动函数中使用的曲线，由于x(t)必然单调递增，我使用了二分法来求近似值，约20次循环后能达到0.000001的精度。
cubicBezierTimingFunctionGenerator = (p1, p2) ->
    b = (n1, n2) ->
        # 这是缓动函数所用到的“单位”三次贝塞尔曲线，即P0和P3分别为(0,0)和(1,1)。
        # 本函数是其中任何一个维度的坐标值（由n1,n2代表的维度所决定）。
        (t) -> 3 * (1 - t) * (1 - t) * t * n1 + 3 * (1 - t) * t * t * n2 + t * t * t
    fx = b(p1.x, p2.x)
    fy = b(p1.y, p2.y)
    (x) ->
        if x == 0
            0
        else if x == 1
            1
        else
            tmin = 0
            tmax = 1
            i = 0
            loop
                t = (tmin + tmax) / 2
                p = fx(t)
                if Math.abs(p - x) < 0.000001 or i == 40 then break
                if p < x then tmin = t else tmax = t
                i++
            fy(t)
easeTimingFunction = cubicBezierTimingFunctionGenerator(new Point(0.25, 0.1), new Point(0.25, 1.0))
