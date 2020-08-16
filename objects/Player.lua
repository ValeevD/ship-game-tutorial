Player = GameObject:extend()

function Player:new(area, x, y, opts)
	
    Player.super.new(self, area, x, y, opts)
	
	self.yy = Vector(1, 1):normalized()
	
	--print(self.yy.x)

	self.x, self.y = x, y
    self.w, self.h = 12, 12

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    --
	self.collider:setCollisionClass('Player')

	self.r = -math.pi / 2
	self.rv =  1.66 * math.pi
	self.v = 0

	self.base_max_v = 100
	--self.base_max_v = 30
	self.max_v = self.base_max_v
	self.a = 100
	self.shoot_timer = 0
    self.shoot_cooldown = 0.24
	self.max_ammo = 100
	self.weapon_index = 1
	
	self.hp_multiplier = 1
	self.ammo_multiplier = 1
	self.boost_multiplier = 1
	
	self.flat_hp = 0
	self.flat_ammo = 0
	self.flat_boost = 0
	
	self.ammo_gain = 0

	self:setAttack('Neutral')
	----------------------------------------------------
	----PLAYER'S CYCLE SETTINGS
	----------------------------------------------------
	self.cycle_timer = 0
	self.cycle_cooldown = 5
	
	self.cycle_speed_multiplier = Stat(1)

--	self.timer:every(self.cycle_cooldown,
--		function()
--			self:tick()
--			self.cycle_timer = 0
--		end)

	----------------------------------------------------
	----SHIP'S INNER SETTINGS
	----------------------------------------------------
    self.max_hp = 100
    self.hp = self.max_hp

    self.invincible = false
    self.invisible = false

