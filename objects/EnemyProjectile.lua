EnemyProjectile = GameObject:extend()

function EnemyProjectile:new(area, x, y, opts)
	EnemyProjectile.super.new(self, area, x, y, opts)
	
	--print(self.area)
	
	self.s = opts.s or 2.5
	self.v = opts.v or 200
	
	self.damage = 10
	
	--self.color = self.color or attacks[self.attack].color

	self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
	self.collider:setObject(self)
	
	self.collider:setCollisionClass('EnemyProjectile')
	
	self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
end

function EnemyProjectile:update(dt)
    EnemyProjectile.super.update(self, dt)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
	
    if self.x - self.s < 0 then self:die() end
    if self.y - self.s < 0 then self:die() end
    if self.x + self.s > gw then self:die() end
    if self.y + self.s > gh then self:die() end	
	
	if self.collider:enter('Player') then
		local collision_data = self.collider:getEnterCollisionData('Player')
        local object = collision_data.collider:getObject()
		
		if not object then
			return
		end
		
		if object:is(Player) then
			object:hit(self.damage)
			self:die()
		end
	elseif self.collider:enter('Projectile') then
		local collision_data = self.collider:getEnterCollisionData('Projectile')
        local object = collision_data.collider:getObject()	
		
		if not object then
			return
		end
		
		if object:is(Projectile) then
			--object:hit(attacks[self.attack].damage)
			object:die()
			self:die()
		end
	end
end

function EnemyProjectile:draw()
    love.graphics.setColor(hp_color)
    pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo()) 
    love.graphics.setLineWidth(self.s - self.s/4)
    love.graphics.line(self.x - 2*self.s, self.y, self.x, self.y)
    love.graphics.line(self.x, self.y, self.x + 2*self.s, self.y)
	love.graphics.setColor(default_color)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
end

function EnemyProjectile:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, 
    {color = hp_color, w = 3*self.s})
end