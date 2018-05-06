local Project = {}
Project.__index = Project

function Project:new( o )
   o = o or {}
   setmetatable( o, self )
   o.name = o.name
   o.start_date = o.start_date
   o.end_date = o.end_date
   o.subprojects = o.subprojects or {}   
   o.description = o.description or "go to hell"
   o.tags = o.tags or {}
   return o
end

function Project:add_subproject( sub )
   table.insert( self.subprojects, sub )
end

function Project:start_date_as_text()
   return self.start_date["day"] .. "." ..
      self.start_date["month"]  .. "." ..
      self.start_date["year"]
end

function Project:end_date_as_text()
   return self.end_date["day"] .. "." ..
      self.end_date["month"]  .. "." ..
      self.end_date["year"]
end

return Project
