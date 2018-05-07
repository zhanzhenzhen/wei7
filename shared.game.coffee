###
Game类实现了最底层的棋局。它既可以表示正在播放的棋谱中的棋，也可以表示正在对局中的棋。
它的主要作用是使棋盘的状态符合围棋的基本规则。
    注意：Game不能储存变化（分支），也不控制UI的呈现，也没有打劫禁手，也无法判断胜负，
    也不禁止自杀，甚至不强制黑白双方交替下子（即一方可以连下两手或以上）。
    这些功能如果需要，将由更加高阶的模块来提供。不过Game可以回退（即俗称的“悔棋”）。
    为啥允许自杀，因为这样能使规则从数学上看起来更漂亮。
    为啥没有打劫禁手，因为当作为教程需要说明规则时，就需要一些违反规则的例子。
    不强制交替下子的原因也一样。而且有些搞笑的“勺子”棋谱恰恰就有这些情况出现。
    总之，Game类禁止的下法应尽可能少。
首先是一些要素：
Color指“颜色”，即黑、白、空三者之一。
Position指棋盘上一个点的坐标，含x,y属性。基本上就等于Point，但使用场合有些差异。
VisualUnit指棋盘上的一个视觉意义上的单元，也就是一个点，它含有color（表示该点目前的状态）
和position两个属性。
    注意：如果position为null，则通常应该用来表示pass。
