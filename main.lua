-- Mark H Carolan
-- 2011
-- Skeleton for a beatbox project
-- 1 hour Corona project (except for slider)

require "slider"

local MIN = 60000
local BPM_RANGE = 240
local BPB = 4

local function newButtonGrid(params)
	local x = params.xUnits or 16
	local y = params.yUnits or 4
	local w = params.width or 26
	local h = params.height or 32
	local fillCol = params.fillCol or {128, 0, 0}
	local borderCol = params.borderCol or {96, 96, 96}
	local borderW = params.borderW or 4
	local onCol = {0, 255, 0}
	
	local grid = display.newGroup()
	
	local bar = {}
	
	local function newTouchHandler(x, y)
		return function(event)
			if event.phase == "ended" then
				local b = bar[x][y]
				if b == 0 then -- togggle on
					event.target:setFillColor(onCol[1], onCol[2], onCol[3])
					bar[x][y] = 1
				else
					event.target:setFillColor(fillCol[1], fillCol[2], fillCol[3])
					bar[x][y] = 0
				end
			end
		end
	end
	
	-- column-major order
	for i = 1, x do
		local slot = {}
		for j = 1, y do
			local b = display.newRect(0, 0, w, h)
			b:setFillColor(fillCol[1], fillCol[2], fillCol[3])
			b:setStrokeColor(borderCol[1], borderCol[2], borderCol[3])
			b.strokeWidth = borderW
			grid:insert(b)
			b.x = (i-1) * w
			b.y = (j-1) * h
			b:addEventListener("touch", newTouchHandler(i, j))
			slot[#slot+1] = 0
		end
		bar[#bar+1] = slot
	end
	
	grid.bar = bar
	
	return grid
end

local function newBeatbox(_bpmScale)
	local beatbox = {}
	
	local bpmScale = _bpmScale or 0.5
	local bpm = bpmScale * BPM_RANGE
	local bar_len_ms = (MIN/bpm)*BPB
	
	local prevTime = 0
	local curSlot = 0
	
	local grid = newButtonGrid{}
	grid:setReferencePoint(display.CenterReferencePoint)
	grid.x = display.contentCenterX
	grid.y = display.contentCenterY

	local bar = grid.bar
	local bar_slots = #bar
	
	local resolution = bar_len_ms/#bar
	
	local sources = 
	{
	"hhat.caf",
	"snare.caf",
	"ride.caf",
	"kick.caf",
	}
	
	local sounds = {}
	
	local channels = #sources

	for i = 1, #sources do
		sounds[#sounds+1] = audio.loadSound(sources[i])
	end
	
	function beatbox:start()		
		Runtime:addEventListener("enterFrame", self)	
	end
	
	function beatbox:stop()
		Runtime:removeEventListener("enterFrame", self)	
	end
	
	function beatbox:enterFrame(event)
		local curTime = system.getTimer()
		if curTime-prevTime >= resolution then
			curSlot = curSlot+1
			if curSlot > bar_slots then
				curSlot = 1
			end
			local slot = bar[curSlot]
			for i = 1, channels do
				local vol = slot[i]
				if vol > 0 then
					audio.play(sounds[i])
				end
			end
			prevTime = curTime
		end
	end
	
	local function setBPM(amt)
		bpm = amt * BPM_RANGE
		bar_len_ms = (MIN/bpm)*BPB
		resolution = bar_len_ms/#bar
	end
	
	local slider = slider.newSlider{callbackFunc = setBPM}
	slider.y = 48
	slider.x = display.contentCenterX
	slider:set(bpmScale)
	
	return beatbox
end

local function newStartStopButton(params)

	local button = display.newRect(0, 0, params.width or 64, params.height or 48)
	button:setFillColor(0, 255, 0)
	button:setStrokeColor(96, 96, 96)
	button.strokeWidth = 3	
	
	button:setReferencePoint(display.CenterReferencePoint)
	button.x = display.contentCenterX
	button.y = display.contentHeight - 48
	
	button.target = params.target
	
	button.playing = false
	
	function button:touch(event)
		if event.phase == "ended" then
			self.playing = not self.playing
			if self.playing then
				self:setFillColor(255, 0, 0)
				self.target:start()
			else
				self:setFillColor(0, 255, 0)
				self.target:stop()
			end
		end
	end

	button:addEventListener("touch", button)
	
	return button
end

local bb = newBeatbox()
local ssb = newStartStopButton{target = bb}

				
			