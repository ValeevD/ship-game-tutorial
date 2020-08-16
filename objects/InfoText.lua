default_colors = {default_color, hp_color, ammo_color, boost_color, skill_point_color}
negative_colors = {
	{1-default_color[1], 1-default_color[2], 1-default_color[3]}, 
	{1-hp_color[1], 1-hp_color[2], 1-hp_color[3]}, 
	{1-ammo_color[1], 1-ammo_color[2], 1-ammo_color[3]}, 
	{1-boost_color[1], 1-boost_color[2], 1-boost_color[3]}, 
	{1-skill_point_color[1], 1-skill_point_color[2], 1-skill_point_color[3]}
}
	
all_colors = fn.append(default_colors, negative_colors)	
random_characters = '0123456789!@#$%¨&*()-=+[]^~/;?><.,|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'

InfoText = GameObject:extend()

function InfoText:new(area, x, y, opts)
	InfoText.super.new(self, area, x, y, opts)
	
	self.font = fonts.m5x7_16
	
	self.depth = 80
  	
    self.characters = {}
	
	self.background_colors = {}
    self.foreground_colors = {}
	
	self.w = self.w or 0
	self.h = self.h or 0
	self.color = self.color or default_color
	
	self.x = self.x + random(-self.w, self.w)
	self.y = self.y + random(-self.h, self.h)
	
    --self.all_colors = fn.append(default_colors, negative_colors)
	
    for i = 1, #self.text do table.insert(self.characters, self.text:utf8sub(i, i)) end
	
	self.visible = true
    self.timer:after(0.70, function()
        self.timer:every(0.05, function() self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)
				
		self.timer:every(0.035, function()
				--local random_characters = '0123456789!@#$%¨&*()-=+[]^~/;?><.,|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'
				for i, character in ipairs(self.characters) do
					if love.math.random(1, 5) <= 1 then
						local r = love.math.random(1, #random_characters)
						self.characters[i] = random_characters:utf8sub(r, r)
--					else
--						self.characters[i] = character
					end
					
					 if love.math.random(1, 20) <= 1 then
						self.background_colors[i] = table.random(all_colors)
					else
						self.background_colors[i] = nil
					end
				  
					if love.math.random(1, 10) <= 3 then
						self.foreground_colors[i] = table.random(all_colors)
					else
						self.background_colors[i] = nil
					end
				end
			end)
    end)

    self.timer:after(1.10, function() self.dead = true end)
end

function InfoText:draw()
	
	if not self.visible then return end
	
    love.graphics.setFont(self.font)
    for i = 1, #self.characters do
        local width = 0
        if i > 1 then
            for j = 1, i-1 do
                width = width + self.font:getWidth(self.characters[j])
            end
        end

        love.graphics.setColor(self.color)
        love.graphics.print(self.characters[i], self.x + width, self.y, 
      	0, 1, 1, 0, self.font:getHeight()/2)
	
		if self.background_colors[i] then
      	    love.graphics.setColor(self.background_colors[i])
      	    love.graphics.rectangle('fill', self.x + width, self.y - self.font:getHeight()/2,
      	    self.font:getWidth(self.characters[i]), self.font:getHeight())
      	end
    	love.graphics.setColor(self.foreground_colors[i] or self.color or default_color)
    	love.graphics.print(self.characters[i], self.x + width, self.y, 
      	0, 1, 1, 0, self.font:getHeight()/2)
    end
	
	love.graphics.setFont(standard_font)
    love.graphics.setColor(default_color)
end