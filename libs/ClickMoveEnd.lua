--[[
Copyright 2011 Richard Jones. All rights reserved.
 
Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY RICHARD JONES ''AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL RICHARD JONES OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of Richard Jones.

The above license is known as the Simplified BSD license.
]]

require "AnAL"

Class = {}
    function Class:new(o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
    end
    
ClickMoveEnd = Class:new{
        visible = false,
        x = 0,
        y = 0,
        start_ttl = 0,
        end_ttl = 0,
        state = "start",
        to_x = 0,
        to_y = 0,
        x_target = 0,
        y_target = 0,
        left = nil,
        right = nil,
        left_middle_x = 0,
        left_middle_y = 0,
        right_middle_x = 0,
        right_middle_y = 0,
        still_frame = 1,
        animation = nil,
        speed = 50,
        music = nil,
        show_coords = false
    }
    
    function ClickMoveEnd:update(dt)
        if not self.visible then return end
        
        if self.start_ttl > 0 and self.state == "start" then
            self.start_ttl = self.start_ttl - dt
        elseif self.state == "start" then
            self.state = "move"
        end
        
        if self.state == "move" then
            if self.animation then
                self.animation:update(dt)
            end
            self:newCoords(dt)
        end
        
        if self.end_ttl > 0 and self.state == "end" then
            self.end_ttl = self.end_ttl - dt
            if self.animation then
                self.animation:seek(self.still_frame)
            end
        elseif self.state == "end" then
            self.visible = false
            if self.music then
                self.music:stop()
            end
        end
        
        if self.x == self.x_target and self.y == self.y_target then
            self.state = "end"
        end
    end
    
    function ClickMoveEnd:newCoords(dt)
        local pixels = dt * self.speed
        
        if self.x < self.x_target then
            self.x = math.min(self.x_target, self.x + pixels)
        elseif self.x > self.x_target then
            self.x = math.max(self.x_target, self.x - pixels)
        end
        
        if self.y < self.y_target then
            self.y = math.min(self.y_target, self.y + pixels)
        elseif self.y > self.y_target then
            self.y = math.max(self.y_target, self.y - pixels)
        end
    end
    
    function ClickMoveEnd:draw()
        if not self.visible then return end
        
        if self.show_coords then
            love.graphics.print(
                "Actual Coords: " .. self.x .. " " .. self.y .. "\n" ..
                "Target Coords: " .. self.x_target .. " " .. self.y_target .. "\n" ..
                "State: " .. self.state, 10, 10)
        end
        self.animation:draw(self.x, self.y)
    end
    
    function ClickMoveEnd:click(x, y, button)
        if self.visible then return end
        self.visible = true
        self.start_ttl = 2
        self.end_ttl = 3
        self.state = "start"
        if x < self.to_x then
            self.x = x - self.right_middle_x
            self.y = y - self.right_middle_y
            self.x_target = self.to_x - self.right_middle_x
            self.y_target = self.to_y - self.right_middle_y
            self.still_frame = self.right_still_frame
            self.animation = newAnimation(self.right, 210, 216, 0.1, 0)
        else
            self.x = x - self.left_middle_x
            self.y = y - self.left_middle_y
            self.x_target = self.to_x - self.left_middle_x
            self.y_target = self.to_y - self.left_middle_y
            self.animation = newAnimation(self.left, 210, 216, 0.1, 0)
            self.still_frame = self.left_still_frame
        end
        self.animation:seek(self.still_frame)
        if self.music then
            love.audio.play(self.music)
        end
    end

cme = ClickMoveEnd:new{}

function love.update(dt)
    cme:update(dt)
end

function love.draw() 
    cme:draw()
end

function love.mousereleased(x, y, button)
    cme:click(x, y, button)
end

function love.keypressed(key, unicode) 
    local x = math.random(cme.right_middle_x, 800 - cme.left_middle_x)
    local y = math.random(cme.right_middle_y, 600 - cme.right_middle_y)
    cme:click(x, y, "l")
end