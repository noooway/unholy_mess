return {
   projects = {
      { name = "Take a week off: Octopus's Garden",
	start_date = 1, --"1.2.3",
	end_date = 19, --"2.2.3",
	subprojects = {
	   { name = "Arrange a place",
	     start_date = 1, -- "1.2.3",
	     end_date = 5, --"2.2.3",
	     subprojects = {},
	     description = "Call uncle Willy, the Octopus. " ..
		"Last time I saw him he told about a nice place with a garden nearby."
	   },
	   { name = "Find a way to get there",
	     start_date = 7, --"1.2.3",
	     end_date = 12, --"2.2.3",
	     subprojects = {},
	     description = "A submarine would be nice. A yellow one."
	   },
	   { name = "Ask friends to visit",
	     start_date = 13, --"1.2.3",
	     end_date = 18, --"2.2.3",
	     subprojects = {},
	     description = "We could finally get all together. That would be great."
	   },	   
	   { name = "Go sightseeing",
	     start_date = 15, --"1.2.3",
	     end_date = 18, --"2.2.3",
	     subprojects = {},
	     description = "We could swim around a coral nearby."
	   },	   
	},
	description = "Spent a couple of weeks in some calm and quiet place. " ..
	"No one around telling what to do."
      },
      { name = "Get back home",
	start_date = 20, --"3.2.3",
	end_date = 28, --"4.2.3",
	subprojects = {
	   { name = "Get to Miami",
	     start_date = 21, --"1.2.3",
	     end_date = 23, --"2.2.3",
	     subprojects = {},
	     description = "Booked a flight from here"
	   },
	},
	description = "Gee, it would be good to be there"
      }
   },
   description = "go to hell",
   creation_date = "01.03.2018"
}
