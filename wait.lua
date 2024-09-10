local _M = {}

function _M.check()
    local wait_time = 10 -- seconds

    if not ngx.var.cookie_wait_start then
        ngx.header["Set-Cookie"] = "wait_start=" .. ngx.time() .. "; path=/"
        ngx.header.content_type = "text/html"
        ngx.say([[
        <html>
        <head>
            <title>Please Wait</title>
            <style>
                body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #f0f0f0; }
                .container { text-align: center; background-color: white; padding: 2em; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
                #countdown { font-size: 2em; font-weight: bold; color: #4CAF50; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Please Wait</h1>
                <p>You will be redirected in <span id="countdown">10</span> seconds.</p>
            </div>
            <script>
                var timeLeft = 10;
                var countdownElement = document.getElementById('countdown');
                var countdownTimer = setInterval(function() {
                    timeLeft--;
                    countdownElement.textContent = timeLeft;
                    if (timeLeft <= 0) {
                        clearInterval(countdownTimer);
                        window.location.reload();
                    }
                }, 1000);
            </script>
        </body>
        </html>
        ]])
        ngx.exit(ngx.HTTP_OK)
    else
        local elapsed = ngx.time() - tonumber(ngx.var.cookie_wait_start)
        if elapsed < wait_time then
            ngx.sleep(wait_time - elapsed)
        end
    end
end

return _M