--    self.max_ammo = 100
--    self.ammo = self.max_ammo

    self.sp = 0

	----------------------------------------------------
	----TRAIL SETTINGS
	----------------------------------------------------
	self.boosting = false

    self.max_boost = 100
    self.boost = self.max_boost

    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2

	----------------------------------------------------
	----SHIP'S FORM SETTINGS
	----------------------------------------------------
    self.ship = 'Fighter'
    self.polygons = {}

    if self.ship == 'Fighter' then
		self.polygons[1] = {
			self.w, 0, -- 1
			self.w/2, -self.w/2, -- 2
			-self.w/2, -self.w/2, -- 3
			-self.w, 0, -- 4
			-self.w/2, self.w/2, -- 5
			self.w/2, self.w/2, -- 6
		}

		self.polygons[2] = {
			self.w/2, -self.w/2, -- 7
			0, -self.w, -- 8
			-self.w - self.w/2, -self.w, -- 9
			-3*self.w/4, -self.w/4, -- 10
			-self.w/2, -self.w/2, -- 11
		}

		self.polygons[3] = {
			self.w/2, self.w/2, -- 12
			-self.w/2, self.w/2, -- 13
			-3*self.w/4, self.w/4, -- 14
			-self.w - self.w/2, self.w, -- 15
			0, self.w, -- 16
		}
	elseif self.ship == 'Lexie' then
		self.polygons[1] = {
			self.w/3, -self.w/6, -- 1
			self.w, -self.w/3, -- 2
			self.w, -2/3*self.w, -- 3
			0, -self.w, -- 4
			-self.w/3, -self.w, -- 5
			-4/3*self.w, -self.w/2, -- 6
			-self.w, -self.w/6, -- 7
			-self.w, self.w/6, -- 8
			-4/3*self.w, self.w/2, -- 9
			-self.w/3, self.w, -- 10
			0, self.w, -- 11
			self.w, 2/3*self.w, -- 12
			self.w, self.w/3, -- 13
			self.w/3, self.w/6, -- 14
		}

		self.polygons[2] = {
			0, -self.w/6, -- 1
			-self.w/6, -self.w/2, -- 2
			-self.w/2, -self.w/2, -- 3
			-2/3*self.w, -self.w/6, -- 4
			-2/3*self.w, self.w/6, -- 5
			-self.w/2, self.w/2, -- 6
			-self.w/6, self.w/2, -- 7
			0, self.w/6, -- 8
		}
    end
	
	self.launch_homing_projectile_on_ammo_pickup_chance = 10
	self.regain_hp_on_ammo_pickup_chance = 10
	self.launch_homing_projectile_on_sp_pickup_chance = 10
	
	self.base_aspd_multiplier = 2
    self.aspd_multiplier = Stat(1)
	self.aspd_boosting = false
	
	self.spawn_haste_area_on_hp_pickup_chance = 10
	self.spawn_haste_area_on_sp_pickup_chance = 10
	
	self.spawn_sp_on_cycle_chance = 10
	
	self.spawn_hp_on_cycle_chance = 10
	self.regain_hp_on_cycle_chance = 10
	
	self.regain_full_ammo_on_cycle_chance = 10
	self.change_attack_on_cycle_chance = 10
	self.spawn_haste_area_on_cycle_chance = 10
	self.barrage_on_cycle_chance = 10
	self.launch_homing_projectile_on_cycle_chance = 1
	
	self.mvspd_boost_on_cycle_chance = 10
	
	self.base_mvspd_multiplier = 1
	self.mvspd_multiplier = Stat(1)
	self.mvspd_boost = false
	
	self.pspd_boost_on_cycle_chance = 10
	
	self.base_pspd_multiplier = 1
	self.pspd_multiplier = Stat(1)
	self.pspd_boost = false
	
	self.pspd_inhibit_on_cycle_chance = 10
	
	self.base_pspd_inhibit_multiplier = 1
	--self.pspd_inhibit_multiplier = Stat(1)
	self.pspd_inhibit = false
	
	self.barrage_on_kill_chance = 10
	self.regain_ammo_on_kill_chance = 10
	self.launch_homing_projectile_on_kill_chance = 10
	self.regain_boost_on_kill_chance = 10
	self.spawn_boost_on_kill_chance = 10
	self.gain_aspd_boost_on_kill_chance = 10
	
	self.drop_double_ammo_chance = 10
	
	self.launch_homing_projectile_while_boosting_chance = 10
	
	self.increased_cycle_speed_while_boosting_chance = 10
	self.increased_cycle_speed_while_boosting = false
	
	self.invulnerability_while_boosting_chance = 10
	self.invulnerability_while_boosting = true
	--self.invul_count = 0
	
	self.luck_multiplier = 1
	
	self.increased_luck_while_boosting = false
	
	self.hp_spawn_chance_multiplier = 1
	self.spawn_sp_chance_multiplier = 1
	self.spawn_boost_chance_multiplier = 3
	
	self.attack_twice_chance = 10
	
	self.spawn_double_hp_chance = 10
	self.spawn_double_sp_chance = 10
	
	self.gain_double_sp_chance = 10
	
	self.enemy_spawn_rate_multiplier = 1
	self.resource_spawn_rate_multiplier = 1
	self.attack_spawn_rate_multiplier = 1
	
	--by myself
	
	self.turn_rate_multiplier = 1
	self.boost_effectiveness_multiplier = 1	
	self.projectile_size_multiplier = 1
	self.boost_recharge_rate_multiplier = 1
	self.invulnerability_time_multiplier = 1
	self.ammo_consumption_multiplier = 1
	
	self.size_multiplier = 1
	
	self.stat_boost_duration_multiplier = 1
	
	self.projectile_ninety_degree_change = false
	self.projectile_random_degree_change = false
	
	self.angle_change_frequency_multiplier = 1
	
	self.wavy_projectiles = false
	self.projectile_waviness_multiplier = 1
	
	self.fast_slow = false
	self.projectile_acceleration_multiplier = 1
	
	self.slow_fast = false
	self.projectile_deceleration_multiplier = 1
	
	self.shield_projectile_chance = 10
	
	self.projectile_duration_multiplier = 1
	
	self.additional_lightning_bolt = false
	self.increased_lightning_angle = false
	
	self.area_multiplier = 1
	
	self.laser_width_multiplier = 1
	
	self.additional_bounce_projectiles = 0
	
	self.fixed_spin_attack_direction = false	
	self.split_projectiles_split_chance = 0
	
	for i = 1, #table_binds do
		if table_binds[i] ~= "Homing" then
			self[table_binds[i].."_spawn_chance_multiplier"] = 1
			self["start_with_attack_"..table_binds[i]] = false
		end
	end
	
	self.additional_homing_projectiles = 0
	
	self.additional_barrage_projectiles = 0
	
	self.barrage_nova = false
	
	self.drop_mines_chance = 10
	
	self.projectiles_explode_on_expiration = false
	self.self_explode_on_cycle_chance = 10
	
	self.projectiles_explosions = true
	
	--ES
	
    self.energy_shield_recharge_cooldown = 2
    self.energy_shield_recharge_amount = 1

    -- Booleans
    self.energy_shield = false
	
	self.energy_shield_recharge_amount_multiplier = 1
	self.energy_shield_recharge_cooldown_multiplier = 1
	
	self.added_chance_to_all_on_kill_events = 0
	
	self.ammo_to_aspd = 0
	
	self.change_attack_periodically = false
	self.change_attack_period = 0
	self.change_attack_timer = 0
	
	self.timer:every(0.01, function()
        if self.ship == 'Fighter' then
            self.area:addGameObject('TrailParticle',
            self.x - 0.9*self.w*self.size_multiplier*math.cos(self.r) + 0.2*self.w*self.size_multiplier*math.cos(self.r - math.pi/2),
            self.y - 0.9*self.w*self.size_multiplier*math.sin(self.r) + 0.2*self.w*self.size_multiplier*math.sin(self.r - math.pi/2),
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color})

		   self.area:addGameObject('TrailParticle',
            self.x - 0.9*self.w*self.size_multiplier*math.cos(self.r) + 0.2*self.w*self.size_multiplier*math.cos(self.r + math.pi/2),
            self.y - 0.9*self.w*self.size_multiplier*math.sin(self.r) + 0.2*self.w*self.size_multiplier*math.sin(self.r + math.pi/2),
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25), color = self.trail_color})
		elseif self.ship == 'Lexie' then
			self.area:addGameObject('TrailParticle',
			self.x - 1.5*self.w*self.size_multiplier*math.cos(self.r),
			self.y - 1.5*self.w*self.size_multiplier*math.sin(self.r),
			{parent = self, r = random(4,6)*self.size_multiplier, d = random(0.15, 0.25)*self.size_multiplier, color = self.trail_color})
        end
    end)

	self:setStats()
	self:generateChances()
	
	self.timer:every(0.5, function() 
			if self.chances.drop_mines_chance:next() then
				self:dropMine()
			end
		end)

