local vector = require "vector"
local ui = require "ui"
local Timeline = require "Timeline"

local luatable = require "LuaTable"

local Journal = require "Journal"
local Project = require "Project"


local function sign( x )
   if x < 0 then
      return -1
   else
      return 1
   end
end

local screen_w = love.graphics.getWidth()
local screen_h = love.graphics.getHeight()

local ProjectsArea = {}
ProjectsArea.__index = ProjectsArea

function ProjectsArea:new( o )
   o = o or {}
   setmetatable( o, self )
   o.bounding_frame = ui.Frame:new{
      position = vector( 0.05 * screen_w, 0.05 * screen_h ),
      width = 0.9 * screen_w,
      height = 0.45 * screen_h,
      draw_frame = true,
      scissors = true
   }
   o.timeline = Timeline:new()
   o.projects_frame = ui.Frame:new{
      position = vector( 0.05 * screen_w, 0.15 * screen_h ),
      width = 0.9 * screen_w,
      height = 0.35 * screen_h,
      draw_frame = true,
      scissors = true
   }
   o.projects_frame.drag_and_drop = ui.DragAndDrop:new{
      position = o.projects_frame.position,
      width = o.projects_frame.width,
      height = o.projects_frame.height
   }
   -- todo: place inside o.bounding_frame
   o.lowest_button = o.lowest_button or 0
   o.widget_type = "ProjectsArea"
   return o
end


function ProjectsArea:recursively_add_projects( proj )
   local project_button_height = 0.05 * screen_h
   local space_between_buttons = 0.01 * screen_h
   local y_offset = 0.16 * screen_h
   local x_pos, project_button_width = self.timeline:compute_x_and_width_for_dates(
      proj.start_date, proj.end_date
   )
   local pos = vector(
      x_pos, 
      y_offset + ( project_button_height + space_between_buttons ) * self.lowest_button )
   local btn = ui.Button:new{
      computed_position = pos,
      position = pos, 
      width = project_button_width,
      height = project_button_height,
      text = proj.name,
      widget_type = "project",
      project = proj
   }
   self.projects_frame:add_widget( btn )
   self.lowest_button = self.lowest_button + 1      
   for _, subproj in ipairs( proj.subprojects ) do
      self:recursively_add_projects( subproj )
   end
end



function ProjectsArea:update( dt )
   self.bounding_frame:update( dt )
   self.timeline:update( self.projects_frame.drag_and_drop.current_drag_distance,
			 self.projects_frame.drag_and_drop.total_drag_distance,
			 dt )
   self.projects_frame.drag_and_drop:update( dt )
   self:update_project_buttons_with_drag( dt )
   self.projects_frame:update( dt )
end


function ProjectsArea:update_project_buttons_with_drag( dt )
   -- Todo: recompute proj positions from timeline? What about y-axis?
   for k, v in ipairs( self.projects_frame:children_of_type( 'project' ) ) do
      v.position = v.computed_position +
	 self.projects_frame.drag_and_drop.current_drag_distance +
	 self.projects_frame.drag_and_drop.total_drag_distance
   end
end


function ProjectsArea:draw()
   self.bounding_frame:draw()
   self.timeline:draw()
   self:draw_time_intervals_separating_lines()
   self.projects_frame:draw()
   --self.projects_frame.drag_and_drop:draw()
end

function ProjectsArea:draw_time_intervals_separating_lines()
   local separating_lines = self.timeline:determine_separating_lines()
   local y1 = self.timeline.button.position.y
   local y2 = self.projects_frame.position.y + self.projects_frame.height
   local lw = love.graphics.getLineWidth()
   for _, line in ipairs( separating_lines ) do
      love.graphics.setLineWidth( line["line_width"] )
      love.graphics.line( line["x"], y1, line["x"], y2 )
   end
   love.graphics.setLineWidth( lw )
end


function ProjectsArea:mousepressed( x, y, button, istouch )
   local projects_frame_in_focus = self.projects_frame.cursor_hovering
   self.projects_frame.drag_and_drop:mousepressed( projects_frame_in_focus, x, y, button )
end


-- function main_window.process_rmb_menu_mousepress( x, y, button, istouch )
--    for i, widget in ipairs( main_window.projects_area.projects_frame.children ) do
--       if widget.widget_type == "rmb_menu" then
-- 	 if not widget:mousereleased( x, y, button ) then
-- 	    table.remove( main_window.projects_area.projects_frame.children, i )
-- 	 end
-- 	 if widget:mousereleased( x, y, button ) then
-- 	    print( "rmb_menu" )
-- 	 end	 
--       end
--    end         
-- end


function ProjectsArea:mousereleased( x, y, button )
   self.projects_frame.drag_and_drop:mousereleased( x, y, button )
   -- return self.cursor_hovering 
end

-- function main_window.gen_add_remove_project_menu_on_click( x, y, button, istouch )
--    local click_on_empty = true
--    for _, widget in ipairs( main_window.projects_area.projects_frame.children ) do
--       if widget.widget_type == "project" then
-- 	 if widget:mousereleased( x, y, button ) and
-- 	 ( button == '2' or button == 'r' ) then
-- 	    local rmb_menu = ui.ListMenu:new{
-- 	       position = vector( x, y ),
-- 	       width = 0.1 * screen_w,
-- 	       items = {"add", "del", "hide"},
-- 	       item_height = 0.05 * screen_h,
-- 	       widget_type = 'rmb_menu',
-- 	       cursor_hovering = true
-- 	    }
-- 	    main_window.projects_area.projects_frame:add_widget( rmb_menu )
-- 	    click_on_empty = false
-- 	 end
--       end
--    end
--    if click_on_empty and ( button == '2' or button == 'r' ) and 
--    main_window.projects_area.projects_frame:mousereleased( x, y, button, istouch ) then
--       local rmb_menu = ui.ListMenu:new{
-- 	 position = vector( x, y ),
-- 	 width = 0.1 * screen_w,
-- 	 items = { "add project", "del project" },
-- 	 item_height = 0.05 * screen_h,
-- 	 widget_type = 'rmb_menu',
-- 	 cursor_hovering = true
--       }
--       main_window.projects_area.projects_frame:add_widget( rmb_menu )      
--    end
-- end



return ProjectsArea
