local utf8 = require( "utf8" )
local vector = require "vector"

local ui = {}

-- utils

-- todo: add vectors

local function table_length( T )
   local count = 0
   for _ in pairs( T ) do count = count + 1 end
   return count
end

local function utf8_sub( s, i, j )
   -- https://stackoverflow.com/questions/43138867/lua-unicode-using-string-sub-with-two-byted-chars
   i = utf8.offset( s, i )
   j = utf8.offset( s, j + 1 ) - 1
   return string.sub( s, i, j )
end


local function point_inside_rectangle( point_x, point_y,
				       top_left_x, top_left_y,
				       width, height )
   return
      top_left_x < point_x and
      point_x < top_left_x + width and
      top_left_y < point_y and
      point_y < top_left_y + height   
end

-- Button

local Button = {}
Button.__index = Button

function Button:new( o )
   o = o or {}
   setmetatable( o, self )
   o.position = o.position or vector( 300, 300 )
   o.width = o.width or 100
   o.height = o.height or 50
   o.text = o.text or "hello"
   o.cursor_hovering = false   
   return o
end

function Button:update( dt )
   local mouse_pos = vector( love.mouse.getPosition() )
   if self:inside( mouse_pos ) then
      self.cursor_hovering = true
   else
      self.cursor_hovering = false
   end
end

function Button:draw()
   love.graphics.rectangle( 'line',
			    self.position.x,
			    self.position.y,
			    self.width,
			    self.height )
   if self.cursor_hovering then
      local r, g, b, a = love.graphics.getColor()
      love.graphics.setColor( 255, 150, 0, 200 )
      love.graphics.print( self.text,
			   self.position.x,
			   self.position.y )
      love.graphics.setColor( r, g, b, a )
   else
      love.graphics.print( self.text,
			   self.position.x,
			   self.position.y )	 
   end
end

function Button:inside( pos )
   return
      self.position.x < pos.x and
      pos.x < ( self.position.x + self.width ) and
      self.position.y < pos.y and
      pos.y < ( self.position.y + self.height )
end

function Button:mousereleased( x, y, button )
   return self.cursor_hovering 
end


-- ListMenu

local ListMenu = {}
ListMenu.__index = ListMenu

function ListMenu:new( o )
   o = o or {}
   setmetatable( o, self )
   o.position = o.position or vector( 300, 300 )
   o.items = o.items or {}
   o.item_height = o.item_height or 20
   o.width = o.width or 100
   o.height = table_length( o.items ) * o.item_height
   o.label_shift = o.label_shift or vector( 0, 0 )
   o.cursor_hovering = false
   o.item_in_focus = o.item_in_focus or nil
   return o
end

function ListMenu:update( dt )
   local mouse_pos = vector( love.mouse.getPosition() )
   if self:inside( mouse_pos ) then
      self.cursor_hovering = true
   else
      self.cursor_hovering = false
   end
   -- todo: move to separate function
   local item_in_focus = nil
   for k, v in ipairs( self.items ) do
      if self.position.x < mouse_pos.x and
	 mouse_pos.x < self.position.x + self.width and 
	 self.position.y + self.item_height * (k-1) < mouse_pos.y and
	 mouse_pos.y < self.position.y + self.item_height * k
      then
	 item_in_focus = k
      end
   end
   self.item_in_focus = item_in_focus
end

function ListMenu:draw()
   love.graphics.rectangle( 'line',
			    self.position.x,
			    self.position.y,
			    self.width,
			    self.height )
   for k, v in ipairs( self.items ) do
      if k == self.item_in_focus then
	 local r, g, b, a = love.graphics.getColor()
	 love.graphics.setColor( 255, 150, 0, 200 )
	 love.graphics.print(
	    v,
	    self.position.x + self.label_shift.x,
	    self.position.y + self.item_height * (k-1) + self.label_shift.y )
	 love.graphics.setColor( r, g, b, a )
      else
	 love.graphics.print(
	    v,
	    self.position.x + self.label_shift.x,
	    self.position.y + self.item_height * (k-1) + self.label_shift.y )
      end
   end
end

function ListMenu:inside( pos )
   return
      self.position.x < pos.x and
      pos.x < ( self.position.x + self.width ) and
      self.position.y < pos.y and
      pos.y < ( self.position.y + self.height )
