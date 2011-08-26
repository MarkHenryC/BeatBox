-- slider.lua
-- Mark Carolan 2010

module(..., package.seeall)

function newSlider(params)
	local p = params or {}
	
	local g = display.newGroup()	
	
	local back = display.newRect(0, 0, p.width or 120, p.height or 32)	
	g:insert(back)
	back:setFillColor(0, 0, 200)
	back.strokeWidth = 3
	back:setStrokeColor(128, 128, 128)
	
	local button = display.newRect(0, 0, p.buttonWidth or 32, p.buttonHeight or 34)		
	g:insert(button)
	button:setFillColor(0, 200, 0)
	button.strokeWidth = 3
	button:setFillColor(200, 200, 200)
	
	local leftLimit = back.x-back.width/2
	local rightLimit = back.x+back.width/2
	button.x = leftLimit
	
	g.x = params.x or 160
	g.y = p.y or 280
	
	button.y = button.y-1
	
	local currentXReading = leftLimit
	local callbackFunc = p.callbackFunc
	
	button:addEventListener("touch", g)
	
	local touching = false
	
	function g:touch(event)
		if event.phase == "began" then
			display.getCurrentStage():setFocus(button)
			touching = true
		elseif event.phase == "moved" then
			local movementX = event.x - event.xStart
			local posX = currentXReading + movementX
			event.target.x = posX 
			if event.target.x < leftLimit then
				event.target.x = leftLimit
			elseif event.target.x > rightLimit then
				event.target.x = rightLimit
			end
			
			local val = event.target.x
			callbackFunc(val / back.width) -- value 0.0 .. 1.0
		elseif event.phase == "ended" then
			currentXReading = button.x
			display.getCurrentStage():setFocus(nil)
			touching = false
		end
		return true
	end
	
	function g:set(f) -- 0.0 .. 1.0
		if not touching then			
			currentXReading = leftLimit + f * back.width
			button.x = currentXReading
		end
	end
	
	g:setReferencePoint(display.CenterReferencePoint)
	
	return g
end
	
	