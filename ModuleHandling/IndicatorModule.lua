local INDICATOR_SIZE = 15

local _G = _G
local PitBull4 = _G.PitBull4

local IndicatorModule = PitBull4:NewModuleType("indicator", {
	size = 1,
	attach_to = "root",
	location = "edge_top_left",
	position = 1,
	side = false,
	enabled = true,
	text_font = nil,
	text_size = 1,
})

--- Call the :GetTexture function on the indicator module regarding the given frame.
-- @param self the module
-- @param frame the frame to get the texture of
-- @usage local tex, c1, c2, c3, c4 = call_texture_function(MyModule, someFrame)
-- @return texture the path to the texture to show
local function call_texture_function(self, frame)
	if not self.GetTexture then
		-- no function, let's just return
		return nil
	end
	local tex
	if frame.guid then
		tex = self:GetTexture(frame)
	end
	if not tex and PitBull4.config_mode and self.GetExampleTexture then
		tex = self:GetExampleTexture(frame)
	end
	if not tex then
		return nil
	end
	
	return tex
end

--- Call the :GetTexCoord function on the indicator module regarding the given frame.
-- @param frame the frame to get the TexCoord of
-- @param texture the texture as returned by call_texture_function
-- @usage local c1, c2, c3, c4 = call_tex_coord_function(MyModule, someFrame, "SomeTexture")
-- @return left TexCoord for left within [0, 1]
-- @return right TexCoord for right within [0, 1]
-- @return top TexCoord for top within [0, 1]
-- @return bottom TexCoord for bottom within [0, 1]
local function call_tex_coord_function(self, frame, texture)
	if not self.GetTexCoord then
		-- no function, let's just return the defaults
		return 0, 1, 0, 1
	end
	local c1, c2, c3, c4 = self:GetTexCoord(frame, texture)
	if not c4 and PitBull4.config_mode and self.GetExampleTexCoord then
		c1, c2, c3, c4 = self:GetExampleTexCoord(frame, texture)
	end
	if not c4 then
		return 0, 1, 0, 1
	end
	
	return c1, c2, c3, c4
end
--- Clear the indicator for the current module if it exists.
-- @param frame the Unit Frame to clear
-- @usage local update_layout = MyModule:ClearFrame(frame)
-- @return whether the update requires :UpdateLayout to be called
function IndicatorModule:ClearFrame(frame)
	--@alpha@
	expect(frame, 'typeof', 'frame')
	--@end-alpha@
	
	local id = self.id
	local control = frame[id]
	if not control then
		return false
	end
	
	frame[id] = control:Delete()
	return true
end

--- Update the indicator for the current module.
-- @param frame the Unit Frame to update
-- @usage local update_layout = MyModule:UpdateFrame(frame)
-- @return whether the update requires :UpdateLayout to be called
function IndicatorModule:UpdateFrame(frame)
	--@alpha@
	expect(frame, 'typeof', 'frame')
	--@end-alpha@
	
	local tex = call_texture_function(self, frame)
	if not tex then
		return self:ClearFrame(frame)
	end
	
	local id = self.id
	local control = frame[id]
	local made_control = not control
	if made_control then
		control = PitBull4.Controls.MakeIcon(frame)
		control:SetFrameLevel(frame:GetFrameLevel() + 3)
		frame[id] = control
		control:SetWidth(INDICATOR_SIZE)
		control:SetHeight(INDICATOR_SIZE)
	end
	
	control:SetTexture(tex)
	
	control:SetTexCoord(call_tex_coord_function(self, frame, tex))
	
	return made_control
end

--- Return the font and size to use for the given frame.
-- @param frame the unit frame
-- @return the font path
-- @return the font size
-- @usage local font, size = MyModule:GetFont(some_frame)
-- some_frame.MyModule:SetFont(font, size)
function IndicatorModule:GetFont(frame)
	local db = self:GetLayoutDB(frame)
	return frame:GetFont(db.text_font, db.text_size)
end