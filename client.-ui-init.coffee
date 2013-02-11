initUIElements = ->
    codifyElement(ui, """
        <rect id="outsideInput" x="-2" y="-2" width="4" height="4" fill="rgba(0,0,0,0)"
                xmlns="http://www.w3.org/2000/svg" />
    """)
    codifyElement(ui, """
        <g id="board" xmlns="http://www.w3.org/2000/svg">
            <rect x="-512" y="-512" width="1024" height="1024" fill="rgb(219,179,119)" />
            <g id="boardLoads">
                <g id="boardGrid" />
                <g id="boardStones" />
                <g id="boardMarks" />
                <g id="boardActiveStoneReminder" opacity="0.25">
                    <rect x="-32" y="-32" width="64" height="64" fill="none" stroke="rgb(255,0,0)"
                            stroke-width="5" />
                </g>
            </g>
            <rect id="boardInput" x="-512" y="-512" width="1024" height="1024"
                    opacity="0" cursor="crosshair" />
            <g id="boardDialogContainer">
                <rect id="boardDialogBackground" x="-512" y="-512" width="1024" height="1024"
                        fill="rgb(224,224,224)" />
                <g id="boardDialog" />
            </g>
        </g>
    """)
    codifyElement(ui, """
        <radialGradient id="blackStoneGradient" r="0.5" xmlns="http://www.w3.org/2000/svg">
            <stop offset="0" stop-color="rgb(82,82,90)" />
            <stop offset="0.333" stop-color="rgb(74,74,82)" />
            <stop offset="0.667" stop-color="rgb(62,62,70)" />
            <stop offset="1" stop-color="rgb(44,44,52)" />
        </radialGradient>
    """)
    codifyElement(ui, """
        <radialGradient id="whiteStoneGradient" r="0.5" xmlns="http://www.w3.org/2000/svg">
            <stop offset="0" stop-color="rgb(238,238,246)" />
            <stop offset="0.333" stop-color="rgb(226,226,234)" />
            <stop offset="0.667" stop-color="rgb(206,206,214)" />
            <stop offset="0.834" stop-color="rgb(192,192,200)" />
            <stop offset="1" stop-color="rgb(170,170,178)" />
        </radialGradient>
    """)
    codifyElement(ui, """
        <symbol id="blackStone" viewBox="-64 -64 128 128" overflow="visible"
                xmlns="http://www.w3.org/2000/svg">
            <circle r="64" fill="rgb(128,128,136)" fill-opacity="0.625" stroke="rgb(48,48,56)"
                    stroke-width="7" />
            <circle r="56" fill="rgb(48,48,56)" />
        </symbol>
    """)
    codifyElement(ui, """
        <symbol id="whiteStone" viewBox="-64 -64 128 128" overflow="visible"
                xmlns="http://www.w3.org/2000/svg">
            <circle r="64" fill="rgb(238,238,246)" stroke="rgb(128,128,136)" stroke-width="7" />
        </symbol>
    """)
