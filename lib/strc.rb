class STRC
	Exception = Class.new(StandardError)

	def initialize
		@dict = {}
	end

	# Set a given key to a value
	def set(key, value)
		@dict[key] = value
		return "OK"
	end

	# Get the value for the given key
	def get(key)
		@dict[key]
	end

	# Delete a key
	def del(*keys)
		keys.each do |key|
			@dict.delete(key)
		end
		return keys.length
	end

	# Returns if key exists
	def exists(key)
		@dict.has_key?(key)
	end

	# Returns a random key
	def randomkey
		@dict.keys.sample
	end

	# Renames a key.  Overwrites destination.
	def rename(key, newkey)
		if key == newkey
			raise STRC::Exception.new "ERR Source and destination objects are the same"
		end
		@dict[newkey] = @dict[key]
		del(key)
		return "OK"
	end

	# Renames a key.  Does not overwrite destination.
	def renamenx(key, newkey)
		if exists(newkey)
			return false
		else
			rename(key, newkey)
			return true
		end
	end

	# Set functions!

	# Add a member to a set
	def sadd(key, *args)
		if args.length < 1
			raise STRC::Exception.new "Wrong number of arguments (1 for 2)"
		end
		set = smembers(key)
		@dict[key] = set + args
		return args.length
	end

	# Remove a member from a set
	def srem(key, member)
		if sismember(key, member)
			@dict[key].delete_at(@dict[key].index(member))
			return true
		else
			return false
		end
	end

	# Returns a list of m
	def sinter(*keys)
		sets = []
		keys.each do |key|
			sets << smembers(key)
		end
		inter = sets.shift
		sets.each do |set|
			inter &= set
		end
		return inter
	end

	# Similar to SINTER, but stores in destination instead of returning
	def sinterstore(destination, *keys)
		elements = sinter(*keys)
		sadd(destination, *elements)
	end

	# Returns a list of the difference between the first set
	# and subsequent sets
	def sdiff(*keys)
		sets = []
		keys.each do |key|
			sets << smembers(key)
		end
		diff = sets.shift
		sets.each do |set|
			diff -= set
		end
		return diff
	end

	# Similar to SDIFF, but stores in destination instead of returning
	def sdiffstore(destination, *keys)
		elements = sdiff(*keys)
		sadd(destination, *elements)
	end

	# Move an item from one set to another
	def smove(source, destination, member)
		if !sismember(source, member)
			return false
		end
		srem(source, member)
		unless sismember(destination, member)
			sadd(destination, member)
		end
		return true
	end

	# Returs a list of all unique items in the given sets
	def sunion(*keys)
	end

	# Similar to SUNION, but stores in destination instead of returning
	def sunionstore(destination, *keys)
		elements = sunion(*keys)
		sadd(destination, *elements)
	end

	# Returns a random element from the set
	def srandmember(key)
		smembers(key).sample
	end

	# Randomly remove and return an item from the set
	def spop(key)
		element = srandmember(key)
		srem(key, element)
		return element
	end

	# Determine if the given value is a member of the set at key
	def sismember(key, member)
		set = smembers(key)
		return !set.index(member).nil?
	end

	# Returns an array of members of the set
	def smembers(key)
		if exists(key)
			value = get(key)
			if value.class == Array
				return value
			else
				raise STRC::Exception .new "ERR Operation against a key holding the wrong kind of value"
			end
		else
			return []
		end
	end

	# Gets the length of a set
	def scard(key)
		set = smembers(key)
		return set.length
	end
end