end

function ListMenu:mousereleased( x, y, button )
   return self.item_in_focus
end


-- DropdownMenu

local DropdownMenu = {}
DropdownMenu.__index = DropdownMenu

function DropdownMenu:new( o )
   o = o or {}
   setmetatable( o, self )
   --
   local position = o.position or vector( 300, 300 )
   local width = o.width or 100
   local item_height = o.item_height or 20
   local items = o.items or {"go", "to", "hell"}
   local label_shift = o.label_shift or vector( 0, 0 )
   --
   o.button_or_menu = o.button_or_menu or 'button'
   o.button = Button:new{
      position = position,
      width = width,
      height = item_height,
      text = items[1]
   }
   o.menu = ListMenu:new{
      position = position,
      items = items,
      item_height = item_height,
      width = width,
      label_shift = label_shift
   }
   o.button_menu_switch = {
      button = o.button,
      menu = o.menu
   }
   return o
end


function DropdownMenu:update( dt )
   self.button_menu_switch[ self.button_or_menu ]:update( dt )
end

function DropdownMenu:draw()
   self.button_menu_switch[ self.button_or_menu ]:draw()
   if self.button_or_menu == 'button' then
      self:draw_dropdown_symbol_on_button()
   end
end

function DropdownMenu:draw_dropdown_symbol_on_button()
   local shift = 3
   love.graphics.print( '+',
			self.button.position.x + self.button.width - shift,
			self.button.position.y - shift )   
end

function DropdownMenu:mousereleased( x, y, button )
   local w = self.button_menu_switch[ self.button_or_menu ]
   if self.button_or_menu == 'button' and w:mousereleased( x, y, button ) then
      self.button_or_menu = 'menu'
   elseif self.button_or_menu == 'menu' then
      local item_index = w:mousereleased( x, y, button )
      if item_index then
	 self.button.text = w.items[item_index]
      end
      self.button_or_menu = 'button'      
   end
end


-- Textfield


local Textfield = {}
Textfield.__index = Textfield

function Textfield:new( o )
   o = o or {}
   setmetatable( o, self )
   o.position = o.position or vector( 300, 300 )
   o.width = o.width or 100
   o.height = o.height or 50
   o.text = o.text or "hello"
   o.typing_position = o.typing_position or utf8.len( o.text ) + 1
   o.cursor_hovering = o.cursor_hovering or false
   o.preferred_cursor = o.preferred_cursor or love.mouse.getSystemCursor( "ibeam" )
   o.in_focus = o.in_focus or false
   --o.is_text_changed = o.is_text_changed or false
   return o
end

function Textfield:update( dt )
   local mouse_pos = vector( love.mouse.getPosition() )
   if self:inside( mouse_pos ) then
      self.cursor_hovering = true     
   else
      self.cursor_hovering = false
   end
end

function Textfield:draw()
   if self.in_focus then
      love.graphics.rectangle( 'line',
			       self.position.x,
			       self.position.y,
			       self.width,
			       self.height )
      local r, g, b, a = love.graphics.getColor()
      love.graphics.setColor( 255, 150, 0, 200 )
      love.graphics.print( self.text,
      			   self.position.x,
      			   self.position.y )
      self:show_typing_invitation()
      love.graphics.setColor( r, g, b, a )
   else
      love.graphics.rectangle( 'line',
			       self.position.x,
			       self.position.y,
			       self.width,
			       self.height )
      love.graphics.print( self.text,
      			   self.position.x,
      			   self.position.y )
      self:show_typing_invitation()
   end   
end

function Textfield:show_typing_invitation()
   if self.in_focus then
      local width = 0
      if self.typing_position > 1 then
	 local substr = utf8_sub( self.text, 1, self.typing_position - 1 )
	 local font = love.graphics.getFont()
	 width = font:getWidth( substr )
      end
      love.graphics.print( "|",
			   self.position.x + width,
			   self.position.y )
   end
end

function Textfield:inside( pos )
   return
      self.position.x < pos.x and
      pos.x < ( self.position.x + self.width ) and
      self.position.y < pos.y and
      pos.y < ( self.position.y + self.height )
end