end


function Player:update(dt)
    Player.super.update(self, dt)

	self.max_v = self.base_max_v

	if input:down('left') then
		self.r = self.r - self.rv*self.turn_rate_multiplier*dt
	end

	if input:down('right') then
		self.r = self.r + self.rv*self.turn_rate_multiplier*dt
	end

    self.boost_timer = self.boost_timer + dt

    if self.boost_timer > self.boost_cooldown / self.boost_recharge_rate_multiplier then
		self.can_boost = true
	end

	self.shoot_timer = self.shoot_timer + dt
	
	if self.ammo_to_aspd > 0 then 
        self.aspd_multiplier:increase((self.ammo_to_aspd/100)*(self.max_ammo - 100)) 
    end
	
	--change attack change
	
	if self.change_attack_periodically then
		self.change_attack_timer = self.change_attack_timer + dt
		
		if self.change_attack_timer >= self.change_attack_period then
			self:setAttack(table.random(table_binds))
			self.area:addGameObject('InfoText', self.x, self.y, 
			{text = 'New Attack!', color = attacks[self.attack].color})		
			self.change_attack_timer = 0
		end
	end
	
    if self.shoot_timer > self.shoot_cooldown/self.aspd_multiplier.value then
        self.shoot_timer = 0
        
		self:shoot()
		
		if self.chances.attack_twice_chance:next() then
			timer:after(0.1, function() self:shoot() end)
			self.area:addGameObject("InfoText", self.x, self.y, {text = 'Double attack', color = default_color})
		end
    end

	self.boosting = false

    if input:pressed('up') and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released('up') then self:onBoostEnd() end
    if input:down('up') and self.boost > 1 and self.can_boost then
		self.boosting = true
		self.max_v = 1.5*self.base_max_v*self.boost_effectiveness_multiplier
		self.boost = self.boost - 50*dt
		if self.boost <= 1 then
            self.boosting    = false
            self.can_boost   = false
            self.boost_timer = 0
			self:onBoostEnd()
        end
	end

    if input:pressed('down') and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released('down') then self:onBoostEnd() end
    if input:down('down') and self.boost > 1 and self.can_boost then
		self.boosting = true
		self.max_v = 0.5*self.base_max_v / self.boost_effectiveness_multiplier
		self.boost = self.boost - 50*dt
		if self.boost <= 1 then
            self.boosting    = false
            self.can_boost   = false
            self.boost_timer = 0
			self:onBoostEnd()
        end
	end
	
	self.max_v = self.max_v * self.mvspd_multiplier.value
	--self.v = self.v * self.mvspd_multiplier.value

	if not self.boosting then
		self.boost = math.min(self.boost + 10*dt, self.max_boost)
	end

	self.trail_color = skill_point_color
	if self.boosting then
		self.trail_color = boost_color
	end

	self.v = math.min(self.v + self.a * self.boost_effectiveness_multiplier * dt, self.max_v)

	self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

	if self.x - self.w < 0 then self:die() end
    if self.y - self.w < 0 then self:die() end
    if self.x + self.w > gw then self:die() end
    if self.y + self.w > gh then self:die() end

	--self.boost = math.min(self.boost + 10*dt, self.max_boost)
	
	self.invincible = self.invincible or self.invulnerability_while_boosting
	

	if self.collider:enter('Collectable') then
        local collision_data = self.collider:getEnterCollisionData('Collectable')
        local object = collision_data.collider:getObject()

		if not object then
			return
		end

        if object:is(Ammo) then
            object:die()
			--self:addAmmo(5)
			self:addAmmo(5)
			self:onAmmoPickup()
        end
		if object:is(Boost) then
            object:die()
			self:addBoost(25)
        end
		if object:is(HP) then
            object:die()
			self:addHP(25)
			self:onHPPickup()
        end
		if object:is(SP) then
            
			local amount = 1
			
			if self.chances.gain_double_sp_chance:next() then
				amount = amount + 1
				self.area:addGameObject("InfoText", self.x, self.y, {text = "Double SP Gain!", color = skill_point_color})
			end
			
			object:die(amount)
			
			self:addResource('sp', amount)
			self:onSPPickup()
        end
		if object:is(Attack) then
            object:die()
			self:setAttack(object.attack)
			current_room.score = current_room.score + 500
        end
	elseif self.collider:enter('Enemy') then
		local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()

		if not object then
			return
		end

		if object:is(Rock) and not self.invincible then
			self:hit(30)
		end

		if object:is(Shooter) and not self.invincible then
			self:hit(30)
		end
	end
	self.cycle_timer = self.cycle_timer + dt
	
    if self.inside_haste_area then self.aspd_multiplier:increase(100) end
    if self.aspd_boosting then self.aspd_multiplier:increase(100) end
    self.aspd_multiplier:update(dt)
	
	if self.mvspd_boost then self.mvspd_multiplier:increase(50) end
	self.mvspd_multiplier:update(dt)
	
	if self.pspd_boost then self.pspd_multiplier:increase(100) end	
	if self.pspd_inhibit then self.pspd_multiplier:decrease(50) end
	self.pspd_multiplier:update(dt)
	
	--self.cycle_timer = self.cycle_timer + dt
	
	local prev_mul = self.cycle_speed_multiplier.value
	if self.increased_cycle_speed_while_boosting then		
		self.cycle_speed_multiplier:increase(200)
	end
	self.cycle_speed_multiplier:update(dt)
	
	self.cycle_timer = self.cycle_timer / self.cycle_speed_multiplier.value * prev_mul
	
	if self.cycle_timer >= self.cycle_cooldown / self.cycle_speed_multiplier.value then
		self:tick()
		self.cycle_timer = 0
	end
