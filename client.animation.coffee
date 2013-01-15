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
# 基于timespanAnimate。callback具有1个参数point，指的是动画所针对的点，该点的动态变化形成动画。
pointAnimate = (startPoint, endPoint, startTime, duration, timingFunction, callback) ->
    timespanAnimate(startTime, duration, (time) ->
        callback(animatedPoint(startPoint, endPoint, duration, time, timingFunction))
    )
animatedValue = (startValue, endValue, duration, currentTime, timingFunction) ->
    startValue + (endValue - startValue) * timingFunction(currentTime / duration)
animatedPoint = (startPoint, endPoint, duration, currentTime, timingFunction) ->
    x: animatedValue(startPoint.x, endPoint.x, duration, currentTime, timingFunction)
    y: animatedValue(startPoint.y, endPoint.y, duration, currentTime, timingFunction)
linearTimingFunction = (x) -> x