function Textfield:mousereleased( x, y, button )
   if self.cursor_hovering then
      self.in_focus = true
   else
      self.in_focus = false
   end
   return self.in_focus
end

function Textfield:textinput( t )
   if self.in_focus then
      if self.typing_position == 1 then
	 self.text = t .. self.text
      elseif self.typing_position - 1 == utf8.len( self.text ) then
	 self.text = self.text .. t
      else
	 local left_substr = utf8_sub( self.text, 1, self.typing_position - 1 )
	 local right_substr = utf8_sub( self.text, self.typing_position,
					utf8.len( self.text ) )
	 self.text = left_substr .. t .. right_substr
      end
      self.typing_position = self.typing_position + 1
      --self.is_text_changed = true
   end
end

function Textfield:keyreleased( key, scancode )
   if self.in_focus then
      if key == "backspace" then	 
	 if self.typing_position == 2 then
	    local right_substr = utf8_sub( self.text, self.typing_position,
					   utf8.len( self.text ) )
	    self.text = right_substr
	    self.typing_position = self.typing_position - 1
	 elseif self.typing_position > 2 then
	    local left_substr = utf8_sub( self.text, 1, self.typing_position - 2 )
	    local right_substr = utf8_sub( self.text, self.typing_position,
					   utf8.len( self.text ) )	    
	    self.text = left_substr .. right_substr	    
	    self.typing_position = self.typing_position - 1
	 end	 
      elseif key == "right" then
	 if self.typing_position < utf8.len( self.text ) + 1 then
	    self.typing_position = self.typing_position + 1
	 end
      elseif key == "left" then
	 if self.typing_position > 1 then
	    self.typing_position = self.typing_position - 1
	 end
      end
   end
end

function Textfield:set_text( text )
   self.text = text
   self.typing_position = utf8.len( self.text ) + 1
end


-- Frame


local Frame = {}
Frame.__index = Frame

function Frame:new( o )
   o = o or {}
   setmetatable( o, self )
   o.position = o.position or vector( 0, 0 )
   o.width = o.width or 300
   o.height = o.height or 200
   o.draw_frame = o.draw_frame or true
   o.scissors = o.scissors or false
   o.children = o.children or {}
   o.cursor_hovering = false
   o.in_focus = o.in_focus or false
   o.preferred_cursor = o.preferred_cursor or love.mouse.getSystemCursor( "arrow" )
   return o
end

function Frame:add_widget( w )
   table.insert( self.children, w )
end

function Frame:children_of_type( widget_type )
   local childs = {}
   for k, v in ipairs( self.children ) do
      if v.widget_type and v.widget_type == widget_type then
	 table.insert( childs, v )
      end
   end
   return childs
end

function Frame:update( dt )
   for k, v in ipairs( self.children ) do
      v:update( dt )
   end
   local mouse_pos = vector( love.mouse.getPosition() )
   if self:inside( mouse_pos ) then
      self.cursor_hovering = true
   else
      self.cursor_hovering = false
   end
end

function Frame:update_cursor()
   local cursor = self.preferred_cursor
   for i, w in ipairs( self.children ) do
      if w.preferred_cursor and w.cursor_hovering then
	 cursor = w.preferred_cursor
	 break
      end      
   end
   love.mouse.setCursor( cursor )
end

function Frame:draw()
   if self.draw_frame then
      love.graphics.rectangle( 'line',
			       self.position.x,
			       self.position.y,
			       self.width,
			       self.height )      
   end
   if self.scissors then
      love.graphics.setScissor( self.position.x,
				self.position.y,
				self.width,
				self.height )
   end
   for k, v in ipairs( self.children ) do
      v:draw()
   end
   if self.scissors then
      love.graphics.setScissor()
   end
end

function Frame:inside( pos )
   return
      self.position.x < pos.x and
      pos.x < ( self.position.x + self.width ) and
      self.position.y < pos.y and
      pos.y < ( self.position.y + self.height )
end

function Frame:mousereleased( x, y, button )      
   return self.cursor_hovering
end

function Frame:detect_click( x, y, button )
   local inside = true
   inside = inside and self.cursor_hovering
   for k, v in ipairs( self.children ) do
      inside = inside and not( v.cursor_hovering )
   end
   if inside then
      self.in_focus = true
   end
