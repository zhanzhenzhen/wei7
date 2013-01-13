# 这是对window.requestAnimationFrame的改进，使之不用在回调函数中再写一次window.requestAnimationFrame，
# 还有callback的参数time变为更直观的意思：调用animate之后经过的时间。当callback返回false时，停止动画。
# callback只具有1个参数。
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
valueAnimate = (startTime, duration, startValue, endValue, callback) ->
    timespanAnimate(startTime, duration, (time) ->
        callback(animatedValue(startValue, endValue, duration, time))
    )
animatedValue = (startValue, endValue, duration, currentTime) ->
    startValue + (endValue - startValue) * (currentTime / duration)
