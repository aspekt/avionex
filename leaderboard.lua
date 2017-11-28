leaderboard = {}

function loadLeaderboard() 

    request = wapi.request({
      method = "GET",
      url = "http://kobot.mybluemix.net/api/killerskies"
      }, function (body, headers, code)

        leaderboard = json.decode(body)
        print(body)
        
    end)

end

function saveScore(initials)

    local payload = "{\"initials\":\""..initials.."\",\"score\":"..score.."}"
    local args = {
        method = "POST",
        url = "http://kobot.mybluemix.net/api/killerskies",
        body = payload,
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = payload:len()
        }
    }

    print(json.encode(args))

    request = wapi.request(args, function (body, headers, code)
          print(body)
    end)

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
