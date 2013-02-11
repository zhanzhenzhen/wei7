ui.board.addSquareButton = (text, position, clickHandler) ->
    element = parseElement("""
        <g transform="translate(#{position.x},#{position.y})" cursor="pointer"
                xmlns="http://www.w3.org/2000/svg">
            <rect x="-52" y="-52" width="104" height="104" rx="8" opacity="0.8"
                    fill="rgb(0,128,255)" stroke="rgb(255,255,255)" stroke-width="3" />
            <text x="0" y="20" fill="rgb(255,255,255)" font-size="56" text-anchor="middle" />
        </g>
    """)
    element.getElementsByTagName("text")[0].textContent = text
    setElementClickHandler(element, clickHandler) if clickHandler?
    ui.boardDialog.appendChild(element)
    element
ui.board.addButton = (text, position, clickHandler) ->
    element = parseElement("""
        <g transform="translate(#{position.x},#{position.y})" cursor="pointer"
                xmlns="http://www.w3.org/2000/svg">
            <rect x="-104" y="-52" width="208" height="104" opacity="0.8"
                    fill="rgb(0,128,255)" stroke="rgb(255,255,255)" stroke-width="3" />
            <text x="0" y="20" fill="rgb(255,255,255)" font-size="56" text-anchor="middle" />
        </g>
    """)
    element.getElementsByTagName("text")[0].textContent = text
    setElementClickHandler(element, clickHandler) if clickHandler?
    ui.boardDialog.appendChild(element)
    element
ui.board.addLabel = (text, position, fontSize) ->
    fontSize ?= 56
    element = parseElement("""
        <text x="0" y="#{fontSize / 2.8}" fill="rgb(0,0,0)" font-size="#{fontSize}"
                text-anchor="middle" transform="translate(#{position.x},#{position.y})"
                xmlns="http://www.w3.org/2000/svg" />
    """)
    element.textContent = text
    ui.boardDialog.appendChild(element)
    element
