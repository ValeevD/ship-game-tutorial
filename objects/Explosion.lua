Explosion = GameObject:extend()

function Explosion:new(area, x, y, opts)
	Explosion.super.new(self, area, x, y, opts)
	
	self.s = opts.s or 60
	
	if self.area_multiplier then
		self.s = self.s * self.area_multiplier
	end
	
	
	--print(self.area_multiplier)
	self.color = opts.color or hp_color
	self.cur_r = 0
	self.cur_color = default_color
	
	self.timer:tween(0.15, self, {cur_r = self.s}, 'in-out-cubic', function()
			self.timer:tween(0.15, self, {cur_r = 0}, 'out-cubic', function()
				self:die()
			end)
			self.cur_color = self.color
			self:killAllEnemies()
		end)
	--self.timer:after(0.5, function() self:die() end)
	
	
end

function Explosion:update(dt)
	Explosion.super.update(self, dt)
end

function Explosion:draw()
	love.graphics.setColor(self.cur_color)
	--if self.cur_r >= self.s * 0.6 then
	--if table.random({false, true}) then
		--draft:square(self.x, self.y, self.cur_r, 'fill')
	--else
		--draft:circle(self.x, self.y, self.cur_r/2, nil, 'fill')
		love.graphics.circle('fill', self.x, self.y, self.cur_r/2)
	--end
	love.graphics.setColor(default_color)
end

function Explosion:die()
	self.dead = true
	
    for i = 1, love.math.random(12, 16) do 
    	self.area:addGameObject('ExplodeParticle', self.x, self.y, {s = 3, color = self.color}) 
    end
	
end

function Explosion:killAllEnemies()
	local objects_to_kill = self.area:getAllGameObjectsThat(function(e) 
			for _, enemy in ipairs(enemies) do
				--print(distance(self.x, self.y, e.x, e.y), self.s)
				if e:is(_G[enemy]) and distance(e.x, e.y, self.x, self.y) <= self.s / 2 then					
					return true
				end
			end
		end)
	
	--print(ojects_to_kill)
	
	--if objects_to_kill then
		--print(#objects_to_kill)
		for i = 1, #objects_to_kill do
			objects_to_kill[i]:die()
		end
	--end
end