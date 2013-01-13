httpModule = require("http")
urlModule = require("url")
fsModule = require("fs")
httpModule.createServer((request, response) ->
    checkError = (error) -> if error? then throw error
    try
        url = urlModule.parse(request.url, true)
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
                                    对不起，您的浏览器太旧了，访问被禁止。本应用使用的某些新技术并不支持IE 6/7/8/9。建议至少使用IE 10，或者其他品牌非IE内核的浏览器。
                                </p>
                                <p>
                                    IE 10: 支持。<br />
                                    Chrome: 支持。<br />
                                    Firefox: 支持。<br />
                                    Safari: 支持。<br />
                                    iPad: 支持。<br />
                                    iPhone: 支持。<br />
                                    Android 4.0 Chrome: 支持。<br />
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
            when "/wei7spec.pdf"
                fsModule.readFile("wei7spec.pdf", (error, data) ->
                    checkError(error)
                    response.writeHead(200, {"Content-Type": "application/pdf"})
                    response.end(data)
                )
            when "/client.js"
                fsModule.readFile("client.js", (error, data) ->
                    checkError(error)
                    response.writeHead(200, {"Content-Type": "application/javascript"})
                    response.end(data)
                )
            when "/wood.jpg"
                fsModule.readFile("wood.jpg", (error, data) ->
                    checkError(error)
                    response.writeHead(200, {"Content-Type": "image/jpeg"})
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
).listen(process.env.VMC_APP_PORT or 1337, null)
