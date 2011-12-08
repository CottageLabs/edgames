package.path = package.path .. ";/Users/richard/Code/External/edgames/libs/?.lua;libs/?.lua"
require "ClickMoveEnd"

function love.load()
    cme = ClickMoveEnd:new{
        start_ttl = 2,
        end_ttl = 2,
        to_x = 400,
        to_y = 300,
        left = love.graphics.newImage("rabbit_left.png"),
        right = love.graphics.newImage("rabbit_right.png"),
        left_middle_x = 100,
        left_middle_y = 216 - 43,
        left_still_frame = 1,
        right_middle_x = 110,
        right_middle_y = 216 - 43,
        right_still_frame = 5,
        music = love.audio.newSource("music.mp3")
    }
end
