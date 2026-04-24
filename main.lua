-- Papa Smurf Scripts Hub for Love2D
-- Clean Black UI with White Glow and Minimize functionality

ui = nil

function love.load()
	-- Window setup
	love.window.setTitle("Papa Smurf Scripts Hub")
	
	-- Create fonts with custom Starbim font
	titleFont = love.graphics.newFont("Starbim.ttf", 32)
	
	-- UI State
	ui = {
		x = 200,
		y = 150,
		width = 500,
		height = 600,
		isMinimized = false,
		isDragging = false,
		dragOffsetX = 0,
		dragOffsetY = 0,
		headerHeight = 60,
		buttonHeight = 45,
		buttonSpacing = 10,
		padding = 15,
	}
	

	
	-- Minimize button state
	ui.minimizeButton = {
		x = ui.x + ui.width - 55,
		y = ui.y + 5,
		width = 50,
		height = 50,
		hovered = false,
		active = false,
	}
	
	-- Resize handle state
	ui.isResizing = false
	ui.resizeHandleSize = 20
	ui.minWidth = 300
	ui.minHeight = 200
	
	-- Toggle switch state
	ui.desyncToggle = {
		enabled = false,
		x = ui.x + ui.padding,
		y = ui.y + ui.headerHeight + ui.padding,
		width = ui.width - ui.padding * 2,
		height = 50,
		hovered = false,
	}
	
	-- Scroll state
	ui.scrollOffset = 0
	ui.contentHeight = 0
	
	return ui
end

function love.update(dt)
	if not ui then return end
	
	local mx, my = love.mouse.getPosition()
	
	-- Update minimize button hover
	ui.minimizeButton.hovered = mx >= ui.minimizeButton.x and
		mx <= ui.minimizeButton.x + ui.minimizeButton.width and
		my >= ui.minimizeButton.y and
		my <= ui.minimizeButton.y + ui.minimizeButton.height
	
	-- Check if mouse is over resize handle
	local resizeX = ui.x + ui.width - ui.resizeHandleSize
	local resizeY = ui.y + ui.height - ui.resizeHandleSize
	local resizeHovered = mx >= resizeX and mx <= ui.x + ui.width and
		my >= resizeY and my <= ui.y + ui.height
	
	-- Change cursor if over resize handle (simple approach)
	if resizeHovered and not ui.isMinimized then
		love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
	else
		love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
	end
	
	-- Update toggle switch hover state
	if not ui.isMinimized then
		local toggleY = ui.y + ui.headerHeight + ui.padding + ui.scrollOffset
		ui.desyncToggle.hovered = mx >= ui.desyncToggle.x and mx <= ui.desyncToggle.x + ui.desyncToggle.width and
			my >= toggleY and my <= toggleY + 50
	else
		ui.desyncToggle.hovered = false
	end
end

function applyDesync(active)
	-- This only works in Roblox environments where sethiddenproperty exists.
	if type(sethiddenproperty) ~= "function" then
		print("Desync " .. (active and "activated" or "deactivated") .. " (placeholder)")
		return
	end

	local success, err = pcall(function()
		local Players = game:GetService("Players")
		local player = Players.LocalPlayer
		if not player then return end
		local character = player.Character or player.CharacterAdded:Wait()
		local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if HumanoidRootPart then
			sethiddenproperty(HumanoidRootPart, "NetworkIsSleeping", active)
		end
	end)

	if not success then
		print("Desync toggle error:", err)
	end
end

