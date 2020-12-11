local Grid = require "world/grid"
local cmp = require "component"
local Particles = require "particles.init"

local World = class "World"

local tinsert = table.insert
local tremove = table.remove

local TIME_STEP = 0.016

function World:init(width, height)
	self.width = width or 160
	self.height = height or 160

	self.particle_manager = Particles.Manager()
	self.drawables = {}
	self.entities = {}
	self.ui_drawbales = {}

	self.grid = Grid(self, 5, 5)

	self.time_elapsed = 0
end

function World:draw()
	for i = 1, #self.drawables do
		self.drawables[i]:draw()
	end
	self.particle_manager:draw()
	-- * DEBUG CODE
	-- self.grid:draw()

	-- lg.setColor(1, 0, 0, 1)

	-- for i = 1, #self.entities do
	-- 	local e = self.entities[i]
	-- 	lg.setColor(1, 0.1, 0.1)
	-- 	if e:has_component(cmp.Collider) then
	-- 		e:get_component(cmp.Collider):draw()
	-- 	end
	-- end

	-- lg.setColor(1, 1, 1, 1)
	-- love.graphics.rectangle("line", 0, 0, self.width, self.height)
	-- * / DEBUG CODE
end

function World:ui_layer()
	for _, ui_el in ipairs(self.ui_drawbales) do
		ui_el:draw()
	end
end

-- remove all 'dead' gameobjects/entities
-- from the entities array. Does the same for all 
-- drawables.
function World:clear_garbage()
	for i = #self.drawables, 1, -1 do
		local d = self.drawables[i]
		if d._delete_flag then
			tremove(self.drawables, i)
			d._delete_flag = false
		end
	end

	for i = #self.entities, 1, -1 do
		local e = self.entities[i]
		if e._delete_flag then
			tremove(self.entities, i)
			e._delete_flag = false
		end
	end

	for i = #self.ui_drawbales, 1, -1 do
		local d = self.drawables[i]
		if d._delete_flag then
			tremove(self.drawables, i)
			d._delete_flag = false
		end
	end
end

function World:update(dt)
	self:clear_garbage()
	self.time_elapsed = self.time_elapsed + dt

	for i = #self.entities, 1, -1 do
		self.entities[i]:update(dt)
		self:bounds_check(self.entities[i])
	end

	while self.time_elapsed >= TIME_STEP do
		self:_physics_process(self.time_elapsed)
		self.time_elapsed = self.time_elapsed - TIME_STEP
	end

	self.particle_manager:update(dt)
end

-- check if an entity's collider is outside the level's rectangle bounds.
-- If so, then clamp the entity's position and call the 
-- 'on_world_exit' callback.
function World:bounds_check(e)
	if not e:has_component(cmp.Collider) then
		return
	end

	local collider = e:get_component(cmp.Collider)
	local pos = collider:get_pos()

	if pos.x < collider.width / 2 or pos.x > self.width - collider.width / 2 or
			pos.y > self.height - collider.height / 2 or pos.y < collider.height / 2 then
		local p = Vec2(sugar.clamp(pos.x, collider.width / 2,
				self.width - collider.width / 2), sugar.clamp(pos.y, collider.height / 2,
				self.height - collider.height / 2))
		e:set_pos(p)
		if collider.owner.on_world_exit then
			collider.owner:on_world_exit()
			return
		end
	end

end

function World:_physics_process(dt)
	self.grid:clear()

	for i = #self.entities, 1, -1 do
		local e = self.entities[i]
		-- ? refactor this out into a collider array ??
		if self.entities[i]:has_component(cmp.Collider) then
			self.grid:insert(self.entities[i]:get_component(cmp.Collider))
		end
		e:_physics_process(dt)
	end

	self.grid:process_collisions()
end

function World:add_drawable(d)
	-- TODO: after depth sorting, change this logic
	--  to insert in sorted array
	tinsert(self.drawables, d)
end

function World:add_ui_element(el)
	tinsert(self.ui_drawbales, el)
end

function World:remove_ui_element(el)
	el._delete_flag = true
end

function World:add_gameobject(e)
	-- TODO: register and handle collision classes as well
	e.world = self
	tinsert(self.entities, e)
end

function World:remove_drawable(d)
	d._delete_flag = true
end

function World:remove_gameobject(g)
	g._delete_flag = true
end

function World:query(shape, x, y, w, h)
	return self.grid:query(shape, x, y, w, h)
end

function World:add_particle_system(sys)
	self.particle_manager:add_system(sys)
	return sys
end

function World:remove_particle_system(sys)
	self.particle_manager:remove_system(sys)
end

return World
