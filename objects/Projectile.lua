Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
	Projectile.super.new(self, area, x, y, opts)
	
	self.s = (opts.s or 2.5) * current_room.player.projectile_size_multiplier
	self.v = opts.v or 200
	
	self.area_multiplier = opts.area_multiplier or current_room.player.area_multiplier or 1
	
	local _player = current_room.player
	
	if _player then		
		self.v = self.v * _player.pspd_multiplier.value
		self.fixed_spin_attack_direction = _player.fixed_spin_attack_direction
		self.projectiles_explosions = _player.projectiles_explosions
	end
	
	self.color = self.color or attacks[self.attack].color

	self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
	self.collider:setObject(self)
	self.collider:setFixedRotation(false)
	self.collider:setAngle(self.r)
    self.collider:setFixedRotation(true)
	self.collider:setCollisionClass('Projectile')
	
	self.explode = opts.explode or self.attack == 'Explode'
	
	--self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

	--self.projectile_duration = opts.projectile_duration
	
	self.rv = table.random({random(-2*math.pi, -math.pi), random(math.pi, 2*math.pi)})
	
	if self.mine then
        self.rv = table.random({random(-12*math.pi, -10*math.pi), 
        random(10*math.pi, 12*math.pi)})
        self.timer:after(1, function()
            self.area:addGameObject('Explosion', self.x, self.y, {color = self.color, area_multiplier = self.area_multiplier})
			self.dead = true
        end)
    end
	
	if self.fixed_spin_attack_direction then
		self.rv = math.abs(self.rv)
	end
	
	
	if self.attack == 'Homing' or 
	   self.attack == '2Split' or 
	   self.attack == '4Split' or
	   self.attack == 'Explode' then
		   
		self.timer:every(0.01, function()
				local _angleTo = Vector(self.collider:getLinearVelocity()):angleTo()
				self.area:addGameObject('TrailParticle',
					self.x - 2*self.s*math.cos(_angleTo),
					self.y - 2*self.s*math.sin(_angleTo),
					{parent = self, r = random(1,1.2)*self.s/2.5, d = random(0.15, 0.25), color = self.color})
			end)
	end
	
	if self.attack == 'Blast' then
        self.damage = 75
        self.color = table.random(negative_colors)
		self.projectile_duration = random(0.4, 0.6)
		self.timer:tween(self.projectile_duration*current_room.player.projectile_duration_multiplier, self, {v = 0}, 'linear', function() self:die() end)
    end
	
	if self.attack == 'Spin' then
		self.projectile_duration = random(2.4, 3.2)
        --self.timer:after(random(2.4, 3.2)*self.projectile_duration_multiplier, function() self:die() end)
		
		self.timer:every(0.05, function()
            self.area:addGameObject('ProjectileTrail', self.x, self.y, 
            {r = Vector(self.collider:getLinearVelocity()):angleTo(), 
            color = self.color, s = self.s})
        end)
	
		--self.timer:after(6, function() self:die() end)
    end
	
	if self.attack == 'Flame' then
		self.damage = 50
		self.projectile_duration = random(0.3, 0.6)
        --self.timer:after(random(2.4, 3.2)*self.projectile_duration_multiplier, function() self:die() end)
		
		self.timer:tween(self.projectile_duration*current_room.player.projectile_duration_multiplier, self, {v = 0}, 'cubic')
		
		self.timer:every(0.05, function()
            self.area:addGameObject('ProjectileTrail', self.x, self.y, 
            {r = Vector(self.collider:getLinearVelocity()):angleTo(), 
            color = self.color, s = self.s})
        end)
    end	
	
	if self.shield then
		self.time = 0
        self.orbit_distance = random(32, 64)
        self.orbit_speed = random(-6, 6)
        self.orbit_offset = random(0, 2*math.pi)
		self.previous_x, self.previous_y = self.collider:getPosition()
		self.projectile_duration = 6
		self.invisible = true
    	self.timer:after(0.05, function() self.invisible = false end)
		self.projectile_duration = 6
		--self.timer:after(self.projectile_duration*self.projectile_duration_multiplier, function() self:die() end)
    end
	
	if self.projectile_duration then
		self.timer:after(self.projectile_duration*current_room.player.projectile_duration_multiplier, 
			function() 
				if current_room.player and current_room.player.projectiles_explode_on_expiration then
					self.explode = true
				end
				self:die() 
			end)
	end
		
	
	if current_room.player.projectile_ninety_degree_change then
        self.timer:after(0.2, function()
      	    self.ninety_degree_direction = table.random({-1, 1})
            self.r = self.r + self.ninety_degree_direction*math.pi/2
            self.timer:every('ninety_degree_first', 0.25 / current_room.player.angle_change_frequency_multiplier, function()
                self.r = self.r - self.ninety_degree_direction*math.pi/2
                self.timer:after('ninety_degree_second', 0.1/ current_room.player.angle_change_frequency_multiplier, function()
                    self.r = self.r - self.ninety_degree_direction*math.pi/2
                    self.ninety_degree_direction = -1*self.ninety_degree_direction
                end)
            end)
      	end)
    end
	
	if current_room.player.projectile_random_degree_change then
		self.timer:after(0.2, function() 
				self.timer:every('random_degree', 0.125/ current_room.player.angle_change_frequency_multiplier, function()
					self.r = self.r + math.random(1, math.pi)	
				end)
			end)
	end
	
    if current_room.player.wavy_projectiles then
        local direction = table.random({-1, 1}) * current_room.player.projectile_waviness_multiplier
		
        self.timer:tween(0.25, self, {r = self.r + direction*math.pi/8}, 'linear', function()
            self.timer:tween(0.25, self, {r = self.r - direction*math.pi/4}, 'linear')
        end)
	
        self.timer:every(0.75, function()
            self.timer:tween(0.25, self, {r = self.r + direction*math.pi/4}, 'linear',  function()
                self.timer:tween(0.5, self, {r = self.r - direction*math.pi/4}, 'linear')
            end)
        end)
    end	
	
	if current_room.player.fast_slow then
        local initial_v = self.v
        self.timer:tween('fast_slow_first', 0.2, self, {v = 2*initial_v*current_room.player.projectile_acceleration_multiplier}, 'in-out-cubic', function()
            self.timer:tween('fast_slow_second', 0.3, self, {v = initial_v/2/current_room.player.projectile_deceleration_multiplier}, 'linear')
        end)
    end
	
	if current_room.player.slow_fast then
        local initial_v = self.v
        self.timer:tween('fast_slow_first', 0.2, self, {v = initial_v/2/current_room.player.projectile_acceleration_multiplier}, 'in-out-cubic', function()
            self.timer:tween('fast_slow_second', 0.3, self, {v = initial_v*2*current_room.player.projectile_deceleration_multiplier}, 'linear')
        end)
    end	
	
