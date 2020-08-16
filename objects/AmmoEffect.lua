AmmoEffect = GameObject:extend()

function AmmoEffect:new(area, x, y, opts)
	AmmoEffect.super.new(self, area, x, y, opts)
	
	
	self.current_color = default_color
	
	self.timer:after(0.1, function()
		self.current_color = self.color
		
		self.timer:after(0.15, function()
			self.dead = true            
		end)
    end)
end

function AmmoEffect:update(dt)
	AmmoEffect.super.update(self, dt)
end

function AmmoEffect:draw()
--	if self.first then 
--		love.graphics.setColor(default_color)
--	elseif self.second then 
--		love.graphics.setColor(self.color) 
--	end

    love.graphics.setColor(ammo_color)
    pushRotate(self.x, self.y, self.r)
    draft:rhombus(self.x, self.y, self.w, self.h, 'fill')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end