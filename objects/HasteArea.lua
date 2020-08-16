HasteArea = GameObject:extend()

function HasteArea:new(area, x, y, opts)
	HasteArea.super.new(self, area, x, y, opts)
	
    self.r = 0
	self.area_multiplier = opts.area_multiplier or current_room.player.area_multiplier or 1
	
	self.timer:tween(1, self, {r = random(64, 96)*self.area_multiplier}, 'out-in-quad')
	
    self.timer:after(5, function()
        self.timer:tween(1, self, {r = 0}, 'in-out-cubic', function() self.dead = true end)
    end)	
end

function HasteArea:update(dt)
	HasteArea.super.update(self, dt)
	

    local player = current_room.player
    if not player then return end
    local d = distance(self.x, self.y, player.x, player.y)
    if d < self.r then player.inside_haste_area = true
    elseif d >= self.r then player.inside_haste_area = false end

end

function HasteArea:draw()
    love.graphics.setColor(ammo_color)
    love.graphics.circle('line', self.x, self.y, self.r)
    love.graphics.setColor(default_color)
end