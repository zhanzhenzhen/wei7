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
# Chrome 21（360浏览器使用的内核）不支持window.performance.now，
# 360浏览器在中国有很大份额，所以也得考虑进去，使用低精度的模拟。
if window.performance != undefined and window.performance.now == undefined
    window.performance.now = -> Date.now() - window.performance.timing.navigationStart
# Safari现在还在仅使用带前缀的window.requestAnimationFrame，
# 而且还在使用已废弃的timestamp作为回调函数的参数，所以我们在Safari中模拟标准实现。
# 注意：Chrome也是使用WebKit，但是已经支持不带前缀的了，所以此模拟只针对Safari。
if window.requestAnimationFrame == undefined and window.webkitRequestAnimationFrame != undefined
    window.requestAnimationFrame = (callback) ->
        window.webkitRequestAnimationFrame((time) -> callback(time - window.performance.timing.navigationStart))
# IE 10不支持所有SVG元素的contains方法（它只支持HTML元素的，它的contains方法
# 并不是如W3C所要求的那样建立在Node之上）。我们在IE 10中模拟它，功能从简（只支持元素对元素）。
if SVGElement::contains == undefined
    SVGElement::contains = (element) ->
        if element == @ then return true
        for item in @getElementsByTagName("*")
            if item == element then return true
        return false
