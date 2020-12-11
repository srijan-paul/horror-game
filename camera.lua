local Transform = require "component/transform"

local camera = {
	pos = Vec2.ZERO(),
	scaleX = 1,
	scaleY = 1,
	offset = Vec2.ZERO(),
	follow_target = nil
}

function camera:reset()
	self.pos = Vec2.ZERO()
	self.scaleX, self.scaleY = 1, 1
	self.offset = Vec2.ZERO()
	self.follow_target = nil
end

function camera:setPos(x, y)
	if not y then -- if only a vector is fed
		self.pos.x = x.x
		self.pos.y = x.y
	end
	self.pos.x = x
	self.pos.y = y
end

function camera:follow(entity)
	self.follow_target = entity:get_component(Transform)
end

function camera:update(dt)
	if not self.follow_target.pos then
		return
	end
	self.pos.x = self.follow_target.pos.x - (SC_WIDTH * self.scaleX) / 2
	self.pos.y = self.follow_target.pos.y - (SC_HEIGHT * self.scaleY) / 2
end

function camera:set()
	love.graphics.push()
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-(self.pos.x + self.offset.x),
			-(self.pos.y + self.offset.y))
end

function camera:unset()
	love.graphics.pop()
end

function camera:zoom(z)
	self.scaleX = 1 / z
	self.scaleY = 1 / z
end

function camera:get_zoom()
	return 1 / self.scaleX
end

function camera:scale(sx, sy)
	self.scaleX = self.scaleX * sx
	self.scaleY = self.scaleY * sy
end

function camera:toScreenX(x)
	return (x - self.pos.x) / self.scaleX
end

function camera:toScreenY(y)
	return (y - self.pos.y) / self.scaleY
end

function camera:toWorldX(x)
	return (x * self.scaleX) + self.pos.x
end

function camera:toWorldY(y)
	return (y * self.scaleY) + self.pos.y
end

function camera:toWorldPos(vec)
	local x = (vec.x * self.scaleX) + self.pos.x
	local y = (vec.y * self.scaleY) + self.pos.y
	return Vec2(x, y)
end

function camera:toScreenPos(vec)
	return Vec2(self:toScreenX(vec.x), self:toScreenY(vec.y))
end

function camera:move(vel)
	self.pos = self.pos + vel
end

return camera
