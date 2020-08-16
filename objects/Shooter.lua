Shooter = GameObject:extend()

function Shooter:new(area, x, y, opts)
    Shooter.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

	self.hit_flash = false
	self.hp = opts.hp or 100
    self.w, self.h = 12, 6
	
    self.collider = self.area.world:newPolygonCollider(
    {self.w, 0, -self.w/2, self.h, -self.w, 0, -self.w/2, -self.h})

    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Enemy')
	
    self.collider:setFixedRotation(false)
    self.collider:setAngle(direction == -1 and 0 or math.pi)
    self.collider:setFixedRotation(true)
	
    self.v = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)


    self.timer:every(random(3, 5), function()
        self.area:addGameObject('PreAttackEffect', 
        self.x + 1.4*self.w*math.cos(self.collider:getAngle()), 
        self.y + 1.4*self.w*math.sin(self.collider:getAngle()), 
        {shooter = self, color = hp_color, duration = 1})
        self.timer:after(1, function()
			self.area:addGameObject('EnemyProjectile', 
            self.x + 1.4*self.w*math.cos(self.collider:getAngle()), 
            self.y + 1.4*self.w*math.sin(self.collider:getAngle()), 
            {r = math.atan2(current_room.player.y - self.y, current_room.player.x - self.x), 
             v = random(80, 100), s = 3.5})
        end)
    end)
end

function Shooter:draw()
    love.graphics.setColor(self.hit_flash and default_color or hp_color)
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    love.graphics.polygon('line', points)
    love.graphics.setColor(default_color)
end

function Shooter:hit(damage)
	
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

function Shooter:die()
	self.dead = true
	
	self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = self.w})
	self.area:addGameObject('Ammo', self.x, self.y) 
	
	current_room.score = current_room.score + 150
end