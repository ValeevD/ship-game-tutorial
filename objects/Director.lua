Director = Object:extend()

function Director:new(stage)
    self.stage = stage
	
	local _player = self.stage.player
	
	self.difficulty = 1
    self.round_duration = 22 
    self.round_timer = 0
	
	self.timer = Timer()
    self.difficulty_to_points = {}
    self.difficulty_to_points[1] = 16
    for i = 2, 1024, 4 do
        self.difficulty_to_points[i] = self.difficulty_to_points[i-1] + 8
        self.difficulty_to_points[i+1] = self.difficulty_to_points[i]
        self.difficulty_to_points[i+2] = math.floor(self.difficulty_to_points[i+1]/1.5)
        self.difficulty_to_points[i+3] = math.floor(self.difficulty_to_points[i+2]*2)
    end	
	
	self.enemy_to_points = {
        ['Rock']    = 1,
        ['Shooter'] = 2,
    }
	
    self.enemy_spawn_chances = {
        [1] = chanceList({'Rock', 1}),
        [2] = chanceList({'Rock', 8}, {'Shooter', 4}),
        [3] = chanceList({'Rock', 8}, {'Shooter', 8}),
        [4] = chanceList({'Rock', 4}, {'Shooter', 8}),
    }	
	
	for i = 5, 1024 do
        self.enemy_spawn_chances[i] = chanceList(
      	    {'Rock', love.math.random(2, 12)}, 
      	    {'Shooter', love.math.random(2, 12)}
    	)
    end
	
	self.resource_spawn_chances = chanceList(
		{'Boost', 28 * _player.spawn_boost_chance_multiplier},
		{'HP', 14 * _player.hp_spawn_chance_multiplier}, 
		{'SP', 58 * _player.spawn_sp_chance_multiplier})
	
	self.resource_delay  = 16
	self.rosource_timer  = 0
	
	local _attacks = {}
	for i = 1, #table_binds do
		if table_binds[i] ~= 'Homing' then
		--if table_binds[i] == 'Lightning' then
			table.insert(_attacks, {table_binds[i], _player[table_binds[i]..'_spawn_chance_multiplier']})
		end
	end
	
	self.attack_spawn_chances = chanceList(unpack(_attacks))
	self.attack_spaw_delay = 5
	self.attack_spaw_timer = 0
	
	self:setEnemySpawnsForThisRound()
end


function Director:update(dt)
	self.timer:update(dt)
    self.round_timer = self.round_timer + dt
	
	local _player = self.stage.player
	
    if self.round_timer > self.round_duration / _player.enemy_spawn_rate_multiplier then
        self.round_timer = 0
        self.difficulty = self.difficulty + 1
		self:setEnemySpawnsForThisRound()
    end  
	
	self.rosource_timer = self.rosource_timer + dt
	
	if self.rosource_timer > self.resource_delay / _player.resource_spawn_rate_multiplier then
		local res = self.resource_spawn_chances:next()
		
		self.rosource_timer = 0
		self.stage.area:addGameObject(res)
		

		if res == "HP" and _player.chances.spawn_double_hp_chance:next() then
			self.stage.area:addGameObject("InfoText", _player.x, _player.y, {text = "Double HP Spawn!", color = hp_color})
			self.stage.area:addGameObject(res)
			end
			
		
		if res == "SP" and _player.chances.spawn_double_sp_chance:next() then
			self.stage.area:addGameObject("InfoText", _player.x, _player.y, {text = "Double SP Spawn!", color = skill_point_color})
			self.stage.area:addGameObject(res)
		end
	end
	
	self.attack_spaw_timer = self.attack_spaw_timer + dt
	if self.attack_spaw_timer > self.attack_spaw_delay/_player.attack_spawn_rate_multiplier then
		local atk = self.attack_spawn_chances:next()
		--print(atk)
		--print(res)
		self.attack_spaw_timer = 0
		self.stage.area:addGameObject('Attack',nil,nil,{attack = atk})
	end	
end

function Director:getMinPoints()
	local cl = self.enemy_spawn_chances[self.difficulty].chance_definitions
	
	local min = 99999
	for _, cd in ipairs(cl) do
		min = math.min(min, self.enemy_to_points[cd[1]])
	end
	
	return min
end

function Director:setEnemySpawnsForThisRound()
    local points = self.difficulty_to_points[self.difficulty]

    -- Find enemies
    local enemy_list = {}
	
	local min_points = self:getMinPoints()
	
	local _player = self.stage.player
	
	if _player then
		_player:setOnStartAttack()
	end
	
	--print('Round points: '..points)
    while points > 0 and points >= min_points do
        local enemy = self.enemy_spawn_chances[self.difficulty]:next()
		--min_points = math.min(min_points, self.enemy_to_points[enemy])

		
		if points >= self.enemy_to_points[enemy] then
			points = points - self.enemy_to_points[enemy]
			--print("Spawned: "..enemy.."("..self.enemy_to_points[enemy]..")")
			table.insert(enemy_list, enemy)
		end
		
    end
	
--	print('Min  points: '..min_points)
--	print('Rest points: '..points)
	
	
--	print('--------------------END------------------')
	
	
    local enemy_spawn_times = {}
    for i = 1, #enemy_list do 
    	enemy_spawn_times[i] = random(0, self.round_duration) 
    end
    table.sort(enemy_spawn_times, function(a, b) return a < b end)	
	
	for i = 1, #enemy_spawn_times do
		--print(enemy_list[i])
        self.timer:after(enemy_spawn_times[i], function()
            self.stage.area:addGameObject(enemy_list[i])
        end)
    end
end