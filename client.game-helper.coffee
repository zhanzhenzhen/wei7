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
    @playMoveInBoard: (point) ->
        game = context.game
        oldSnapshot = game.getBoardSnapshot()
        game.playMove(point)
        newSnapshot = game.getBoardSnapshot()
        diff = Game.compareSnapshots(oldSnapshot, newSnapshot)
        ui.board.updateStones(diff, true)
        ui.board.setActiveStone(point, game.getLastMove().color)
