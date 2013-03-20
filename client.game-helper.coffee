class GameHelper
    @getResultText: (result) ->
        if not result?
            "结果未知"
        else if result.winner == Game.COLOR_BLACK
            if result.margin?
                "黑胜#{result.margin}目"
            else
                "黑中盘胜"
        else if result.winner == Game.COLOR_WHITE
            if result.margin?
                "白胜#{result.margin}目"
            else
                "白中盘胜"
        else
            "结果未知"
    @applyScoringAgent: (legalGame) ->
        score = legalGame.calculateScore()
        legalGame.setResult(score.winner, score.margin)
    @randomBot: (legalGame) ->
        emptyPoints = legalGame.getPointsInColor(Game.COLOR_EMPTY)
        success = do ->
            while emptyPoints.length != 0
                p = takeOutRandomItemInArray(emptyPoints)
                if legalGame.testMove(p) then return p
            return null
        success
    @addStonesInBoard: (stones) ->
        game = context.game
        oldSnapshot = game.getBoardSnapshot()
        game.addStones(stones)
        newSnapshot = game.getBoardSnapshot()
        diff = Game.compareSnapshots(oldSnapshot, newSnapshot)
        ui.board.updateStones(diff, false)
    @removeStonesInBoard: ->
        game = context.game
        oldSnapshot = game.getBoardSnapshot()
        game.removeStones()
        newSnapshot = game.getBoardSnapshot()
        diff = Game.compareSnapshots(oldSnapshot, newSnapshot)
        ui.board.updateStones(diff, false)
    @playMoveInBoard: (move) ->
        game = context.game
        game.playMove(move)
        movePlayed = game.getLastMove()
        if movePlayed.position != null
            ui.board.addStone(movePlayed.color, movePlayed.position, true)
            for m in movePlayed.captures
                ui.board.removeStone(m, true)
        ui.board.setActiveStone(movePlayed.position, movePlayed.color)
    @takebackMoveInBoard: (count) ->
        game = context.game
        oldSnapshot = game.getBoardSnapshot()
        game.undo() for i in [0...count]
        newSnapshot = game.getBoardSnapshot()
        diff = Game.compareSnapshots(oldSnapshot, newSnapshot)
        ui.board.updateStones(diff, false)
        move = game.getLastMove()
        if move != null then ui.board.setActiveStone(move.position, move.color)
