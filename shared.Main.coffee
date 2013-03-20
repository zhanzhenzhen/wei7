fail = (errorMessage) -> throw new Error(errorMessage)
# 返回一个大于等于0且小于n的随机整数
randomInt = (n) -> Math.floor(Math.random() * n)
randomItemInArray = (array) -> array[randomInt(array.length)]
takeOutRandomItemInArray = (array) ->
    index = randomInt(array.length)
    r = array[index]
    array.splice(index, 1)
    r
jsonClone = (x) -> JSON.parse(JSON.stringify(x))
class GameRecordWalker
    constructor: (@record) ->
        @position = {branchIndexes: [], stepIndex: undefined}
        @stepCondition = -> true
        @gotoFirstStep()
    getCurrentBranch: ->
        branch = @record.tree
        for m in @position.branchIndexes
            branch = branch.branches[m]
        branch
    findStepIndex: (isForward, start) ->
        branch = @getCurrentBranch()
        lowerBound = -1
        upperBound = if branch.steps == undefined then -1 else branch.steps.length - 1
        if isForward
            start ?= lowerBound
            end = upperBound
        else
            start ?= upperBound
            end = lowerBound
        for i in [start..end] by (if isForward then 1 else -1)
            if i == -1
                if branch.pre != undefined or branch.steps == undefined then return i
            else
                step = branch.steps[i]
                if @stepCondition(step) then return i
        fail("Step not found.")
    gotoFirstStep: ->
        @position.stepIndex = @findStepIndex(true)
    gotoLastStep: ->
        @position.stepIndex = @findStepIndex(false)
    getNextStepIndex: ->
        branch = @getCurrentBranch()
        @findStepIndex(true, @position.stepIndex + 1)
    getPreviousStepIndex: ->
        branch = @getCurrentBranch()
        @findStepIndex(false, @position.stepIndex - 1)
    gotoNextStep: ->
        @position.stepIndex = @getNextStepIndex()
    gotoPreviousStep: ->
        @position.stepIndex = @getPreviousStepIndex()
    gotoChild: (branchIndex) ->
        branch = @getCurrentBranch()
        if not (branch.branches != undefined and 0 <= branchIndex < branch.branches.length)
            fail("Branch does not exist.")
        @position.branchIndexes.push(branchIndex)
        @gotoFirstStep()
    gotoParent: ->
        if @position.branchIndexes.length == 0
            fail("Already root.")
        @position.branchIndexes.pop()
        @gotoLastStep()
class ObjectWithEvent
    constructor: ->
        @_eventList = {} # 用对象来模拟dictionary比用数组方便，但事件不能取会产生冲突的名称
    subscribeEvent: (eventName, handler) ->
        @_eventList[eventName] ?= []
        @_eventList[eventName].push(handler) if @_eventList[eventName].indexOf(handler) == -1
    unsubscribeEvent: (eventName, handler) ->
        index = indexOf(handler)
        @_eventList[eventName].splice(index, 1) if index != -1
    triggerEvent: (eventName, arg) ->
        @_eventList[eventName] ?= []
        m(arg) for m in @_eventList[eventName]
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