end

function Player:draw()
	--love.graphics.print("Difficulty = "..current_room.director.difficulty)
	--love.graphics.print("Round timer = "..math.ceil(current_room.director.round_timer), nil, 15)
  --  love.graphics.print("Incr"..(self.increased_cycle_speed_while_boosting and "YES" or "NO"), nil, 15)
--	love.graphics.print('Time: '..self.cycle_timer, nil, 45)
  --love.graphics.print("Attack = "..(self.attack or ""),nil,15)

	if self.invisible then
		return
	end

	pushRotate(self.x, self.y, self.r)
	love.graphics.setColor(default_color)
	for _, polygon in ipairs(self.polygons) do

        local points = fn.map(polygon, function(k, v)

        	if v % 2 == 1 then
				return self.x + k * self.size_multiplier-- + random(-1, 1)
        	else
          		return self.y + k * self.size_multiplier-- + random(-1, 1)
        	end
      	end)

		love.graphics.polygon('line', points)
	end
	love.graphics.pop()
end

function Player:shoot()
    local d = (1 + 0.2/self.size_multiplier)*(self.w*self.size_multiplier)
	local cur_ammo = attacks[self.attack].ammo 
	
	--local shield = self.chances.shield_projectile_chance:next()
	
	local mods = {
		shield = self.chances.shield_projectile_chance:next()
	}

    if self.ammo <= 0 then
        self:setAttack('Neutral')
        self.ammo = self.max_ammo
    end

    if self.attack == 'Neutral' then

        self.area:addGameObject('Projectile',
			self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack}, mods))
	elseif self.attack == 'Homing' then
		self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})
		
	elseif self.attack == 'Rapid' then

        self.area:addGameObject('Projectile',
		self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})
	elseif self.attack == 'Double' then

        self.area:addGameObject('Projectile',
    	self.x + 1.5*d*math.cos(self.r + math.pi/12),
    	self.y + 1.5*d*math.sin(self.r + math.pi/12),
    	{r = self.r + math.pi/12, attack = self.attack})

        self.area:addGameObject('Projectile',
    	self.x + 1.5*d*math.cos(self.r - math.pi/12),
    	self.y + 1.5*d*math.sin(self.r - math.pi/12),
    	{r = self.r - math.pi/12, attack = self.attack})

	elseif self.attack == 'Triple' then

        self.area:addGameObject('Projectile',
    	self.x + 1.5*d*math.cos(self.r + math.pi/12),
    	self.y + 1.5*d*math.sin(self.r + math.pi/12),
    	{r = self.r + math.pi/12, attack = self.attack})

        self.area:addGameObject('Projectile',
    	self.x + 1.5*d*math.cos(self.r - math.pi/12),
    	self.y + 1.5*d*math.sin(self.r - math.pi/12),
    	{r = self.r - math.pi/12, attack = self.attack})

		self.area:addGameObject('Projectile',
		self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})

	elseif self.attack == 'Spread' then

		local _col = table.random(all_colors)
        self.area:addGameObject('Projectile',
		self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r),
		{r = self.r + random(-math.pi/8, math.pi/8), attack = self.attack, color = _col})

	elseif self.attack == 'Side' then

        self.area:addGameObject('Projectile',
    	self.x + 1.5*d*math.cos(self.r+math.pi/2),
    	self.y + 1.5*d*math.sin(self.r+math.pi/2),
    	{r = self.r + math.pi/2, attack = self.attack})

        self.area:addGameObject('Projectile',
    	self.x + 1.5*d*math.cos(self.r-math.pi/2),
    	self.y + 1.5*d*math.sin(self.r-math.pi/2),
    	{r = self.r - math.pi/2, attack = self.attack})

		self.area:addGameObject('Projectile',
		self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), {r = self.r, attack = self.attack})
	
    elseif self.attack == 'Blast' then
		local half_angle = math.min(math.pi/6 * self.area_multiplier, 2*math.pi)
        for i = 1, 12 do
            local random_angle = random(-half_angle, half_angle)
			mods.shield = self.chances.shield_projectile_chance:next()
            self.area:addGameObject('Projectile', 
      	        self.x + 1.5*d*math.cos(self.r + random_angle), 
      	        self.y + 1.5*d*math.sin(self.r + random_angle), 
            table.merge({r = self.r + random_angle, attack = self.attack, 
          	v = random(500, 600)}, mods))
        end
        camera:shake(2, 20, 0.4)
    elseif self.attack == 'Spin' then
        --self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack}, mods))
	elseif self.attack == 'Flame' then
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack}, mods))	
    elseif self.attack == 'Bounce' then
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack, bounce = 4+self.additional_bounce_projectiles}, mods))	
	elseif self.attack == '2Split' then
		self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack}, mods))
	elseif self.attack == '4Split' then
		self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack}, mods))	
	elseif self.attack == 'Lightning' then
		local x1, y1 = self.x + d*math.cos(self.r), self.y + d*math.sin(self.r)
		local cx, cy = 0, 0
		
		if self.increased_lightning_angle then
			cx, cy = self.x, self.y
		else
			cx, cy = x1 + 24*math.cos(self.r), y1 + 24*math.sin(self.r)
		end
		cur_ammo = 0
		
	
		local targets_num = 1 + (self.additional_lightning_bolt and 1 or 0)
		local rad = 64*self.area_multiplier
		
		cur_ammo = 0	
		
		for i=1,targets_num do
			
			local nearby_enemies = self.area:getAllGameObjectsThat(function(e)
				for _, enemy in ipairs(enemies) do
					if e:is(_G[enemy]) and (distance(e.x, e.y, cx, cy) < rad) and not e.dead then
						return true
					end
				end
			end)
		
			table.sort(nearby_enemies, function(a, b) 
				return distance(a.x, a.y, cx, cy) < distance(b.x, b.y, cx, cy) 
			end)
	
			local closest_enemy = nearby_enemies[1]
			
			if closest_enemy then
				cur_ammo = i*attacks[self.attack].ammo
				closest_enemy:hit()
				local x2, y2 = closest_enemy.x, closest_enemy.y
				self.area:addGameObject('LightningLine', 0, 0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
				for i = 1, love.math.random(4, 8) do 
					self.area:addGameObject('ExplodeParticle', x1, y1, 
					{color = table.random({default_color, boost_color})}) 
				end
				for i = 1, love.math.random(4, 8) do 
					self.area:addGameObject('ExplodeParticle', x2, y2, 
					{color = table.random({default_color, boost_color})}) 
				end
				x1,y1 = x2,y2
				cx,cy = x1,y1
				rad = (i+1)*rad/2*self.area_multiplier
			end		
			

		end	
	elseif self.attack == 'Explode' then
		self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack, s=3.5}, mods))
	elseif self.attack == 'Laser' then
		
