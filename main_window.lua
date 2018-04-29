local utf8 = require( "utf8" )
local luatable = require "LuaTable"

local vector = require "vector"
local ui = require "ui"
local ProjectsArea = require "ProjectsArea"
local DescriptionArea = require "DescriptionArea"

local Journal = require "Journal"
local Project = require "Project"


-- GUI
local screen_w = love.graphics.getWidth()
local screen_h = love.graphics.getHeight()

local main_window = {}

main_window.projects_area = ProjectsArea:new()
main_window.description_area = DescriptionArea:new()


function main_window.init_from_journal( journal )
   for _, proj in ipairs( journal.projects ) do
      main_window.projects_area:recursively_add_projects( proj )
   end   
end


function main_window.draw()
   main_window.projects_area:draw()
   main_window.description_area:draw()
end


function main_window.update( dt )
   main_window.projects_area:update( dt )
   main_window.description_area:update( dt )
   main_window.update_cursor_type( dt )
end


function main_window.mousepressed( x, y, button, istouch )
   main_window.projects_area:mousepressed( x, y, button, istouch )
end


function main_window.mousereleased( x, y, button, istouch )
   -- warning: order is important
   main_window.projects_area:mousereleased( x, y, button, istouch )
   main_window.update_description_on_click( x, y, button, istouch )
   -- main_window.gen_add_remove_project_menu_on_click( x, y, button, istouch )
   main_window.description_area:mousereleased( x, y, button, istouch )
end


function main_window.update_description_on_click( x, y, button, istouch )
   for _, widget in ipairs(
      main_window.projects_area.projects_frame:children_of_type( "project" )) do
      if widget:mousereleased( x, y, button ) and ( button == 1 or button == 'l' ) then
	 main_window.description_area.textfield:set_text( widget.project.description )
	 main_window.description_area.project_title_widget:set_text( widget.project.name )
	 main_window.description_area.project_title_widget.project_btn = widget 
	 main_window.description_area.start_date_widget:set_text(widget.project.start_date)
	 main_window.description_area.end_date_widget:set_text( widget.project.end_date )
	 break
      end
   end
end


function main_window.update_cursor_type( dt )
   main_window.description_area.bounding_frame:update_cursor()
end


function main_window.keyreleased( key, scancode )
   main_window.description_area:keyreleased( key, scancode )
end


function main_window.textinput( t )
   main_window.description_area:textinput( t )
end


return main_window