end


-- Mousetrap extension
-- todo

-- DragAndDrop extension

local DragAndDrop = {}
DragAndDrop.__index = DragAndDrop

function DragAndDrop:new( o )
   o = o or {}
   setmetatable( o, self )
   o.position = o.position or vector( 300, 300 )
   o.width = o.width or 100
   o.height = o.height or 50
   o.cursor_hovering = o.cursor_hovering or false
   o.click_position = o.click_position or nil
   o.total_drag_distance = o.total_drag_distance or vector( 0, 0 )
   o.current_drag_distance = o.current_drag_distance or vector( 0, 0 )
   o.dragged = o.dragged or false
   return o
end

function DragAndDrop:update( dt )
   --if love.mouse.isDown( 1 ) or love.mouse.isDown( 'l' ) and self.dragged then
   if love.mouse.isDown( 1 ) and self.dragged then
      local mouse_pos = vector( love.mouse.getPosition() )
      self.current_drag_distance = mouse_pos - self.click_position
      --self.current_drag_distance = self.click_position - mouse_pos
      --print( "drag", self.current_drag_distance )
   end
end

function DragAndDrop:draw()
   -- For debugging
   local r, g, b, a = love.graphics.getColor()
   love.graphics.setColor( 255, 0, 0, 150 )
   love.graphics.rectangle( 'line',
			    self.position.x,
			    self.position.y,
			    self.width,
			    self.height )
   love.graphics.print( "drag-and-drop frame",
			self.position.x,
			self.position.y )	 
   love.graphics.setColor( r, g, b, a )
end

function DragAndDrop:mousepressed( is_widget_in_focus, x, y, button )
   if is_widget_in_focus then
      self.click_position = vector( x, y )
      self.dragged = true
   end
end

function DragAndDrop:mousereleased( x, y, button )
   if self.dragged then
      self.dragged = false
      self.total_drag_distance = self.total_drag_distance + self.current_drag_distance
      self.current_drag_distance = vector( 0, 0 )
   end
end


-- Scroll extension

local Scroll = {}
Scroll.__index = Scroll

function Scroll:new( o )
   o = o or {}
   setmetatable( o, self )
   o.position = o.position or vector( 300, 300 )
   o.width = o.width or 100
   o.height = o.height or 50
   o.cursor_hovering = o.cursor_hovering or false
   o.total_scroll_distance = o.total_scrol_distance or 0
   o.current_scroll_distance = o.current_scroll_distance or 0
   return o
end

function Scroll:update( dt )
   local mouse_pos = vector( love.mouse.getPosition() )
   if self:inside( mouse_pos ) then
      self.cursor_hovering = true
   else
      self.cursor_hovering = false
   end
end

function Scroll:draw()
   -- For debugging
   local r, g, b, a = love.graphics.getColor()
   love.graphics.setColor( 0, 255, 0, 150 )
   love.graphics.rectangle( 'line',
			    self.position.x,
			    self.position.y,
			    self.width,
			    self.height )
   love.graphics.print( "scroll frame",
			self.position.x,
			self.position.y )	 
   love.graphics.setColor( r, g, b, a )
end

function Scroll:wheelmoved( x, y )
   if self.cursor_hovering then
      self.current_scroll_distance = y
      self.total_scroll_distance = self.total_scroll_distance + y
   end
end

function Scroll:inside( pos )
   return
      self.position.x < pos.x and
      pos.x < ( self.position.x + self.width ) and
      self.position.y < pos.y and
      pos.y < ( self.position.y + self.height )
end


-- Update cursor

local function update_cursor( widgets, default_cursor )
   local cursor = default_cursor or love.mouse.getSystemCursor( "arrow" )
   for i, w in ipairs( widgets ) do
      if w.preferred_cursor and w.cursor_hovering then
	 cursor = w.preferred_cursor
	 break
      end      
   end
   love.mouse.setCursor( cursor )
end

--

ui.Button = Button
ui.ListMenu = ListMenu
ui.DropdownMenu = DropdownMenu
ui.Textfield = Textfield
ui.Frame = Frame
ui.DragAndDrop = DragAndDrop
ui.Scroll = Scroll
ui.update_cursor = update_cursor

return ui
