httpModule = require("http")
urlModule = require("url")
fsModule = require("fs")
httpModule.createServer((request, response) ->
    checkError = (error) -> if error? then throw error
    try
        url = urlModule.parse(request.url, true)
        switch url.pathname
            when "/"
                response.writeHead(200, {"Content-Type": "application/xhtml+xml"})
                response.end("""
                    <!DOCTYPE html>
                    <html xmlns="http://www.w3.org/1999/xhtml">
                        <head>
                            <title>test title</title>
                        </head>
                        <body>
                            This is a test page!
                        </body>
                    </html>
                """)
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
            else
                response.writeHead(404, {"Content-Type": "application/xhtml+xml"})
                response.end("""
                    <!DOCTYPE html>
                    <html xmlns="http://www.w3.org/1999/xhtml">
                        <head>
                            <title>404 not found</title>
                        </head>
                        <body>
                            404 not found
                        </body>
                    </html>
                """)
    catch error
        response.writeHead(500, {"Content-Type": "application/xhtml+xml"})
        response.end("""
            <!DOCTYPE html>
            <html xmlns="http://www.w3.org/1999/xhtml">
                <head>
                    <title>500 internal error</title>
                </head>
                <body>
                    500 internal error
                </body>
            </html>
        """)
).listen(process.env.VMC_APP_PORT or 1337, null)