Stone指具体的某颗棋子，即某个非空的VisualUnit。
Snapshot指整个棋盘的快照，即局面（“局面”在英语中应为position，但我们这里position有其他含义）
State指整个棋盘的全部状态（包括chains等内部状态）。
move指一步棋，它在VisualUnit的基础上增加了可选的previousState和captures。
Chain指一块棋，即竖直方向或水平方向相连的所有棋子的集合。它有一些属性和方法，比较复杂。
liberty指气，指具体的某一口气，它是一个position。
其次是对一些词语的解释：
adjacent或相邻，仅包括水平和竖直方向，不包括对角线方向。
###
class Game extends ObjectWithEvent
    @COLOR_EMPTY: 0
    @COLOR_BLACK: 1
    @COLOR_WHITE: 2
    constructor: (@size, @firstColor) ->
        super()
        @secondColor = Game.getOpposite(@firstColor)
        @moves = []
        @_board = @_createBoard()
        @_chains = []
    class Chain
        constructor: (@game, @color) -> @positions = [] # chain内的棋子的坐标
        getLiberties: ->
            result = []
            tryPush = (pos) =>
                for i in [0...result.length]
                    if result[i].equal(pos) then return
                result.push(pos)
            for i in [0...@positions.length]
                pos = @positions[i]
                x = pos.x
                y = pos.y
                if x != 0 and @game._getBoardItemFromXY(x - 1, y).color == Game.COLOR_EMPTY
                    tryPush(new Point(x - 1, y))
                if x != @game.size - 1 and @game._getBoardItemFromXY(x + 1, y).color == Game.COLOR_EMPTY
                    tryPush(new Point(x + 1, y))
                if y != 0 and @game._getBoardItemFromXY(x, y - 1).color == Game.COLOR_EMPTY
                    tryPush(new Point(x, y - 1))
                if y != @game.size - 1 and @game._getBoardItemFromXY(x, y + 1).color == Game.COLOR_EMPTY
                    tryPush(new Point(x, y + 1))
            result
        merge: (chainsToMerge) ->
            for i in [0...chainsToMerge.length]
                chain = chainsToMerge[i]
                for j in [0...chain.positions.length]
                    pos = chain.positions[j]
                    @game._getBoardItem(pos).chain = @
                    @positions.push(pos)
                @game._chains.splice(@game._chains.indexOf(chain), 1)
        clone: ->
            newChain = new Chain(@game, @color)
            newPositions = newChain.positions
            for i in [0...@positions.length]
                pos = @positions[i]
                newPositions.push(new Point(pos.x, pos.y))
            newChain
    @getOpposite: (color) ->
        if color == Game.COLOR_BLACK
            Game.COLOR_WHITE
        else if color == Game.COLOR_WHITE
            Game.COLOR_BLACK
        else
            fail("No opposite.")
    @compareSnapshots: (oldSnapshot, newSnapshot) ->
        size = Math.round(Math.sqrt(newSnapshot.length))
        (
            color: m
            position: new Point(i % size, Math.floor(i / size))
        ) for m, i in newSnapshot when m != oldSnapshot[i]
    isPointInBoard: (p) -> 0 <= p.x < @size and 0 <= p.y < @size
    getAdjacentPoints: (p) ->
        m for m in [
            new Point(p.x - 1, p.y),
            new Point(p.x + 1, p.y),
            new Point(p.x, p.y - 1),
            new Point(p.x, p.y + 1)
        ] when @isPointInBoard(m)
    getBoardSnapshot: -> m.color for m in @_board
    getExtensibleBoardSnapshot: -> {color: m.color} for m in @_board
    getNextColor: ->
        if @moves.length % 2 == 0 then @firstColor else @secondColor
    addStones: (stones) ->
        if @moves.length != 0 then fail("Already has moves.")
        for i in [0...stones.length]
            @_addStone(stones[i])
    removeStones: ->
        if @moves.length != 0 then fail("Already has moves.")
        @_board = @_createBoard()
        @_chains = []
    barePlayMove: (move) -> # move也可为一Point
        if move == null or move instanceof Point
            move = {color: @getNextColor(), position: move}
        move.previousState = @_cloneState()
        move.captures = []
        pos = move.position # pos如为null则代表pass
        if pos == null
            @moves.push(move)
        else
            if @_getBoardItem(move.position).color != Game.COLOR_EMPTY
                fail("Illegal move. This point already has a stone.")
            color = move.color
            oppositeColor = Game.getOpposite(color)
            # *****(
            # 原理：
            # 由两个步骤组成。
            # 第一步，添加棋子。
            # 第二步，处理吃子。程序不但能处理吃敌方的棋，还能吃自己的（即自杀）。
            # 注意：本来为了追求性能，我没有用方法去实现数气的功能，而是动态更新属性。但后来发现实在难处理，
            # 便改用方法试了试，结果并不像想象的那样坏，那点性能损耗根本无法察觉。
            chainForMove = @_addStone(move)
            do =>
                emptyChain = (chain) =>
                    for m in chain.positions
                        boardItem = @_getBoardItem(m)
                        boardItem.color = Game.COLOR_EMPTY
                        boardItem.chain = null
                        move.captures.push(m)
                    @_chains.splice(@_chains.indexOf(chain), 1)
                chainsToUse = @_getAdjacentChains(pos, oppositeColor)
                for m in chainsToUse
                    if m.getLiberties().length == 0
                        emptyChain(m)
                if move.captures.length != 0
                    move.isSuicide = false
                else if chainForMove.getLiberties().length == 0
                    emptyChain(chainForMove)
                    move.isSuicide = true
            # )*****
            @moves.push(move)
    playMove: (move) ->
        @barePlayMove(move)
        @triggerEvent("AfterPlayMove")
    testMove: (move) ->
        try
            @barePlayMove(move)
        catch e
            return false
        @undo()
        true
    undo: ->
        move = @moves[@moves.length - 1]
        @_board = move.previousState.board
        @_chains = move.previousState.chains
        @moves.splice(@moves.length - 1, 1)
    getLastMove: -> if @moves.length == 0 then null else @moves[@moves.length - 1]
    getColor: (point) -> @_getBoardItem(point).color
    getColorFromIndex: (index) -> @_board(index).color
    getColorFromXY: (x, y) -> @_getBoardItemFromXY(x, y).color
    getPointsInColor: (color) -> @convertIndexToPoint(i) for m, i in @_board when m.color == color
    convertPointToIndex: (point) -> point.y * @size + point.x
    convertIndexToPoint: (index) -> new Point(index % @size, Math.floor(index / @size))
    _getBoardItem: (point) -> @_getBoardItemFromXY(point.x, point.y)
    _getBoardItemFromXY: (x, y) -> @_board[y * @size + x]
    _createBoard: -> {color: Game.COLOR_EMPTY, chain: null} for i in [0...@size * @size]
    # 属于color一方的与pos相邻的所有的chain（显然最多可以有4个）
    _getAdjacentChains: (pos, color) ->
        tryPush = (chain) => if result.indexOf(chain) == -1 then result.push(chain)
        x = pos.x
        y = pos.y
        result = []
        if x != 0 and @_getBoardItemFromXY(x - 1, y).color == color
            tryPush(@_getBoardItemFromXY(x - 1, y).chain)
        if x != @size - 1 and @_getBoardItemFromXY(x + 1, y).color == color
            tryPush(@_getBoardItemFromXY(x + 1, y).chain)
        if y != 0 and @_getBoardItemFromXY(x, y - 1).color == color
            tryPush(@_getBoardItemFromXY(x, y - 1).chain)
        if y != @size - 1 and @_getBoardItemFromXY(x, y + 1).color == color
            tryPush(@_getBoardItemFromXY(x, y + 1).chain)
        result
    _cloneState: ->
        newBoard = @_createBoard()
        newChains = []
        for i in [0...@_chains.length]
            chain = @_chains[i]
            newChain = chain.clone()
            for j in [0...chain.positions.length]
                pos = chain.positions[j]
                newBoardItem = newBoard[@convertPointToIndex(pos)]
                newBoardItem.color = newChain.color
                newBoardItem.chain = newChain
            newChains.push(newChain)
        {board: newBoard, chains: newChains}
    # 把一个棋子放到棋盘中。这里主要是要处理chain，要决定是为该棋子新建一个chain，
    # 还是用原来已存在的chain。如果用原来已存在的chain，那么决定是简单地把该子加入chain，
    # 还是需要合并chain（取决于与该子相邻的chain的数目）。
    _addStone: (stone) ->
        color = stone.color
        pos = stone.position
        chainsToUse = @_getAdjacentChains(pos, color)
        if chainsToUse.length == 0
            chain = new Chain(@, color)
            @_chains.push(chain)
        else if chainsToUse.length == 1
            chain = chainsToUse[0]
        else
            longestChain = chainsToUse[0]
            longestChainIndex = 0
            for i in [1...chainsToUse.length]
                if chainsToUse[i].positions.length > longestChain.positions.length
                    longestChain = chainsToUse[i]
                    longestChainIndex = i
            chainsToUse.splice(longestChainIndex, 1)
            longestChain.merge(chainsToUse)
            chain = longestChain
        chain.positions.push(pos)
        boardItem = @_getBoardItem(pos)
        boardItem.color = color
        boardItem.chain = chain
        chain