end

function Projectile:update(dt)
    Projectile.super.update(self, dt)
    
	
	if self.bounce and self.bounce > 0 then
		--print('xyu')
        if self.x < 0 then
            self.r = math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.y < 0 then
            self.r = 2*math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.x > gw then
            self.r = math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.y > gh then
            self.r = 2*math.pi - self.r
            self.bounce = self.bounce - 1
        end
    else
        if self.x < 0 then self:die() end
        if self.y < 0 then self:die() end
        if self.x > gw then self:die() end
        if self.y > gh then self:die() end
    end
	
	if self.attack == 'Homing' then
		if not self.target then
			local targets = self.area:getAllGameObjectsThat(function(e)
				for _, enemy in ipairs(enemies) do
					if e:is(_G[enemy]) and (distance(e.x, e.y, self.x, self.y) < 400) then
						return true
					end
				end
			end)
			self.target = table.remove(targets, love.math.random(1, #targets))
		end
		
		if self.target and self.target.dead then self.target = nil end
		
		if self.target then
			--print('CHANGING TARGET')
			local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
			local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
			local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
			local final_heading = (projectile_heading + 0.1*to_target_heading):normalized()
			self.collider:setLinearVelocity(self.v*final_heading.x, self.v*final_heading.y)
		else
			self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
		end
	else
		self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
	end
	
	
	if self.attack == 'Spin' or self.mine then
    	self.r = self.r + self.rv*dt
    end
	
	if self.shield then
		self.time = self.time + dt
        local player = current_room.player
        self.collider:setPosition(
      	player.x + self.orbit_distance*math.cos(self.orbit_speed*self.time + self.orbit_offset),
      	player.y + self.orbit_distance*math.sin(self.orbit_speed*self.time + self.orbit_offset))
	
		local x, y = self.collider:getPosition()
        local dx, dy = x - self.previous_x, y - self.previous_y
        self.r = Vector(dx, dy):angleTo()
    end
	
	if self.collider:enter('Enemy') then
		local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()
		
		if not object or object.dead then
			return
		end
		
		object:hit(self.damage)
		self:die()
		
		if object.hp <= 0 then 
			current_room.player:onKill(object.x, object.y) 
		end
	end

	self.previous_x, self.previous_y = self.collider:getPosition()
end



function Projectile:draw()
	if self.invisible then
		return
	end

	if self.attack == 'Homing' or 
	   self.attack == '2Split' or 
	   self.attack == '4Split' or
	   self.attack == 'Explode' then   
		   
		pushRotate(self.x, self.y, math.pi/2 + Vector(self.collider:getLinearVelocity()):angleTo()) 
		love.graphics.setColor(default_color)
		draft:triangleIsosceles(self.x, self.y, self.s * 2, self.s * 2)
		love.graphics.pop()
		pushRotate(self.x, self.y, 3 * math.pi/2 + Vector(self.collider:getLinearVelocity()):angleTo()) 
		love.graphics.setColor(self.color)
		draft:triangleIsosceles(self.x, self.y - self.s * 2, self.s * 2, self.s * 2)
		love.graphics.setColor(default_color)
		love.graphics.setLineWidth(1)
		
		love.graphics.pop()
	else
		local first_color, second_color = default_color, self.color
		
		if self.attack == 'Flame' or self.no_first_part then
			first_color = {0,0,0}
		end
		
		if self.attack == 'Bounce' then
			second_color = table.random(default_colors)
		end
		pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo()) 
		love.graphics.setColor(first_color)
		love.graphics.setLineWidth(self.s - self.s/4)
		love.graphics.line(self.x - 2*self.s, self.y, self.x, self.y)
		love.graphics.setColor(second_color)
		love.graphics.line(self.x, self.y, self.x + 2*self.s, self.y)
		love.graphics.setColor(default_color)
		love.graphics.setLineWidth(1)
		love.graphics.pop()
	end
end

function Projectile:die()
    self.dead = true
	
	local _player = current_room.player
	if self.attack == '2Split' or 
	   self.attack == '4Split' then
		   
		local _angles = {}
		
		if self.attack == '2Split' then
			table.insert(_angles, self.r + 3*math.pi/4)
			table.insert(_angles, self.r - 3*math.pi/4)			
		elseif self.attack == '4Split' then
			for i = 1, 4 do
				table.insert(_angles, (2*i - 1)*math.pi/4)
			end
		end
		
		local split_chance_list = _player.chances.split_projectiles_split_chance
		
		for i = 1, #_angles do
			local split_chance = split_chance_list:next()
			local _attack = split_chance and self.attack or "Neutral"
			
			self.area:addGameObject('Projectile', math.abs(self.x-1), math.abs(self.y-1), {r = _angles[i], color = self.color, no_first_part = not split_chance, attack = _attack})
		end
	end
	
	if self.explode then
		self.area:addGameObject('Explosion', self.x, self.y, {color = self.color, area_multiplier = self.area_multiplier})
		
		if self.projectiles_explosions then
			local half_angle = 2*math.pi
			local projectilles_number = 5 + _player.additional_barrage_projectiles
			
			--self.dead = false
			--self.timer:after(0.05 * projectilles_number, function() self.dead = true end)

			for i = 1, projectilles_number do
				--self.area.timer:after((i-1)*0.05, function()
					local random_angle = random(-half_angle, half_angle)
					self.area:addGameObject('Projectile', 
					self.x+math.sin(random_angle), 
					self.y+math.cos(random_angle), 
					{r = random_angle, attack = 'Neutral'})
				--end)
			end
		end
	end
	
	if self.attack ~= 'Explode' then
	    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, 
		{color = self.color, w = 3*self.s})
	end
end