httpModule = require("http")
urlModule = require("url")
fsModule = require("fs")
httpModule.createServer((request, response) ->
    checkError = (error) -> if error? then throw error
    try
        url = urlModule.parse(request.url, true)
        if request.headers["host"] == "www.wei7.com"
            response.writeHead(301, {"Location": "//wei7.com#{url.pathname}"})
            response.end()
            return
        switch url.pathname
            when "/"
                userAgent = request.headers["user-agent"]
                if /// MSIE \x20 [6789]\.0 ///.test(userAgent)
                    response.writeHead(403, {"Content-Type": "text/html"})
                    response.end("""
                        <!DOCTYPE html>
                        <html xmlns="http://www.w3.org/1999/xhtml">
                            <head>
                                <meta http-equiv="content-type" content="text/html; charset=utf-8" />
                                <title>403 forbidden</title>
                            </head>
                            <body>
                                <p>
                                    wei7.com是一个有关围棋的应用。本应用是为了对现有的中文围棋应用作适当的补充，使移动平台和最新桌面平台能够提供统一和优质的围棋体验。
                                </p>
                                <p>
                                    对不起，您的浏览器太旧了，访问被禁止。本应用使用的某些新技术并不支持IE 6/7/8/9。
                                </p>
                                <p>
                                    如果您使用360或搜狗浏览器，请务必更新到最新版，并切换到<b>极速/高速</b>模式，不要使用兼容模式。
                                </p>
                                <p>
                                    如果您用IE10从百度跳转至wei7.com，可能会遇到此页面，这是由于百度仍然使用IE7兼容模式，您只需<a href=".">点击这里</a>便可解决此问题。
                                </p>
                                <p>
                                    IE 10: 支持。<br />
                                    Chrome: 支持。<br />
                                    Firefox: 支持。<br />
                                    Safari: 支持。<br />
                                    360浏览器(极速模式): 支持。<br />
                                    搜狗浏览器(高速模式): 支持。<br />
                                    iPad: 支持。<br />
                                    iPhone: 支持。<br />
                                    Android 4.0 (Chrome): 支持。<br />
                                    Windows Phone 8: 支持。
                                </p>
                            </body>
                        </html>
                    """)
                else
                    fsModule.readFile("client.xhtml", (error, data) ->
                        checkError(error)
                        response.writeHead(200, {"Content-Type": "application/xhtml+xml"})
                        response.end(data)
                    )
                ###
            when "/insertzzztest"
                mongoModule.connect(mongoURL, (err, conn) ->
                    conn.collection("things", (err, coll) ->
                        coll.insert({time: {$date: 1362242631012}}, {safe: true}, (err) ->
                            response.writeHead(200, {"Content-Type": "text/html"})
                            response.end("<html><body>insert success</body></html>")
                        )
                    )
                )
                ###
            when "/logo-16.ico"
                fsModule.readFile("logo-16.ico", (error, data) ->
                    checkError(error)
                    response.writeHead(200, {"Content-Type": "image/x-icon"})
                    response.end(data)
                )
            when "/help.pdf"
                fsModule.readFile("help.pdf", (error, data) ->
                    checkError(error)
                    response.writeHead(200, {"Content-Type": "application/pdf"})
                    response.end(data)
                )
            when "/tutorial.wei7"
                fsModule.readFile("tutorial.wei7", (error, data) ->
                    checkError(error)
                    response.writeHead(200, {"Content-Type": "application/json"})
                    response.end(data)
                )
            when "/client.js"
                fsModule.readFile("client.js", (error, data) ->
                    checkError(error)
                    response.writeHead(200, {"Content-Type": "application/javascript"})
                    response.end(data)
                )
            else
                response.writeHead(404, {"Content-Type": "text/html"})
                response.end("""
                    <!DOCTYPE html>
                    <html xmlns="http://www.w3.org/1999/xhtml">
                        <head>
                            <meta http-equiv="content-type" content="text/html; charset=utf-8" />
                            <title>404 not found</title>
                        </head>
                        <body>
                            请求的资源不存在。
                        </body>
                    </html>
                """)
    catch error
        response.writeHead(500, {"Content-Type": "text/html"})
        response.end("""
            <!DOCTYPE html>
            <html xmlns="http://www.w3.org/1999/xhtml">
                <head>
                    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
                    <title>500 internal error</title>
                </head>
                <body>
                    内部错误。
                </body>
            </html>
        """)
).listen(40000, "127.0.0.1")