--		local hit_enemies = self.area:getAllGameObjectsThat(function(e)
					
--				end)
		self.area:addGameObject('LaserLine', 
    	0, 0, 
			{attack = self.attack, 
			depth = 51, 
			r = self.r, 
			x1 = self.x + 1.2*d*math.cos(self.r), 
			y1 = self.y + 1.2*d*math.sin(self.r),
			laser_width_multiplier = self.laser_width_multiplier})
	
		self.area:addGameObject('ShootEffect',
						self.x + d*math.cos(self.r),
						self.y + d*math.sin(self.r),
						{r = self.r, depth = 52, d = d, w = 20 * self.laser_width_multiplier, min_w = 20* self.laser_width_multiplier, oName = self.oName, effect_duration = 0.2, color = hp_color})
		
		camera:shake(2, 20, 0.1)
		
    end
	
	if self.attack ~= 'Laser' then
		self.area:addGameObject('ShootEffect',
							self.x + d*math.cos(self.r),
							self.y + d*math.sin(self.r),
							{player = self, d = d, oName = self.oName})
	end
	
	self.ammo = self.ammo - cur_ammo * self.ammo_consumption_multiplier
end

function Player:hit(damage)
	self:addHP(-(damage or 10))

	local flash_frames = 3
	local shake_lvl = 6
	local shake_time = 0.2
	local slow_lvl = 0.25
	local slow_time = 0.5
	local invincible_time = 2

	if damage < 30 then
		flash_frames = 2
		shake_lvl = 6
		shake_time = 0.1
		slow_lvl = 0.75
		slow_time = 0.25
		invincible_time = 0
	end

	flash(flash_frames)
	camera:shake(shake_lvl, 60, shake_time)
	slow(slow_lvl, slow_time)

	self.invincible = true
	
	local blick_times = math.ceil(invincible_time * self.invulnerability_time_multiplier / 0.04)
	
	if blick_times % 2 ~= 0 then
		blick_times = blick_times - 1
	end
	
	self.timer:every(0.04, function() self.invisible = not self.invisible end, blick_times)
	
	self.timer:after(invincible_time * self.invulnerability_time_multiplier, function() 
			self.invincible = false 
		end)
	
	if self.energy_shield then
        damage = damage*2
        self.timer:after('es_cooldown', self.energy_shield_recharge_cooldown/self.energy_shield_recharge_cooldown_multiplier, function()
            self.timer:every('es_amount', 0.25, function()
                self:addHP(self.energy_shield_recharge_amount*self.energy_shield_recharge_amount_multiplier)
            end)
        end)
    end

	for i = 1, love.math.random(4, 8) do
    	self.area:addGameObject('ExplodeParticle', self.x, self.y)
  	end
