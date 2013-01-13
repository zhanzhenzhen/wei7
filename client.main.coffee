parseElement = (s) -> (new DOMParser()).parseFromString(s, "application/xml").documentElement
homeButton = parseElement("""
    <g xmlns="http://www.w3.org/2000/svg" transform="translate(-768,0)">
        <circle cx="0" cy="0" r="60" stroke="rgb(0,0,0)" stroke-width="30" fill="rgb(255,255,255)" />
    </g>
""")
uiBoard = parseElement("""
    <g xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <rect x="-512" y="-512" width="1024" height="1024" fill="rgb(219,179,119)" />
    </g>
""")
document.addEventListener("DOMContentLoaded", ->
    uiPoint = (x, y) ->
        p = uiRoot.createSVGPoint()
        p.x = x
        p.y = y
        p
    uiRoot = document.getElementById("root")
    uiRoot.convertPointToScreen = (p) ->
        p.matrixTransform(uiRoot.getScreenCTM())
    uiRoot.convertPointFromScreen = (p) ->
        p.matrixTransform(uiRoot.getScreenCTM().inverse())
    uiRoot.positionLimit = uiRoot.convertPointFromScreen(uiPoint(window.innerWidth, window.innerHeight))
    uiRoot.appendChild(homeButton)
    do ->
        uiBoard.startPosX = uiRoot.positionLimit.x + 512 + 256
        uiBoard.transform.baseVal.clear()
        uiBoard.transform.baseVal.appendItem(uiRoot.createSVGTransform())
        uiBoard.transform.baseVal.getItem(0).setTranslate(uiBoard.startPosX, 0)
        uiRoot.appendChild(uiBoard)
        valueAnimate(750, 400, uiBoard.startPosX, 0, (value) ->
            uiBoard.transform.baseVal.getItem(0).setTranslate(value, 0)
        )
    window.uiBoard = uiBoard
)
