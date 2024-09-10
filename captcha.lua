local _M = {}

local function generate_captcha()
    math.randomseed(os.time())
    local num1 = math.random(1, 10)
    local num2 = math.random(1, 10)
    local answer = num1 + num2
    return num1, num2, answer
end

function _M.check()
    if not ngx.var.cookie_captcha_solved then
        local num1, num2, answer
        
        if ngx.var.cookie_captcha_answer then
            answer = tonumber(ngx.var.cookie_captcha_answer)
            num1, num2 = tonumber(ngx.var.cookie_captcha_num1), tonumber(ngx.var.cookie_captcha_num2)
        else
            num1, num2, answer = generate_captcha()
            ngx.header["Set-Cookie"] = {
                "captcha_answer=" .. answer .. "; path=/",
                "captcha_num1=" .. num1 .. "; path=/",
                "captcha_num2=" .. num2 .. "; path=/"
            }
        end
        
        if ngx.var.arg_captcha then
            if tonumber(ngx.var.arg_captcha) == answer then
                ngx.header["Set-Cookie"] = {
                    "captcha_solved=1; path=/",
                    "captcha_answer=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT",
                    "captcha_num1=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT",
                    "captcha_num2=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT"
                }
                return true
            else
                local error_message = "Incorrect CAPTCHA. Please try again."
                ngx.header.content_type = "text/html"
                ngx.say(string.format([[
                <html>
                <head>
                    <title>CAPTCHA Challenge</title>
                    <style>
                        body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #f0f0f0; }
                        .container { text-align: center; background-color: white; padding: 2em; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
                        input[type="text"] { font-size: 1em; padding: 0.5em; margin: 1em 0; }
                        input[type="submit"] { font-size: 1em; padding: 0.5em 1em; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
                        .error { color: red; margin-bottom: 1em; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <h1>CAPTCHA Challenge</h1>
                        <p class="error">%s</p>
                        <form method="get">
                            <p>What is %d + %d?</p>
                            <input type="text" name="captcha" autofocus>
                            <br>
                            <input type="submit" value="Submit">
                        </form>
                    </div>
                </body>
                </html>
                ]], error_message, num1, num2))
                return false
            end
        end

        ngx.header.content_type = "text/html"
        ngx.say(string.format([[
        <html>
        <head>
            <title>CAPTCHA Challenge</title>
            <style>
                body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #f0f0f0; }
                .container { text-align: center; background-color: white; padding: 2em; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
                input[type="text"] { font-size: 1em; padding: 0.5em; margin: 1em 0; }
                input[type="submit"] { font-size: 1em; padding: 0.5em 1em; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>CAPTCHA Challenge</h1>
                <form method="get">
                    <p>What is %d + %d?</p>
                    <input type="text" name="captcha" autofocus>
                    <br>
                    <input type="submit" value="Submit">
                </form>
            </div>
        </body>
        </html>
        ]], num1, num2))
        return false
    end
    return true
end

return _M
