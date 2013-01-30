class LegalGame extends Game
    constructor: (size, @komi) -> super(size, Game.COLOR_BLACK)
    playMove: (move) ->
        super(move)
    calculateScore: ->