function love.draw()
	if not ui then return end
	
	love.graphics.clear(0.1, 0.1, 0.1)
	
	-- Draw main frame background with rounded corners
	love.graphics.setColor(0.06, 0.06, 0.06)
	drawRoundedRect(ui.x, ui.y, ui.width, 
		ui.isMinimized and ui.headerHeight or ui.height, 15)
	
	-- Draw glowing stroke
	drawRoundedRectStroke(ui.x, ui.y, ui.width,
		ui.isMinimized and ui.headerHeight or ui.height, 15, 4)
	
	-- Draw header background
	love.graphics.setColor(0.04, 0.04, 0.04)
	drawRoundedRect(ui.x, ui.y, ui.width, ui.headerHeight, 15)
	
	-- Draw title
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(titleFont)
	love.graphics.printf("Papa Smurf Scripts", ui.x + 15, ui.y + 12, ui.width - 80, "left")
	
	-- Draw minimize button
	drawButton(ui.minimizeButton, ui.isMinimized and "+" or "−", ui.minimizeButton.hovered)
	
	-- Draw scrollable content if not minimized
	if not ui.isMinimized then
		-- Draw content area background
		love.graphics.setColor(0.08, 0.08, 0.08)
		love.graphics.rectangle("fill", ui.x, ui.y + ui.headerHeight, ui.width, ui.height - ui.headerHeight)
		
		-- Set scissor for content clipping
		love.graphics.setScissor(ui.x, ui.y + ui.headerHeight, ui.width, ui.height - ui.headerHeight - ui.resizeHandleSize)
		
		-- Draw toggle switch with scroll offset
		local toggleY = ui.y + ui.headerHeight + ui.padding + ui.scrollOffset
		ui.desyncToggle.y = toggleY
		drawToggleSwitch(ui.desyncToggle, "Desync", ui.desyncToggle.enabled, ui.desyncToggle.hovered)
		
		-- Reset scissor
		love.graphics.setScissor()
		
		-- Draw resize handle
		local resizeX = ui.x + ui.width - ui.resizeHandleSize
		local resizeY = ui.y + ui.height - ui.resizeHandleSize
		love.graphics.setColor(0.4, 0.8, 1.0, 0.4)
		love.graphics.rectangle("fill", resizeX, resizeY, ui.resizeHandleSize, ui.resizeHandleSize)
		love.graphics.setColor(0.4, 0.8, 1.0, 0.7)
		love.graphics.line(resizeX + 5, resizeY + ui.resizeHandleSize - 5, 
			resizeX + ui.resizeHandleSize - 5, resizeY + 5)
		love.graphics.line(resizeX + 10, resizeY + ui.resizeHandleSize - 5,
			resizeX + ui.resizeHandleSize - 5, resizeY + 10)
	end
end

function drawButton(btn, text, hovered)
	-- Button background
	if hovered then
		love.graphics.setColor(0.2, 0.2, 0.2)
	else
		love.graphics.setColor(0.12, 0.12, 0.12)
	end
	
	love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height)
	
	-- Button border
	love.graphics.setColor(0.4, 0.8, 1.0, 0.5)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height)
	
	-- Button text
	love.graphics.setColor(0.4, 0.8, 1.0)
	love.graphics.printf(text, btn.x, btn.y + 12, btn.width, "center")
end

