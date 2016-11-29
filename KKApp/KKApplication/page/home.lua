
log("home.lua")

return function(app,obs)
	
	http:send({
		method="GET",
		url="http://kkmofang.cn/job/?id=1",
		type="text",
		onload = function(data)
			log(data)
		end,
		onfail = function(err)
			log(err)
		end,
		onresponse = function(response)
			log(response.headers["Content-Type"])
		end
	})

	log(obs.get({"app","title"}))

end

