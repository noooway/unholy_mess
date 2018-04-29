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

return Project
