require "lib/utils"
require "lib/globals"
require "lib/utf8"

Object = require "lib/classic"
Timer = require "lib/EnhancedTimer"
Camera = require "lib/hump/camera"
Input  = require "lib/input"
Physics = require "lib/windfield/"
Moses = require "lib/moses"
Draft = require "lib/draft"
Vector = require "lib/hump/vector"

require "lib/shake"

require "objects/GameObject"
require "objects/Stage"

function love.load()
    local object_files = {}

	--ob = Object:extend()
	fonts = {}

	input  = Input()
	camera = Camera()
	timer  = Timer()
	fn     = Moses()
	draft  = Draft()

    recursiveEnumerate('objects', object_files)
	requireFiles(object_files)

	fonts.m5x7_16 = love.graphics.newFont("resourses/fonts/m5x7.ttf", 16);

	--love.graphics.setDefaultFilter('nearest')
	--love.graphics.setLineStyle('rough')

	input:bind('left', 'left')
	input:bind('right', 'right')
	input:bind('up', 'up')
	input:bind('down', 'down')

	current_room = nil
	slow_amount = 1

	gotoRoom('Stage', 'NewRoom'..(rooms and #rooms or 1))

	resize(3)

	standard_font = love.graphics.getFont()

end

function love.draw()
	if current_room then
		current_room:draw()
	end

	if flash_frames then
        flash_frames = flash_frames - 1

        if flash_frames == -1 then
			flash_frames = nil
		end
    end

    if flash_frames then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle('fill', 0, 0, sx*gw, sy*gh)
        love.graphics.setColor(255, 255, 255)
    end
	--print(type(current_room))
end

function love.update(dt)
	timer:update(dt * slow_amount)
	camera:update(dt * slow_amount)

	if current_room then
		current_room:update(dt * slow_amount)
	end
end


function addRoom(room_type, room_name, ...)
    local room = _G[room_type](room_name, ...)

	if not rooms then
		rooms = {}
	end

    rooms[room_name] = room
    return room
end

function gotoRoom(room_type, room_name, ...)
    if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
end

function resize(s)
    love.window.setMode(s*gw, s*gh)
    sx, sy = s, s
end

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
		--print(item)
        local file = folder .. '/' .. item
		--print (love.filesystem.getInfo(file).type)
        if love.filesystem.getInfo(file).type == 'file' then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)

    for _, file in ipairs(files) do
        local _file = file:sub(1, -5)
		--print(_file)
        require(_file)
    end
end


--[[

COUNTING OBJECTS, TYPES E.T.C.

]]--


function count_all(f)
    local seen = {}
    local count_table

    count_table = function(t)
        if seen[t] then
			return
		end

        f(t)
	    seen[t] = true

	    for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
    end

    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end

    count_all(enumerate)

    return counts
end

global_type_table = nil

function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
		for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
		global_type_table[0] = "table"
    end

    return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function slow(amount, duration)
    slow_amount = amount
	timer:tween('slow', duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function flash(frames)
	flash_frames = frames
end
