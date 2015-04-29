#to do 
#sort out commas in describe_location
# change "used condom" and other items to :symbols

################################################################
# Classs Lcation
################################################################
class Location

def initialize(id,description,to_the_north,to_the_south,to_the_west,to_the_east,special)
	@id = id
	@description = description
	@to_the_north = to_the_north
	@to_the_south = to_the_south 
	@to_the_west = to_the_west
	@to_the_east = to_the_east
	@special = special
end

def describe_location
	result = "You are #{@description}, " 
    result << "you can see " + @special + ",\n" if @special != "" && @special != "winner"
	result << "you can travel "
	result << "north, " if @to_the_north > 0
	result << "south, " if @to_the_south > 0
	result << "east, " if @to_the_east > 0
	result << "west" if @to_the_west > 0
	result <<"."
    #fix the commas in the list of directions
    return result
end

def next_place(string)
	result = 0
	result = @to_the_north if string == "n" && @to_the_north > 0
	result = @to_the_south if string == "s" && @to_the_south > 0
	result = @to_the_east if string == "e" && @to_the_east > 0
	result = @to_the_west if string == "w" && @to_the_west > 0

	#return the location to go next, returns 0 if its an invalid location
	return result
end

def winning_location?()
	result = false
	result = true if @special == "winner"
	# returns true if you are in a winning location
end

def whats_on_the_ground
	#returns the special item
	@special if @special != "winner"
end

def pick_up
	#removes the item from the location, so it is 'picked up'
	@special = ""
end

end #location


################################################################
# Class Map
################################################################
class Map

def initialize(mapfile)

	result =[]

	txt = open(mapfile)

	# works with up to 99 locations, otherwise can't pick up the special items
	txt.each_line do |line| 
		linearray = line.split(',')
		n = 0
		s = 0
		w = 0
		e = 0
		special = ""
		(2..6).each {|i| 
			if linearray[i] != nil 
				n = linearray[i][1..-1].to_i if linearray[i][0] == "n"
				s = linearray[i][1..-1].to_i if linearray[i][0] == "s"
				w = linearray[i][1..-1].to_i if linearray[i][0] == "w"
				e = linearray[i][1..-1].to_i if linearray[i][0] == "e"
			end
		} #each
		
        special = linearray.last.chomp if linearray.last.chomp.length > 3
		

		location = Location.new(linearray[0],linearray[1],n,s,w,e,special)
		result << location

	end

	txt.close()

	#sets up a gamemap which is an array of locations
	@internalmap = result

end

def location(place)
	#returns the location (this is one item from the map array)
	@internalmap[place]
end

end #map


################################################################
# general function
################################################################

def help
	puts """
	Try and find your way out of Lewisham
	COMMANDS
	h = help
	n,s,w,e = travel in any direction
	p = pick up item
	i = view your inventory
	u = use item
	bye = exit game
	"""
end


################################################################
# Class Inventory
################################################################
class Inventory

	def initialize()
		@items =[]
	end

	def use_item
		if @items.count == 0
	        puts "You have empty pockets muppet, you have nothing to use"
	        $muppet_count +=1
   	    else
			i = 0
			formatted_list =""
			@items.each{|item| 
				i+=1 
			    formatted_list << "#{i}) #{item} \n"}
			puts "What would you like to use? \n#{formatted_list}"
			print "?"
		    input_string = $stdin.gets.chomp.downcase
		    num = input_string.to_i
		    if !num.between?(1,i) 
		    	puts "Stupid answer muppet"
		    	$muppet_count+= 1
		    else
  			    puts "Yuck dirty boy, at least you could have washed it first" if @items[num-1] == "a used condom"
  			    puts "What do you think this is dungeons and dragons, can't use a key just smash the glass to enter" if @items[num-1] == "a shinny key"
  			    puts "Woof woof, he is sure to help you find home" if @items[num-1] == "Gangzi"
  			    puts "Now you can go in disguise round the shopping centre" if @items[num-1] == "an old coat"
  			    puts "Sorry there is a rail replacement service today, that timetable is useless" if @items[num-1] == "a ripped timetable"
	    		@items.delete_at(num-1) #remove item from inventory
	    	end
		end #if
	end #use_item

	def display_inventory()
		if @items.count == 0
	        puts "You have empty pockets"
   	    else
		 	you_have = "You have :"
		 	@items.each{|item| you_have << item + ', '}
		 	you_have[-2] = "." #replace last comma with fullstop
		 	puts you_have
		end
	end

	def pick_up_item(gamemap,location)
		item = gamemap.location(location).whats_on_the_ground
	    if item != "" && item != "winner"
	    	puts "You picked up #{item}."
	    	@items << item
	    	gamemap.location(location).pick_up
	    else
	  		puts "Nothing to pick up you muppet!"
	  		$muppet_count += 1
	    end
	end

end #inventory

################################################################
# main flow
################################################################

#load map
mapfile = ARGV.first
gamemap = Map.new(mapfile)

Start_location = 1 # constant starts with capital letter

#set defaults
location = Start_location # start at location 1
input_string = ""
inventorylist =Inventory.new()
$muppet_count = 0  #global varible starts with $

while input_string != "bye" do

	puts gamemap.location(location).describe_location

	if gamemap.location(location).winning_location?
		puts "You found your way home and won the game, Lewisham is better than you think eh?" 
		input_string = "bye"
	elsif $muppet_count > 10
		puts "You a massive muppet and have lost, you'll never make it to Greenwich"
		input_string = "bye"
	else
	  print "?"
	  input_string = $stdin.gets.chomp.downcase
    end

	#deal with input
	case input_string
	when "h"
		help
	when "p"
		inventorylist.pick_up_item(gamemap,location)
	when "i"
		inventorylist.display_inventory()
	when "u"
		inventorylist.use_item()
	when "q"
		input_string = "bye"
	when "n", "s", "e", "w"
	    #move
		validatelocation = gamemap.location(location).next_place(input_string)
		if validatelocation == 0
			puts"You can't move there you muppet!"
			$muppet_count +=1
		else
			location = validatelocation
		end
	end #case
	
	
	
	
end #while