function drawToggleSwitch(toggle, label, enabled, hovered)
	-- Background container with rounded corners
	if hovered then
		love.graphics.setColor(0.12, 0.12, 0.12)
	else
		love.graphics.setColor(0.1, 0.1, 0.1)
	end
	
	drawRoundedRect(toggle.x, toggle.y, toggle.width, toggle.height, 10)
	
	-- Border with rounded corners
	love.graphics.setColor(0.4, 0.8, 1.0, 0.4)
	love.graphics.setLineWidth(2)
	
	-- Draw simplified rounded border
	local radius = 10
	love.graphics.line(toggle.x + radius, toggle.y, toggle.x + toggle.width - radius, toggle.y)
	love.graphics.line(toggle.x + radius, toggle.y + toggle.height, toggle.x + toggle.width - radius, toggle.y + toggle.height)
	love.graphics.line(toggle.x, toggle.y + radius, toggle.x, toggle.y + toggle.height - radius)
	love.graphics.line(toggle.x + toggle.width, toggle.y + radius, toggle.x + toggle.width, toggle.y + toggle.height - radius)
	
	love.graphics.circle("line", toggle.x + radius, toggle.y + radius, radius)
	love.graphics.circle("line", toggle.x + toggle.width - radius, toggle.y + radius, radius)
	love.graphics.circle("line", toggle.x + radius, toggle.y + toggle.height - radius, radius)
	love.graphics.circle("line", toggle.x + toggle.width - radius, toggle.y + toggle.height - radius, radius)
	
	-- Label text on the left
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(love.graphics.getFont())
	love.graphics.printf(label, toggle.x + 20, toggle.y + 12, toggle.width - 150, "left")
	
	-- Toggle switch on the right
	local switchX = toggle.x + toggle.width - 90
	local switchY = toggle.y + (toggle.height - 40) / 2
	local switchWidth = 80
	local switchHeight = 40
	local cornerRadius = 20
	
	-- Switch background with rounded corners
	if enabled then
		love.graphics.setColor(0.4, 0.8, 1.0, 0.7)
	else
		love.graphics.setColor(0.25, 0.25, 0.25)
	end
	
	drawRoundedRect(switchX, switchY, switchWidth, switchHeight, cornerRadius)
	
	-- Switch circle (toggle button) with glow
	local circleRadius = 16
	if enabled then
		-- Right position when enabled
		local circleX = switchX + switchWidth - circleRadius - 4
		-- Glow effect
		love.graphics.setColor(0.4, 0.8, 1.0, 0.3)
		love.graphics.circle("fill", circleX, switchY + switchHeight / 2, circleRadius + 4)
		-- Main circle
		love.graphics.setColor(1, 1, 1)
		love.graphics.circle("fill", circleX, switchY + switchHeight / 2, circleRadius)
	else
		-- Left position when disabled
		local circleX = switchX + circleRadius + 4
		-- Glow effect
		love.graphics.setColor(0.5, 0.5, 0.5, 0.2)
		love.graphics.circle("fill", circleX, switchY + switchHeight / 2, circleRadius + 4)
		-- Main circle
		love.graphics.setColor(0.7, 0.7, 0.7)
		love.graphics.circle("fill", circleX, switchY + switchHeight / 2, circleRadius)
	end
end

function drawScriptButton(x, y, width, height, text, hovered)
	-- Button background
	if hovered then
		love.graphics.setColor(0.16, 0.16, 0.16)
	else
		love.graphics.setColor(0.1, 0.1, 0.1)
	end
	
	love.graphics.rectangle("fill", x, y, width, height)
	
	-- Button border
	love.graphics.setColor(1, 1, 1, 0.3)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", x, y, width, height)
	
	-- Button text
	love.graphics.setColor(0.78, 0.78, 0.78)
	love.graphics.printf(text, x + 15, y + 12, width - 30, "left")
end

function drawRoundedRect(x, y, width, height, radius)
	-- Draw rounded rectangle using rectangles and circles
	local radius = math.min(radius, width / 2, height / 2)
	
	-- Center rectangles
	love.graphics.rectangle("fill", x + radius, y, width - radius * 2, height)
	love.graphics.rectangle("fill", x, y + radius, radius, height - radius * 2)
	love.graphics.rectangle("fill", x + width - radius, y + radius, radius, height - radius * 2)
	
	-- Corner circles
	love.graphics.circle("fill", x + radius, y + radius, radius)
	love.graphics.circle("fill", x + width - radius, y + radius, radius)
	love.graphics.circle("fill", x + radius, y + height - radius, radius)
	love.graphics.circle("fill", x + width - radius, y + height - radius, radius)
end

function drawRoundedRectStroke(x, y, width, height, radius, strokeWidth)
	-- Draw multiple strokes for glow effect
	local radius = math.min(radius, width / 2, height / 2)
	
	-- Outer glow layers (sky blue)
	for i = 1, 3 do
		love.graphics.setColor(0.4, 0.8, 1.0, 0.15 / i)
		love.graphics.setLineWidth(strokeWidth + i * 2)
		
		-- Draw lines for each side
		love.graphics.line(x + radius, y - strokeWidth/2, x + width - radius, y - strokeWidth/2)
		love.graphics.line(x + radius, y + height + strokeWidth/2, x + width - radius, y + height + strokeWidth/2)
		love.graphics.line(x - strokeWidth/2, y + radius, x - strokeWidth/2, y + height - radius)
		love.graphics.line(x + width + strokeWidth/2, y + radius, x + width + strokeWidth/2, y + height - radius)
		
		-- Draw circles for corners
		love.graphics.circle("line", x + radius, y + radius, radius)
		love.graphics.circle("line", x + width - radius, y + radius, radius)
		love.graphics.circle("line", x + radius, y + height - radius, radius)
		love.graphics.circle("line", x + width - radius, y + height - radius, radius)
	end
	
	-- Main stroke (bright sky blue)
	love.graphics.setColor(0.4, 0.8, 1.0, 0.8)
	love.graphics.setLineWidth(strokeWidth)
	
	love.graphics.line(x + radius, y, x + width - radius, y)
	love.graphics.line(x + radius, y + height, x + width - radius, y + height)
	love.graphics.line(x, y + radius, x, y + height - radius)
	love.graphics.line(x + width, y + radius, x + width, y + height - radius)
	
	love.graphics.circle("line", x + radius, y + radius, radius)
	love.graphics.circle("line", x + width - radius, y + radius, radius)
	love.graphics.circle("line", x + radius, y + height - radius, radius)
	love.graphics.circle("line", x + width - radius, y + height - radius, radius)
