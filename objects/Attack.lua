Attack = GameObject:extend()

function Attack:new(area, x, y, opts)
	Attack.super.new(self, area, x, y, opts)
	
	local direction = table.random({-1, 1})
	
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(48, gh - 48)

    self.w, self.h = 27, 27
	self.font = fonts.m5x7_16
	
	self.abbreviation_width = 0
	self.rnd_color = attacks[self.attack].rnd_color == true
	
	for i = 1, #attacks[self.attack].abbreviation do 
		self.abbreviation_width = self.abbreviation_width + self.font:getWidth(attacks[self.attack].abbreviation:utf8sub(i, i)) 
	end
	
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.v = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
end


function Attack:draw()
	if self.rnd_color then
		love.graphics.setColor(table.random(all_colors))
	else
		love.graphics.setColor(attacks[self.attack].color)
	end
	
    draft:rhombus(self.x, self.y, self.w, self.h, 'line')
	love.graphics.setFont(self.font)
	love.graphics.print(attacks[self.attack].abbreviation, self.x, self.y, 0, 1, 1, self.abbreviation_width / 2, self.font:getHeight()/2)
	love.graphics.setFont(standard_font)
	love.graphics.setColor(default_color)
    draft:rhombus(self.x, self.y, self.w-4, self.h-4, 'line')
end

function Attack:die()
	self.dead = true
	
	local attack_effect = attacks[self.attack]
	
	self.area:addGameObject('AttackEffect', self.x, self.y, {attack = self.attack, w = self.w, h = self.h})
	self.area:addGameObject('InfoText', self.x, self.y, {text = self.attack, color = not self.rnd_color and attack_effect.color or table.random(all_colors), w = self.w/5, h = self.h/5})
end