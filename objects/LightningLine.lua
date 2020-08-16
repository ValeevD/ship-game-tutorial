LightningLine = GameObject:extend()

function LightningLine:new(area, x, y, opts)
    LightningLine.super.new(self, area, x, y, opts)
	
	self.lines = {}

	self.invisible = false
	self.alpha = 1
	--self.random_line_draw = false
	
--	self.timer:after(0.6, function() self.dead = true end)

	self.timer:tween(0.3, self, {alpha = 0}, 'linear', function() self.dead = true end)
	

	self:generate()
end

function LightningLine:update(dt)
    LightningLine.super.update(self, dt)
end

-- Generates lines and populates the self.lines table with them
function LightningLine:generate()
	self:generateLinesBetweenTwoPoints(self.x1, self.y1, self.x2, self.y2, 6, 40, 1)    
end

function LightningLine:generateLinesBetweenTwoPoints(x1, y1, x2, y2, depth, offsetAmount, line_width_multiplier)
	if depth <= 0 then
		--print(x1, y1, x2, y2, depth, offsetAmount)
		table.insert(self.lines, {x1 = x1, y1 = y1, x2 = x2, y2 = y2, lw = line_width_multiplier})
		return
	end
	
	local _vector = Vector(x2-x1, y2-y1):normalized():rotated(table.random({-math.pi/2, math.pi/2}))
	local xc, yc = (x1+x2)/2, (y1+y2)/2
	local x_new, y_new = xc + _vector.x * offsetAmount, yc + _vector.y * offsetAmount
	local _vector_branch = Vector(x_new - x1, y_new - y1) * 1.6
	--local len_branch = _vector_branch:len()
	local x_branch, y_branch = x1 + _vector_branch.x, y1 + _vector_branch.y
	
	self:generateLinesBetweenTwoPoints(x1, y1, x_new, y_new, depth - 1, offsetAmount/2, line_width_multiplier)
	self:generateLinesBetweenTwoPoints(x_new, y_new, x2, y2, depth - 1, offsetAmount/2, line_width_multiplier)
	
	self:generateLinesBetweenTwoPoints(x_new, y_new, x_branch, y_branch, math.floor(depth/2), offsetAmount/2, line_width_multiplier * 0.4)
	
end

function LightningLine:draw()
	if self.invisible then
		return
	end
	
    for i, line in ipairs(self.lines) do 
		
		local r, g, b = unpack(boost_color)
		love.graphics.setColor(r, g, b, self.alpha*line.lw)
		love.graphics.setLineWidth(2*line.lw)
		love.graphics.line(line.x1, line.y1, line.x2, line.y2) 

		local r, g, b = unpack(default_color)
		love.graphics.setColor(r, g, b, self.alpha*line.lw)
		love.graphics.setLineWidth(1.1*line.lw)
		love.graphics.line(line.x1, line.y1, line.x2, line.y2) 

    end
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

function LightningLine:destroy()
    LightningLine.super.destroy(self)
end