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

local function days_in_month( month_num )
   -- todo: make into table
   local n_of_days = {
      31,
      28, -- feb; todo
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
   }
   return n_of_days[ month_num ]
end

month_num_to_abbr = {
   "jan", "feb",
   "mar", "apr", "may",
   "jun", "jul", "aug",
   "sep", "oct", "nov",
   "dec"   
}




local screen_w = love.graphics.getWidth()
local screen_h = love.graphics.getHeight()

local Timeline = {}
Timeline.__index = Timeline

function Timeline:new( o )
   o = o or {}
   setmetatable( o, self )
   o.button = ui.Button:new{ -- replace with DropdownMenu
      position = vector( 0.06 * screen_w, 0.07 * screen_h ),
      width = 0.88 * screen_w,
      height = 0.05 * screen_h,
      text = ""
   }
   o.widget_type = "timeline"
   o.timescale = "month"
   o.current_date = os.date( "*t" )
   o.n_of_divisions = 31
   o:set_displayed_start_end_dates( o.current_date, o.timescale )
   o.start_day = 1
   o.end_day = 31   
   o.day_width = o.button.width / o.n_of_divisions
   return o
end

function Timeline:set_displayed_start_end_dates( current_date, timescale )
   self.current_month = current_date["month"]
   self.displayed_start_date = os.date( "*t", os.time( { year = current_date["year"],
							 month = current_date["month"],
							 day = 1 } ) )
   local n_of_days_in_month = days_in_month( self.current_month )
   if n_of_days_in_month == 31 then
      self.displayed_end_date = os.date( "*t", os.time(
					    { year = current_date["year"],
					      month = current_date["month"],
					      day = self.n_of_divisions } ) )
   elseif n_of_days_in_month == 30 then
      self.displayed_end_date = os.date( "*t", os.time(
					    { year = current_date["year"],
					      month = current_date["month"] + 1,
					      day = 1 } ) )
   else
      -- feb
      end_day = self.n_of_divisions - n_of_days_in_month
      self.displayed_end_date = os.date( "*t", os.time( {
					       year = current_date["year"],
					       month = current_date["month"] + 1,
					       day = end_day } ) )
   end
end

function Timeline:update( projects_area_current_drag, projects_area_total_drag, dt )
   self.button:update( dt )
   self:compute_labels_and_separating_lines( projects_area_current_drag,
					     projects_area_total_drag )
end


function Timeline:compute_labels_and_separating_lines( projects_area_current_drag,
						       projects_area_total_drag )
   self:compute_days_labels_and_lines( projects_area_current_drag,
				       projects_area_total_drag )
   -- self:compute_weeks_labels_and_lines
   self:compute_weeks_boundaries( projects_area_current_drag,
				  projects_area_total_drag )
   self:compute_months_labels_and_lines( projects_area_current_drag,
					 projects_area_total_drag )
   -- self:compute_months_boundaries()
end

function Timeline:compute_days_labels_and_lines( projects_area_current_drag,
						 projects_area_total_drag )
   self:update_displayed_start_and_end_dates_wrt_drag( projects_area_current_drag,
						       projects_area_total_drag )
   self:compute_days_lines_shift( projects_area_current_drag,
				  projects_area_total_drag )
   --self:generate_days_labels_and_separating_positions()
end


function Timeline:update_displayed_start_and_end_dates_wrt_drag(
      projects_area_current_drag,
      projects_area_total_drag )
   local total_x_shift = projects_area_total_drag.x + projects_area_current_drag.x
   if total_x_shift >= 0 then
      self.days_shift = - math.floor( total_x_shift / self.day_width )
   else
      self.days_shift = math.ceil( math.abs( total_x_shift ) / self.day_width )
   end
   self.shifted_start_day = self.start_day + self.days_shift
   self.shifted_end_day = self.end_day + self.days_shift
   local hours_in_days = 24
   local seconds_in_hour = 3600
   local days_shift_in_seconds = self.days_shift * hours_in_days * seconds_in_hour
   self.shifted_displayed_start_date = os.date(
      "*t", os.time( self.displayed_start_date ) + days_shift_in_seconds )
   self.shifted_displayed_end_date = os.date(
      "*t", os.time( self.displayed_end_date ) + days_shift_in_seconds )
end

function Timeline:compute_days_lines_shift( projects_area_current_drag,
					    projects_area_total_drag )
   local total_x_shift = projects_area_total_drag.x + projects_area_current_drag.x
   if total_x_shift >= 0 then
      self.days_lines_shift = total_x_shift % self.day_width
   else
      self.days_lines_shift = self.day_width -
	 ( math.abs( total_x_shift ) % self.day_width )
   end
end


-- function Timeline:generate_days_labels_and_separating_positions()
--    --self.shifted_start_day = self.start_day + self.days_shift
--    --self.shifted_end_day = self.end_day + self.days_shift   
--    --self.days_lines_shift
--    local hours_in_days = 24
--    local seconds_in_hour = 3600
--    local seconds_in_day = hours_in_days * seconds_in_hour
--    local days_shift_in_seconds = self.days_shift * hours_in_days * seconds_in_hour
--    self.days_labels = {} -- todo: warning: new table is created each update cycle
--    -- what happens to the old one?
--    -- todo: create table once; change labels
--    local date = nil
--    local day_label = nil
--    for i = 1, self.n_of_divisions do
--       date = os.time( self.shifted_displayed_start_date ) + (i-1) * seconds_in_day
--       day_label = os.date( "*t", date )["day"]
--       table.insert( self.days_labels, day_label )
--    end
-- end