end



function Player:die()

	if self.dead then
		return
	end

    self.dead = true
	self.hp = 0

	flash(4)
	camera:shake(6, 60, 0.4)
	slow(0.15, 1)

    for i = 1, love.math.random(30, 36) do
    	self.area:addGameObject('ExplodeParticle', self.x, self.y, 
			{d = math.random(0.3, 1.5), 
			color = table.random(all_colors), 
			s = math.random(1, 2), 
			line_width = math.random(0.3, 0.6), 
			v = random(50, 500)})
  	end

	current_room:finish()
end

function Player:addAmmo(amount)
	self.ammo = math.min(self.max_ammo, self.ammo + amount + self.ammo_gain)
	current_room.score = current_room.score + 50
end

function Player:onAmmoPickup()
    if self.chances.launch_homing_projectile_on_ammo_pickup_chance:next() then
        local d = 1.2*self.w * self.projectile_size_multiplier
		
		for i = 1, 1+self.additional_homing_projectiles do
			self.area:addGameObject('Projectile', 
			self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), 
			{r = self.r, attack = 'Homing'})
		end
		
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
    end
	
	if self.chances.regain_hp_on_ammo_pickup_chance:next() then
		self:getHPOnResoursePickup()
	end
end

function Player:getHPOnResoursePickup()
	self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color, w = 12, h = 12})
	
	self:addHP(25)	
end

function Player:onSPPickup()
	if self.chances.launch_homing_projectile_on_sp_pickup_chance:next() then
        local d = 1.2*self.w
		
		for i = 1, 1+self.additional_homing_projectiles do
			self.area:addGameObject('Projectile', 
			self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), 
			{r = self.r, attack = 'Homing'})
		end
		
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
	end
	
	if self.chances.spawn_haste_area_on_sp_pickup_chance:next() then
		self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!', color = hp_color, w = 12, h = 12})
		self.area:addGameObject('HasteArea', self.x, self.y)
	end
	
end

function Player:onHPPickup()
	if self.chances.spawn_haste_area_on_hp_pickup_chance:next() then
		self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!', color = hp_color, w = 12, h = 12})
		self.area:addGameObject('HasteArea', self.x, self.y)
	end
end

function Player:addBoost(amount)
	self:addResource('boost', amount)
	 current_room.score = current_room.score + 150
end

function Player:addHP(amount)
	self:addResource('hp', amount)

	if self.hp <= 0 then
		self:die()
	end
end


function Player:addSP(amount)
	self:addResource('sp', amount)
	 current_room.score = current_room.score + 250
end

