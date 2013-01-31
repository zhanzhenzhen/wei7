class LegalGame extends Game
    constructor: (size, @komi) ->
        super(size, Game.COLOR_BLACK)
    playMove: (move) ->
        lastMove = @getLastMove()
        lastButOneMove = if @moves.length < 2 then null else @moves[@moves.length - 2]
        super(move)
        # 禁止打劫时立即反吃
        do =>
            if lastMove != null and lastMove.captures.length == 1 == move.captures.length
                p11 = lastMove.position
                p12 = lastMove.captures[0]
                p21 = move.position
                p22 = move.captures[0]
                p11p21 = p11.vectorToTarget(p21)
                p11p12 = p11.vectorToTarget(p12)
                p21p22 = p21.vectorToTarget(p22)
                if p11p21.magnitude() == 1 and p11p21.equal(p11p12) and p11p12.oppositeTo(p21p22)
                    @undo()
                    fail("Illegal move.")
        # 禁止“送二还一”，因其可能被用于耍赖（故意导致无法终局）
        do =>
            if lastButOneMove != null and
                    lastButOneMove.captures.length == 0 and
                    lastMove.captures.length == 2 and
                    move.captures.length == 1
                p11 = lastButOneMove.position
                p21 = lastMove.position
                p22 = lastMove.captures[0]
                p23 = lastMove.captures[1]
                p31 = move.position
                p32 = move.captures[0]
                p11p21 = p11.vectorToTarget(p21)
                p21p31 = p21.vectorToTarget(p31)
                p21p22 = p21.vectorToTarget(p22)
                p21p23 = p21.vectorToTarget(p23)
                p31p32 = p31.vectorToTarget(p32)
                if p11p21.magnitude() == 2 and p21p31.magnitude() == 1 and
                    p11p21.directionInDegreesTo(p21p31) == 180 and (
                        (p22.equal(p11) and p21p22.equal(p21p23.multiply(2))) or
                        (p23.equal(p11) and p21p23.equal(p21p22.multiply(2)))
                    ) and p32.equal(p21)
                        @undo()
                        fail("Illegal move.")
    calculateScore: ->
