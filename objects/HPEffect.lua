HPEffect = GameObject:extend()

function HPEffect:new(area, x, y, opts)
	HPEffect.super.new(self, area, x, y, opts)
	
    self.current_color = default_color
    self.timer:after(0.2, function() 
        self.current_color = self.color 
        self.timer:after(0.35, function()
            self.dead = true
        end)
    end)	

    self.visible = true
    self.timer:after(0.2, function()
        self.timer:every(0.05, function() self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)
    end)

    self.sw = 1
    self.timer:tween(0.35, self, {sw = 1.4}, 'in-out-cubic')

end

function HPEffect:draw()
    if not self.visible then return end

    love.graphics.setColor(self.current_color)
	
    draft:rectangle(self.x , self.y , 1.15 * self.rect_h, 1.15 * self.rect_w, 'fill')
	draft:rectangle(self.x , self.y , 1.15 * self.rect_w, 1.15 * self.rect_h, 'fill')
    --draft:rectangle(self.x - self.rect_w / 2, self.y - self.rect_h / 2, self.rect_w, self.rect_h, 'fill')
	love.graphics.setColor(default_color)
	draft:circle(self.x, self.y, self.sw * 1.15 * self.w, nil, 'line')
	
    --love.graphics.setColor(default_color)
end