LaserLine = GameObject:extend()

function LaserLine:new(area, x, y, opts)
	LaserLine.super.new(self, area, x, y, opts)
	

	self._vector = Vector.fromPolar(self.r)*distance(0,0,gw,gh)
	self.points = {
		self.x1 + math.cos(self.r+math.pi/2)*10, self.y1 + math.sin(self.r+math.pi/2)*10, 
		self.x1 + math.cos(self.r-math.pi/2)*10, self.y1 + math.sin(self.r-math.pi/2)*10,
		self.x1 + self._vector.x + math.cos(self.r+math.pi/2)*10, self.y1 + self._vector.y + math.sin(self.r+math.pi/2)*10,
		self.x1 + self._vector.x + math.cos(self.r-math.pi/2)*10, self.y1 + self._vector.y + math.sin(self.r-math.pi/2)*10}
		
	self.points.getPointByNumber = function(n)
		return {x = self.points[2*n - 1], y = self.points[2*n]}
	end
	
	self.laser_width_multiplier = opts.laser_width_multiplier or 1
	
	self.max_main_line_width  = (opts.laser_main_line_width or 10) * self.laser_width_multiplier
	self.main_line_width      = self.max_main_line_width
	
	self.max_secondary_line_width = self.max_main_line_width / 10
	self.secondary_line_width 	  = self.max_secondary_line_width
	
	self.secondary_lines_offset   = 0
	
	self.collider = self.area.world:newPolygonCollider(self.points)
	self.collider:setObject(self)
	self.collider:setCollisionClass('Projectile')

	
--	self.timer:after(0.2, function() 
--				self.dead = true
--			end)
		
	self.timer:tween(0.2, self, 
		{main_line_width = 0, secondary_line_width = 0, secondary_lines_offset = self.max_main_line_width/2 - self.max_secondary_line_width}, 
		'out-cubic', function() self.dead = true end)
		

end

function LaserLine:update(dt)
	LaserLine.super.update(self, dt)
	
	local enemy_collision_classes = {'Enemy', 'EnemyProjectile'}
	
	for i=1,#enemy_collision_classes do
		if self.collider:enter(enemy_collision_classes[i]) then
			--local collision_data = self.collider:getStayCollisionData('Enemy')
			local collision_events = self.collider.collision_events[enemy_collision_classes[i]]
			--print(#collision_events)
			
			for _, e in ipairs(collision_events) do
				if e.collision_type == 'enter' then
					local object = e.collider_2:getObject()   
					
					if object then
						if object.hit then object:hit(100)
						elseif object.die then object:die()
						else object.dead = true end
					end
				end
			end
		end	
	end
end

function LaserLine:draw()
--	pushRotate(self.x1, self.y1, self.r)
--	local x, y = self.collider:getPosition()
--	love.graphics.rectangle('fill', x, y, self.width, 20)
--	love.graphics.pop()
	--love.graphics.polygon('line', self.points)
	local p1 = self.points.getPointByNumber(1)
	local p2 = self.points.getPointByNumber(2)
	local p3 = self.points.getPointByNumber(3)
	local p4 = self.points.getPointByNumber(4)
	
	local x1, y1, x2, y2 = (p1.x + p2.x)/2, (p1.y + p2.y)/2, (p3.x + p4.x)/2, (p3.y + p4.y)/2
	
	local sin_plus  = math.sin(self.r + math.pi/2)*(self.max_main_line_width/2 + self.secondary_lines_offset)
	local cos_plus  = math.cos(self.r + math.pi/2)*(self.max_main_line_width/2 + self.secondary_lines_offset)
	local sin_minus = math.sin(self.r - math.pi/2)*(self.max_main_line_width/2 + self.secondary_lines_offset)
	local cos_minus = math.cos(self.r - math.pi/2)*(self.max_main_line_width/2 + self.secondary_lines_offset)
	
	love.graphics.setLineWidth(self.main_line_width)
	love.graphics.setColor(default_color)
	love.graphics.line(x1, y1, x2, y2)
	love.graphics.setLineWidth(self.secondary_line_width)
	love.graphics.setColor(hp_color)
	love.graphics.line(x1+cos_plus, y1+sin_plus, x2+cos_plus, y2+sin_plus)
	love.graphics.line(x1+cos_minus, y1+sin_minus, x2+cos_minus, y2+sin_minus)
	
	
	
	
--	love.graphics.line(self.x1 + math.cos(self.r+math.pi/2)*10, self.y1 + math.sin(self.r+math.pi/2)*10, 
--		               self.x1 + self._vector.x + math.cos(self.r+math.pi/2)*10, self.y1 + self._vector.y + math.sin(self.r+math.pi/2)*10)
				   
--	love.graphics.line(self.x1 + math.cos(self.r-math.pi/2)*10, self.y1 + math.sin(self.r-math.pi/2)*10, 
--		               self.x1 + self._vector.x + math.cos(self.r-math.pi/2)*10, self.y1 + self._vector.y + math.sin(self.r-math.pi/2)*10)
	--love.graphics.rectangle('line', self.x1, self.y1, self.width, 20)
end


function LaserLine:killAllEnemies()

end


