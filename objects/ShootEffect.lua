ShootEffect = GameObject:extend()

function ShootEffect:new(area, x, y, opts)
    ShootEffect.super.new(self, area, x, y, opts)
    self.w = opts.w or 8
	self.min_w = opts.min_w or 0
	
	self.effect_duration = opts.effect_duration or 0.1
	self.color = opts.color or default_color
	self.cur_color = default_color
	
	self.timer:after(self.effect_duration/2, function() self.cur_color = self.color end)
	
    self.timer:tween(self.effect_duration, self, {w = self.min_w}, 'in-out-cubic', function() self.dead = true end)
	
	--self.depth = 100
	--print(self.oName..' '..self.x..", "..self.y)
end

function ShootEffect:update(dt)
    ShootEffect.super.update(self, dt)
    if self.player then 
    	self.x = self.player.x + self.d*math.cos(self.player.r) 
    	self.y = self.player.y + self.d*math.sin(self.player.r) 
  	end
	
	--print(self.oName)
end

function ShootEffect:draw()
	--pushRotate(self.player.x, self.player.y, math.pi/2)
    pushRotate(self.x, self.y, (self.player and self.player.r or self.r) + math.pi/4)
	--pushRotateScale(self.x, self.y, self.player.r + math.pi/4, self.w / 8, self.w / 8)
    love.graphics.setColor(self.cur_color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - self.w/2, self.w, self.w)
    love.graphics.pop()
	--love.graphics.pop()
	
	--love.graphics.print(self.oName..self.x..", "..self.y, self.x, self.y)
end

