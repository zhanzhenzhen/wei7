# 对于window.requestAnimationFrame，目前Firefox仅使用带前缀的，
# 而且还在使用已废弃的timestamp作为回调函数的参数，因此我们在Firefox中模拟出一个符合W3C的实现。
if window.requestAnimationFrame == undefined and window.mozRequestAnimationFrame != undefined
    window.requestAnimationFrame = (callback) ->
        window.mozRequestAnimationFrame((time) -> callback(time - window.performance.timing.navigationStart))
# Safari现在还不支持window.performance，所以我们在Safari中模拟它，当然精度就只能是低精度了
if window.performance == undefined
    window.performance =
        now: -> Date.now() - window.performance.timing.navigationStart
        timing:
            navigationStart: Date.now()
# Safari现在还在仅使用带前缀的window.requestAnimationFrame，
# 而且还在使用已废弃的timestamp作为回调函数的参数，所以我们在Safari中模拟标准实现。
# 注意：Chrome也是使用WebKit，但是已经支持不带前缀的了，所以此模拟只针对Safari。
if window.requestAnimationFrame == undefined and window.webkitRequestAnimationFrame != undefined
    window.requestAnimationFrame = (callback) ->
        window.webkitRequestAnimationFrame((time) -> callback(time - window.performance.timing.navigationStart))
