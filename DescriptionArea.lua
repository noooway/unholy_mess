local vector = require "vector"
local ui = require "ui"

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

local DescriptionArea = {}
DescriptionArea.__index = DescriptionArea

function DescriptionArea:new( o )
   o = o or {}
   setmetatable( o, self )
   o.bounding_frame = ui.Frame:new{
      position = vector( 0.05 * screen_w, 0.55 * screen_h ),
      width = 0.9 * screen_w,
      height = 0.40 * screen_h,
      draw_frame = true,
      scissors = false
   }
   --
   o.project_title_widget = ui.Textfield:new{
      position = vector( 0.10 * screen_w, 0.57 * screen_h ),
      width = 0.25 * screen_w,
      height = 0.05 * screen_h,
      text = "Project Title"
   }
   o.bounding_frame:add_widget( o.project_title_widget )
   --
   o.start_date_widget = ui.Textfield:new{
      position = vector( 0.37 * screen_w, 0.57 * screen_h ),
      width = 0.25 * screen_w,
      height = 0.05 * screen_h,
      text = "Start Date"
   }
   o.bounding_frame:add_widget( o.start_date_widget )
   --
   o.end_date_widget = ui.Textfield:new{
      position = vector( 0.65 * screen_w, 0.57 * screen_h ),
      width = 0.25 * screen_w,
      height = 0.05 * screen_h,
      text = "End Date"
   }
   o.bounding_frame:add_widget( o.end_date_widget )
   --
   o.textfield = ui.Textfield:new{
      id = "textfield",
      position = vector( 0.10 * screen_w, 0.64 * screen_h ),
      width = 0.8 * screen_w,
      height = 0.30 * screen_h,
      text = "project description"
   }
   o.bounding_frame:add_widget( o.textfield )
   --
   o.invisible = true or o.invisible
   o.widget_type = "DescriptionArea"
   return o
end


function DescriptionArea:update( dt )
   if self.invisible then
      return
   end
   self.bounding_frame:update( dt )
end


function DescriptionArea:draw()
   if self.invisible then
      return
   end
   self.bounding_frame:draw()
end


function DescriptionArea:mousereleased( x, y, button, istouch )
   if self.invisible then
      return
   end
   self.project_title_widget:mousereleased( x, y, button, istouch )
   self.start_date_widget:mousereleased( x, y, button, istouch )
   self.end_date_widget:mousereleased( x, y, button, istouch )   
end

function DescriptionArea:textinput( t )
   if self.invisible then
      return
   end
   self.project_title_widget:textinput( t )
   if self.project_title_widget.project_btn and
   self.project_title_widget.text ~= self.project_title_widget.project_btn.text then
      self.project_title_widget.project_btn.text = self.project_title_widget.text
      self.project_title_widget.project_btn.project.name = self.project_title_widget.text
   end
   self.start_date_widget:textinput( t )
   self.end_date_widget:textinput( t )
end

function DescriptionArea:keyreleased( key, scancode )
   if self.invisible then
      return
   end
   --same as textinput to catch backspace and del
   self.project_title_widget:keyreleased( key, scancode )
   if self.project_title_widget.project_btn and
   self.project_title_widget.text ~= self.project_title_widget.project_btn.text then
      self.project_title_widget.project_btn.text = self.project_title_widget.text
      self.project_title_widget.project_btn.project.name = self.project_title_widget.text
   end
   self.start_date_widget:keyreleased( key, scancode )
   self.end_date_widget:keyreleased( key, scancode )
end

return DescriptionArea