function Timeline:compute_weeks_boundaries( projects_area_current_drag,
					    projects_area_total_drag )
   local days_in_week = 7
   local nearest_sunday_shift = days_in_week - self.displayed_start_date["wday"] + 1
   local sunday_days_indices = {}
   --
   local hours_in_days = 24
   local seconds_in_hour = 3600
   local seconds_in_day = hours_in_days * seconds_in_hour
   local date = nil
   local sunday_wday = 1
   for i = 1, self.n_of_divisions do
      date = os.time( self.shifted_displayed_start_date ) + (i-1) * seconds_in_day
      if os.date( "*t", date )["wday"] == sunday_wday then
	 table.insert( sunday_days_indices, i )
      end
   end   
   local sundays_x = {}
   for _, s in ipairs( sunday_days_indices ) do
      local x = self.button.position.x + s * self.day_width + self.days_lines_shift
      if x <= self.button.position.x + self.button.width then
	 table.insert( sundays_x, x )
      end
   end
   self.weeks_lines = sundays_x
   -- todo: do not create new table each update cycle
end

function Timeline:compute_months_labels_and_lines()
   local hours_in_days = 24
   local seconds_in_hour = 3600
   local seconds_in_day = hours_in_days * seconds_in_hour
   local date1 = nil
   local date2 = nil
   local end_month_day = {}
   for i = 1, self.n_of_divisions do
      date1 = os.time( self.shifted_displayed_start_date ) + (i-1) * seconds_in_day
      date2 = os.time( self.shifted_displayed_start_date ) + (i  ) * seconds_in_day
      if os.date( "*t", date1 )["month"] ~= os.date( "*t", date2 )["month"] then
	 table.insert( end_month_day, i )
      end
   end   
   local end_month_day_x = {}
   for _, d in ipairs( end_month_day ) do
      local x = self.button.position.x + d * self.day_width + self.days_lines_shift
      if x <= self.button.position.x + self.button.width then
	 table.insert( end_month_day_x, x )
      end
   end
   self.months_lines = end_month_day_x
   -- labels and positions
   local month_labels = {}
   local label_shift = 3   
   table.insert(
      month_labels,
      { month = month_num_to_abbr[ self.shifted_displayed_start_date["month"] ],
	x = self.button.position.x + label_shift } )
   for i = 1, self.n_of_divisions do
      date1 = os.time( self.shifted_displayed_start_date ) + (i-1) * seconds_in_day
      date2 = os.time( self.shifted_displayed_start_date ) + (i  ) * seconds_in_day
      if os.date( "*t", date1 )["month"] ~= os.date( "*t", date2 )["month"] then
	 local x = self.button.position.x + i * self.day_width +
	    self.days_lines_shift + label_shift
	 local abr = month_num_to_abbr[ os.date( "*t", date2 )["month"] ]
	 if x <= self.button.position.x + self.button.width - self.day_width then
	    table.insert( month_labels, { month = abr, x = x } )
	 end
      end
   end
   self.month_labels_and_pos = month_labels
end


function Timeline:determine_separating_lines()
   local separating_lines = {}
   for k, v in ipairs( self.weeks_lines ) do
      table.insert( separating_lines, { line_width = 1.5, x = v } )
   end
   for k, v in ipairs( self.months_lines ) do
      table.insert( separating_lines, { line_width = 2.5, x = v } )
   end
   return separating_lines
end


local function determine_sundays()
   -- todo
   return {4, 11, 18, 25 }
end



function Timeline:compute_x_and_width_for_dates( proj_start_date, proj_end_date )
   local start_pos = self.button.position.x +
      ( proj_start_date - self.start_day ) * self.day_width
   local end_pos = self.button.position.x +
      ( proj_end_date + 1 - self.start_day ) * self.day_width   
   local width = end_pos - start_pos
   return start_pos, width
end




function Timeline:draw()
   self.button:draw()
   self:draw_dates()
   self:draw_months_labels()
end

function Timeline:draw_dates()
   local days_x_start_pos = {}
   --
   -- local days_labels = {}
   -- for i = self.shifted_start_day, self.shifted_end_day do
   --    table.insert( days_labels, i )
   -- end
   --local days_labels = self.days_labels   
   local days_labels = {}
   local hours_in_days = 24
   local seconds_in_hour = 3600
   local seconds_in_day = hours_in_days * seconds_in_hour
   local days_shift_in_seconds = self.days_shift * hours_in_days * seconds_in_hour
   local date = nil
   local day_label = nil
   for i = 1, self.n_of_divisions do
      date = os.time( self.shifted_displayed_start_date ) + (i-1) * seconds_in_day
      day_label = os.date( "*t", date )["day"]
      table.insert( days_labels, day_label )
   end
   --
   for i = 1, self.n_of_divisions do
      local x = self.button.position.x + (i - 1) * self.day_width
      x = x + self.days_lines_shift
      table.insert( days_x_start_pos, x )
   end
   local y1 = self.button.position.y
   local y2 = self.button.position.y + self.button.height
   local middle_y = ( y1 + y2 ) / 2
   local x_text_shift = 3
   love.graphics.setScissor( self.button.position.x,
   			     self.button.position.y,
   			     self.button.width,
   			     self.button.height )
   for d, x in ipairs( days_x_start_pos ) do
      love.graphics.line( x, middle_y, x, y2 )
      love.graphics.print( days_labels[d], x + x_text_shift, middle_y )
   end
   love.graphics.setScissor()
end


function Timeline:draw_months_labels()
   local y1 = self.button.position.y
   local y2 = self.button.position.y + self.button.height
   local middle_y = ( y1 + y2 ) / 2
   for _, l in pairs( self.month_labels_and_pos ) do
      love.graphics.print( l["month"], l["x"], y1 )
   end
end


function Timeline:mousereleased( x, y, button )
   return self.cursor_hovering 
end



return Timeline