function Player:addResource(res_name, amount)
	self[res_name] = math.min(self[res_name] + amount, self["max_"..res_name] or 9999999)
end

function Player:tick()
	local d = 1.2*self.w
		
	self.area:addGameObject('TickEffect', self.x, self.y, {parent = self})	
	
	if self.chances.spawn_sp_on_cycle_chance:next() then
        self.area:addGameObject('SP')
        self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'SP Spawn!', color = skill_point_color})
    end
	
	if self.chances.spawn_hp_on_cycle_chance:next() then
        self.area:addGameObject('HP')
        self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'HP Spawn!', color = hp_color})
    end
	
	if self.chances.regain_hp_on_cycle_chance:next() then
		self:addHP(25)
		self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'HP Regain!', color = hp_color})
	end
	
	if self.chances.regain_full_ammo_on_cycle_chance:next() then
		self:addAmmo(self.max_ammo)
		self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'Full Ammo!', color = ammo_color})
	end
	
	if self.chances.change_attack_on_cycle_chance:next() then
		self:setAttack(table.random(table_binds))
		self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'New Attack!', color = attacks[self.attack].color})		
	end
	
	if self.chances.spawn_haste_area_on_cycle_chance:next() then
		self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!', color = hp_color, w = 12, h = 12})
		self.area:addGameObject('HasteArea', self.x, self.y)		
	end
	
	if self.chances.barrage_on_cycle_chance:next() then 
		self:spawn_barage()
	end
	
	if self.chances.launch_homing_projectile_on_cycle_chance:next() then
		for i = 1, 1+self.additional_homing_projectiles do			
			self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing'})	
		end
		
		self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Missle!', color = ammo_color, w = 12, h = 12})
	end
	
	if self.chances.mvspd_boost_on_cycle_chance:next() then
        self.mvspd_boost = true

        self.timer:after(4, function() self.mvspd_boost = false end)
		
        self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'MVSPD Boost!', color = boost_color})		
	end
	
	if self.chances.pspd_boost_on_cycle_chance:next() then
		self.pspd_boost = true
		self.timer:after(4, function() self.pspd_boost = false end)
		
		self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'PSPD Boost!', color = skill_point_color})		
	end
	
	if self.chances.pspd_inhibit_on_cycle_chance:next() then
		self.pspd_inhibit = true
		self.timer:after(4, function() self.pspd_inhibit = false end)
		
		self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'PSPD Inhibit!', color = skill_point_color})		
	end	
	
	if self.chances.self_explode_on_cycle_chance:next() then
		local explosions_number = 10
		for i=1,explosions_number do
			local one_explode_delay = 0.1
			
			self.timer:every(one_explode_delay, function()
					self.area:addGameObject('Explosion', self.x + math.random(-100, 100), self.y+ math.random(-100, 100), {color=hp_color, s=100})
				end, one_explode_delay * explosions_number)
		end
		camera:shake(4,30,0.4)
	end
end

function Player:setAttack(attack)
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammo = self.max_ammo
end

function Player:setStats()
    self.max_hp = (self.max_hp + self.flat_hp)*self.hp_multiplier
    self.hp = self.max_hp
	
	self.max_ammo = (self.max_ammo + self.flat_ammo) * self.ammo_multiplier
    self.ammo = self.max_ammo
	
	self.max_boost = (self.max_boost + self.flat_boost) * self.boost_multiplier
	self.boost = self.max_boost
	
	--self.energy_shield = true
	
	--if self.energy_shield then
        --self.invulnerability_time_multiplier = self.invulnerability_time_multiplier/2
    --end
end

function Player:generateChances()
    self.chances = {}
    for k, v in pairs(self) do
        if k:find('_chance') and type(v) == 'number' then
			if k:find('_on_kill') and v > 0 then
                self.chances[k] = chanceList(
                {true, math.ceil(v+self.added_chance_to_all_on_kill_events)*self.luck_multiplier}, 
                {false, 100-math.ceil(v+self.added_chance_to_all_on_kill_events)*self.luck_multiplier})
            else
				self.chances[k] = chanceList({true, math.ceil(v * self.luck_multiplier)}, {false, 100-math.ceil(v * self.luck_multiplier)})
			end
        end
    end
end

