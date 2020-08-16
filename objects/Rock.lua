Rock = GameObject:extend()

function Rock:new(area, x, y, opts)
    Rock.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.w, self.h = 8, 8
	self.hit_flash = false
	
	self.hp = opts.hp or 100
    self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(8))
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFixedRotation(false)
    self.v = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-100, 100))
end

function Rock:draw()
    love.graphics.setColor(self.hit_flash and default_color or hp_color)
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    love.graphics.polygon('line', points)
    love.graphics.setColor(default_color)
end

function Rock:hit(damage)
	
	--print(self.hp)
	self.hp = self.hp - (damage or 100)
	
	if self.hp <= 0 then
		self.hp = 0
		self:die()
	else
		self.hit_flash = true
		self.timer:after(0.2, function() self.hit_flash = false end)
	end
end

function Rock:die()
	self.dead = true
	
	self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = self.w})
	self.area:addGameObject('Ammo', self.x, self.y) 
	
	current_room.score = current_room.score + 100
end