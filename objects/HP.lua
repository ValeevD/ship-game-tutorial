HP = GameObject:extend()

function HP:new(area, x, y, opts)
	HP.super.new(self, area, x, y, opts)
	
	local direction = table.random({-1, 1})
	
	self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(48, gh - 48)

    self.w  = 16
	
	self.rect_w = 3/5 * self.w
	self.rect_h = 1/3 * self.rect_w
	
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
	
	self.v = -direction*random(20, 40)
	--self.collider:setFixedRotation(false)
	self.collider:setLinearVelocity(self.v, 0)
	--self.collider:applyAngularImpulse(random(-24, 24))	
end

function HP:update(dt)
	HP.super.update(self, dt)
	
	self.collider:setLinearVelocity(self.v, 0)
end

function HP:draw()
    love.graphics.setColor(hp_color)
    --pushRotate(self.x, self.y, self.collider:getAngle())
    draft:rectangle(self.x , self.y , self.rect_h, self.rect_w, 'fill')
	draft:rectangle(self.x , self.y , self.rect_w, self.rect_h, 'fill')
    --draft:rectangle(self.x - self.rect_w / 2, self.y - self.rect_h / 2, self.rect_w, self.rect_h, 'fill')
	love.graphics.setColor(default_color)
	draft:circle(self.x, self.y, self.w, nil, 'line')
    --love.graphics.pop()
    --love.graphics.setColor(default_color)
end

function HP:die()
	self.dead = true
	
	self.area:addGameObject('HPEffect', self.x, self.y, {color = hp_color, w = self.w, rect_w = self.rect_w, rect_h = self.rect_h})	
	self.area:addGameObject('InfoText', self.x, self.y, {text = '+25HP', color = hp_color, w = 12, h = 12})
	
	for i = 1, random(4, 8) do
		self.area:addGameObject('ExplodeParticle', self.x, self.y, {color = hp_color})
	end
end