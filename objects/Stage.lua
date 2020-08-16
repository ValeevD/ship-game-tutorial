Stage = Object:extend()

function Stage:new()
	self.area = Area(self)
	self.area:addPhysicsWorld()
	
	self.area.world:addCollisionClass('Player')
	self.area.world:addCollisionClass('Enemy', {ignores = {'Player', 'Enemy'}})
	self.area.world:addCollisionClass('ExplodeParticle', {ignores = {'Enemy', 'Player'}})
    self.area.world:addCollisionClass('Projectile', {ignores = {'Projectile', 'Player', 'Enemy'}})
    self.area.world:addCollisionClass('Collectable', {ignores = {'Player', 'ExplodeParticle', 'Projectile', 'Collectable', 'Enemy'}})
	self.area.world:addCollisionClass('EnemyProjectile', {ignores = {'EnemyProjectile', 'Projectile', 'Enemy', 'Collectable'}})
	--self.area.world:addCollisionClass('Explosion', {ignores = {})
	
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    self.font = fonts.m5x7_16
	
	self.score = 0

	self.player = self.area:addGameObject('Player', gw/2, gh/2)
	
	self.director = Director(self)
	
	return self
end

function Stage:update(dt)
	self.director:update(dt)
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
	
    self.area:update(dt)
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
	
	--love.graphics.print('Round #'..self.director.difficulty..'; t: '..self.director.round_timer)
	--love.graphics.print('Game objects count: '..#self.area.game_objects)
  	camera:attach(0, 0, gw, gh)
	--love.graphics.circle('line', gw/2, gh/2, 50)
	self.area:draw()
  	camera:detach()
	
	
	-- Score
	love.graphics.setColor(default_color)
	love.graphics.print(self.score, gw - 20, 10, 0, 1, 1,
	math.floor(self.font:getWidth(self.score)), self.font:getHeight()/2)
	love.graphics.setColor(1, 1, 1)	
	
	love.graphics.setColor(skill_point_color)
	love.graphics.print(self.player.sp, 20, 10, 0, 1, 1,
	math.floor(self.font:getWidth(self.player.sp)), self.font:getHeight()/2)
	love.graphics.setColor(1, 1, 1)	
	
	
        -- HP
	local r, g, b = unpack(self.player.energy_shield and default_color or hp_color)
	local hp, max_hp = self.player.hp, self.player.max_hp
	local title = self.player.energy_shield and 'ES' or 'HP'
	
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle('fill', gw/2 - 52, gh - 16, 48*(hp/max_hp), 4)
	love.graphics.setColor(r - 32/255, g - 32/255, b - 32/255)
	love.graphics.rectangle('line', gw/2 - 52, gh - 16, 48, 4)
	
	love.graphics.print(title, gw/2 - 52 + 22, gh - 24, 0, 1, 1,
	math.floor(self.font:getWidth(title )/2), math.floor(self.font:getHeight()/2))
	
	love.graphics.print(hp .. '/' .. max_hp, gw/2 - 52 + 18, gh - 6, 0, 1, 1,
    math.floor(self.font:getWidth(hp .. '/' .. max_hp)/2),
    math.floor(self.font:getHeight()/2))

		--AMMO
		
	local r, g, b = unpack(ammo_color)
	local ammo, max_ammo = self.player.ammo, self.player.max_ammo
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle('fill', gw/2 - 52, 16, 48*(ammo/max_ammo), 4)
	love.graphics.setColor(r - 32/255, g - 32/255, b - 32/255)
	love.graphics.rectangle('line', gw/2 - 52, 16, 48, 4)
	
	love.graphics.print('AMMO', gw/2 - 52 + 10, 28, 0, 1, 1,
	math.floor(self.font:getWidth('HP')/2), math.floor(self.font:getHeight()/2))
	
	love.graphics.print(math.ceil(ammo) .. '/' .. max_ammo, gw/2 - 52 + 18, 6, 0, 1, 1,
    math.floor(self.font:getWidth(math.ceil(ammo).. '/' .. max_ammo)/2),
    math.floor(self.font:getHeight()/2))


		--BOOST
		
	local r, g, b = unpack(boost_color)
	local boost, max_boost = self.player.boost, self.player.max_boost
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle('fill', gw/2 , 16, 48*(boost/max_boost), 4)
	love.graphics.setColor(r - 32/255, g - 32/255, b - 32/255)
	love.graphics.rectangle('line', gw/2 , 16, 48, 4)
	
	love.graphics.print('BOOST', gw/2  + 10, 28, 0, 1, 1,
	math.floor(self.font:getWidth('HP')/2), math.floor(self.font:getHeight()/2))
	
	love.graphics.print(math.floor(boost) .. '/' .. max_boost, gw/2  + 18, 6, 0, 1, 1,
    math.floor(self.font:getWidth(math.floor(boost) .. '/' .. max_boost)/2),
    math.floor(self.font:getHeight()/2))

	-- Cycle
	local r, g, b = unpack(default_color)
	local cycle_timer, cycle_cooldown = self.player.cycle_timer, self.player.cycle_cooldown / self.player.cycle_speed_multiplier.value
	love.graphics.setColor(r, g, b)
	love.graphics.rectangle('fill', gw/2 , gh - 16, 48*(cycle_timer/cycle_cooldown), 4)
	love.graphics.setColor(r - 32/255, g - 32/255, b - 32/255)
	love.graphics.rectangle('line', gw/2 , gh - 16, 48, 4)
	
	love.graphics.print('CYCLE', gw/2  + 18, gh - 24, 0, 1, 1,
	math.floor(self.font:getWidth('Cycle')/2), math.floor(self.font:getHeight()/2))
	

		
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Stage:destroy()
	self.area:destroy()
	self.area = nil
end

function Stage:finish()
    timer:after(2, function()
        gotoRoom('Stage')
    end)
end