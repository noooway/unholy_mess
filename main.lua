local vector = require "vector"
local ui = require "ui"
local luatable = require "LuaTable"

local Journal = require "Journal"
local Project = require "Project"

local main_window = require "main_window"


--
-- journal_serialized = luatable.encode_pretty( journal )
-- success, message = love.filesystem.write("test_journal.lua",
-- 					 journal_serialized )
-- print( success, message )
-- local file, err = io.open( "./pockethole/saved_journal.lua", "wb" )
-- if err then return err end
-- file:write( journal_serialized )
-- file:close()
--

local roboto_font = love.graphics.newFont( "/fonts/Roboto-Regular.ttf" )

function love.load()
   love.graphics.setFont( roboto_font )
   journal = Journal:load_from_file( "saved_journal" )
   main_window.init_from_journal( journal )
end

function love.update( dt )
   main_window.update( dt )
end
 
function love.draw()
   main_window.draw()
end

function love.mousepressed( x, y, button, istouch )
   main_window.mousepressed( x, y, button, istouch )
end

function love.mousereleased( x, y, button, istouch )
   main_window.mousereleased( x, y, button, istouch )
end

-- function love.mousemoved( x, y, dx, dy, istouch )
--    main_window.mousemoved( x, y, dx, dy, istouch )
-- end

function love.wheelmoved( x, y )
   main_window.wheelmoved( x, y )
end


function love.keyreleased( key, scancode )
   main_window.keyreleased( key, scancode )
end

function love.textinput( t )
   main_window.textinput( t )
end


function love.quit()
  print("Thanks for playing! Come back soon!")
end
