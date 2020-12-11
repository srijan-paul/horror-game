local Transform = require "component/transform"
-- *AABB rect collider

local Collider = class "Collider"

function Collider:init(entity, width, height, class, offset)
	self.owner = entity
	self.width = width
	self.height = height
	-- the offset of this collider from the
	-- parent entitiy's center. Not
	-- all colliders necessarily need to be
	-- centered on the parent entity's transform

	-- For example, bullets only have a small square collider
	-- near the top.
	self.offset = offset or Vec2.ZERO()
	-- the collision class this component
	-- belongs to.
	self.class = class or ""
	-- the set of collision classes
	-- that this collider collides with.
	self.mask = {}
end

function Collider:collides_with(class)
	return self.mask[class]
end

function Collider:add_mask(class)
	self.mask[class] = true
end

function Collider:add_masks(...)
	local args = {...}
	for i = 1, #args do
		self.mask[args[i]] = true
	end
end

function Collider:get_pos()
	assert(self.owner:has_component(Transform),
			"no transform component on collider parent")
	-- transform is the center coordinate
	local t = self.owner:get_component(Transform)
	return t.pos + self.offset:rotated(t.rotation)
end

function Collider.checkAABB(r1, r2)
	-- get the top-right corner coordinates
	-- from the transform's center coordinates.
	local p1 = r1:get_pos() - Vec2(r1.width / 2, r1.height / 2)
	local p2 = r2:get_pos() - Vec2(r2.width / 2, r2.height / 2)
	return not ((p1.x > p2.x + r2.width) or (p1.x + r1.width < p2.x) or
       			(p1.y + r1.height < p2.y) or (p1.y > p2.y + r2.height))
end

function Collider.AABBdir(a, b)
	local apos = a:get_pos()
	local bpos = b:get_pos()
	local dist = apos - bpos

	if math.abs(dist.x) == math.abs(dist.y) then
		if dist.y > 0 then
			return "down"
		end
		return "up"
	elseif math.abs(dist.x) > math.abs(dist.y) then
		if (dist.x > 0) then
			return "right"
		end
		return "left"
	end

	if dist.y > 0 then
		return "down"
	end
	return "up"
end

function Collider:draw()
	local pos = self:get_pos()
	love.graphics.rectangle("line", pos.x - self.width / 2,
			pos.y - self.height / 2, self.width, self.height)
end

function Collider:update(dt)
	-- body
end

return Collider