function Player:onKill(x, y)
	
	if self.dead then
		return
	end
	
    if self.chances.barrage_on_kill_chance:next() then
		self:spawn_barage()
    end
	
	if self.chances.regain_ammo_on_kill_chance:next() then
		self.area:addGameObject('InfoText', self.x, self.y, {text = 'Ammo regain!', color = ammo_color, w = 12, h = 12})
		self:addAmmo(20)
	end
	
	if self.chances.launch_homing_projectile_on_kill_chance:next() then
		local d = 1.2*self.w*self.size_multiplier
		
		for i = 1, 1+self.additional_homing_projectiles do
			self.area:addGameObject('Projectile', 
			self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), 
			{r = self.r, attack = 'Homing'})
		end
		
		self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!'})
		
	end
	
	if self.chances.regain_boost_on_kill_chance:next() then
		self.area:addGameObject('InfoText', self.x, self.y, {text = 'Boost regain!', color = boost_color, w = 12, h = 12})
		self:addBoost(40)
	end
	
	if self.chances.spawn_boost_on_kill_chance:next() then
        self.area:addGameObject('Boost')
        self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'Boost Spawn!', color = boost_color})		
	end
	
	if self.chances.gain_aspd_boost_on_kill_chance:next() then
        self.aspd_boosting = true
		--self.v = self.v * self.mvspd_multiplier.value
        self.timer:after(4, function() self.aspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'ASPD Boost!', color = ammo_color})
    end
	
	if self.chances.drop_double_ammo_chance:next() then
		self.area:addGameObject('InfoText', self.x, self.y, 
      	{text = 'Double Ammo!', color = ammo_color})
		self.area:addGameObject('Ammo', x or self.x, y or self.y)
	end

end

function Player:spawn_barage()
	if self.dead then
		return
	end
	
	local half_angle = math.min(math.pi/8 * self.area_multiplier, 2*math.pi)
	
	if self.barrage_nova then
		half_angle = 2*math.pi
	end
	
	for j = 1, 1 + self.additional_barrage_projectiles do
		for i = 1, 8 do
			self.timer:after((i-1)*0.05, function()
				local random_angle = random(-half_angle, half_angle)
				local d = 2.2*self.w*self.size_multiplier
				self.area:addGameObject('Projectile', 
				self.x + d*math.cos(self.r + random_angle), 
				self.y + d*math.sin(self.r + random_angle), 
				{r = self.r + random_angle, attack = 'Neutral'})
			end)
		end
	end
	
	self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage!!!'})	
end

function Player:onBoostStart()
    self.timer:every('launch_homing_projectile_while_boosting_chance', 0.2, function()
        if self.chances.launch_homing_projectile_while_boosting_chance:next() then
            local d = 1.2*self.w*self.size_multiplier
			
			for i = 1, 1+self.additional_homing_projectiles do
				self.area:addGameObject('Projectile', 
				self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), 
					{r = self.r, attack = 'Homing'})
			end
			
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Missle!'})
        end
    end)

    self.timer:every('increased_cycle_speed_while_boosting', 0.2, function()
		if not self.increased_cycle_speed_while_boosting then
			if self.chances.increased_cycle_speed_while_boosting_chance:next() then				
				self.increased_cycle_speed_while_boosting = true
				self.area:addGameObject('InfoText', self.x, self.y, {text = 'Cycle Boost Speed!!'})
			end            
        end
    end)

	
	self.timer:every('invulnerability_while_boosting', 0.2, function()
		if not self.invulnerability_while_boosting then
			if self.chances.invulnerability_while_boosting_chance:next() then				
				self.invulnerability_while_boosting = true
				self.area:addGameObject('InfoText', self.x, self.y, {text = 'INVUL!!', color = hp_color})
				--self.timer:every('visible_change', 0.04, function() self.invisible = not self.invisible end)
			end            
		end
	end)

    if self.increased_luck_while_boosting then 
    	self.luck_boosting = true
    	self.luck_multiplier = self.luck_multiplier*2
    	self:generateChances()
    end
end

function Player:onBoostEnd()
	--print('gavno'..(self.invulnerability_while_boosting and "YES" or "NO"))
    self.timer:cancel('launch_homing_projectile_while_boosting_chance')
	
	self.timer:cancel('increased_cycle_speed_while_boosting')
	self.increased_cycle_speed_while_boosting = false
	
	self.timer:cancel('invulnerability_while_boosting')
	self.invulnerability_while_boosting = false
	self.invincible = false
	--self.invisible  = false
	
	if self.increased_luck_while_boosting and self.luck_boosting then
    	self.luck_boosting = false
    	self.luck_multiplier = self.luck_multiplier/2
    	self:generateChances()
    end
end

function Player:setOnStartAttack()
	local table_attack_on_start = {}
	
	--print('xuy')
	for k,v in pairs(self) do
		if k:find('start_with_attack') and self[k] then
			table.insert(table_attack_on_start, string.sub(k, string.len('start_with_attack')+2, string.len(k)))
		end
	end
	
	--print(table.random(table_attack_on_start))
	self:setAttack(#table_attack_on_start>0 and table.random(table_attack_on_start) or 'Neutral')
end

function Player:dropMine()
	local d = 1.2*self.w*self.size_multiplier
	
	self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {attack = 'Neutral', r = self.r, mine = true})
end
