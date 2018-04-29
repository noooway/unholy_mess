local Journal = {}

Journal.__index = Journal

function Journal:new( o )
   o = o or {}
   setmetatable( o, self )
   o.projects = o.projects or {}
   o.description = o.description or "go to hell"
   o.creation_date = o.creation_date or "1.2.3"
   return o
end

function Journal:add_project( project )
   table.insert( self.projects, project )
end

function Journal:load_from_file( filename )
   journal_no_mt = require( filename )
   journal = Journal:new( journal_no_mt )
   return journal
end

return Journal