end

function love.mousepressed(x, y, button)
	if not ui then return end
	
	if button == 1 then
		-- Check resize handle
		if not ui.isMinimized then
			local resizeX = ui.x + ui.width - ui.resizeHandleSize
			local resizeY = ui.y + ui.height - ui.resizeHandleSize
			if x >= resizeX and x <= ui.x + ui.width and y >= resizeY and y <= ui.y + ui.height then
				ui.isResizing = true
				return
			end
		end
		
		-- Check minimize button
		if x >= ui.minimizeButton.x and x <= ui.minimizeButton.x + ui.minimizeButton.width and
			y >= ui.minimizeButton.y and y <= ui.minimizeButton.y + ui.minimizeButton.height then
			ui.isMinimized = not ui.isMinimized
		end
		
		-- Check if clicking on toggle switch
		if not ui.isMinimized then
			local toggleY = ui.y + ui.headerHeight + ui.padding + ui.scrollOffset
			if x >= ui.desyncToggle.x and x <= ui.desyncToggle.x + ui.desyncToggle.width and
				y >= toggleY and y <= toggleY + ui.desyncToggle.height then
				ui.desyncToggle.enabled = not ui.desyncToggle.enabled
				applyDesync(ui.desyncToggle.enabled)
				return
			end
		end
		
		-- Check if clicking on header to drag
		if x >= ui.x and x <= ui.x + ui.width and y >= ui.y and y <= ui.y + ui.headerHeight then
			ui.isDragging = true
			ui.dragOffsetX = x - ui.x
			ui.dragOffsetY = y - ui.y
			return
		end
		

	end
end

function love.mousereleased(x, y, button)
	if not ui then return end
	
	if button == 1 then
		ui.isDragging = false
		ui.isResizing = false
		

	end
end

function love.mousemoved(x, y)
	if not ui then return end
	
	if ui.isDragging then
		ui.x = x - ui.dragOffsetX
		ui.y = y - ui.dragOffsetY
		
		-- Update minimize button position
		ui.minimizeButton.x = ui.x + ui.width - 55
		ui.minimizeButton.y = ui.y + 5
		
		-- Update toggle switch position
		ui.desyncToggle.x = ui.x + ui.padding
	end
	
	if ui.isResizing then
		-- Calculate new width and height based on mouse position
		local newWidth = x - ui.x
		local newHeight = y - ui.y
		
		-- Enforce minimum size
		ui.width = math.max(newWidth, ui.minWidth)
		ui.height = math.max(newHeight, ui.minHeight)
		
		-- Update minimize button position
		ui.minimizeButton.x = ui.x + ui.width - 55
		ui.minimizeButton.y = ui.y + 5
		
		-- Update toggle switch width
		ui.desyncToggle.width = ui.width - ui.padding * 2
	end
end

function love.wheelmoved(x, y)
	if not ui or ui.isMinimized then return end
	
	-- Check if mouse is over content area
	local mx, my = love.mouse.getPosition()
	if mx >= ui.x and mx <= ui.x + ui.width and my >= ui.y + ui.headerHeight and my <= ui.y + ui.height then
		ui.scrollOffset = ui.scrollOffset - y * 20


	end
end
