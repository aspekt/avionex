leaderboard = {}

function loadLeaderboard() 


    co = coroutine.create(function ()
        local response = {}
        
            a,b,c = http.request{ 
                url = "http://kobot.mybluemix.net/api/killerskies", 
                sink = ltn12.sink.table(response),
                redirect = true
            }
        
            --[{"_id":"5a11f321d28a060050b0bd02","score":"100","initials":"DIE","country":"URU"}]
            response = table.concat(response)
            print(response)
            leaderboard = json.decode(response) -- Returns { 1, 2, 3, { x = 10 } }
            coroutine.yield()
      end)

      Timer.after(0.2, function() coroutine.resume(co) end)
      

end

function saveScore(initials)

    co = coroutine.create(function ()

        local response = {}
        
        local payload = "{\"initials\":\""..initials.."\",\"score\":"..score.."}"
        local response_body = { }

        print(payload)

        a,b,c = http.request{ 
            url = "http://kobot.mybluemix.net/api/killerskies", 
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json",
                ["Content-Length"] = payload:len()
            },
            source = ltn12.source.string(payload),
            sink = ltn12.sink.table(response_body)
        }
    end)

    Timer.after(0.5, function() coroutine.resume(co) end)
    


end


function drawLeaderboard()

	gfx.push("all")
	gfx.setNewFont("assets/octab-017.ttf", 40)

	local w = gfx:getWidth()
	local h = gfx:getHeight()

	gfx.push("all")
	
	love.graphics.setBlendMode("alpha")
    love.graphics.setColor(0, 0, 0, 190)
	love.graphics.rectangle('fill', w / 2 - 150, 180, 300, 480)
	
	love.graphics.setColor(0, 255, 0, 200)
	
	love.graphics.print('HALL  OF  FAME', w / 2 - 110, 200 )

	
	local i = 1
	while leaderboard[i] and i <= 10 do
		local score = leaderboard[i]
		love.graphics.print(i..".",  w / 2 - 100, 200 + (i * 40) )				
		love.graphics.print(score['initials'],  w / 2 - 50, 200 + (i * 40) )		
		love.graphics.print(score['score'],  w / 2 + 40 , 200 + (i * 40) )
        i = i + 1
	end
	gfx.pop()
	
	gfx.pop()

end
