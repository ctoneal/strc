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

	# Add a member to a set
	def sadd(key, *args)
		if args.length < 1
			raise STRC::Exception.new "Wrong number of arguments (1 for 2)"
		end
		if @dict.has_key?(key)
			if @dict[key].class == Array
				@dict[key] << args
			else
				raise STRC::Exception.new "ERR Operation against a key holding the wrong kind of value"
			end
		else
			@dict[key] = args
		end
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

	# Determine if the given value is a member of the set at key
	def sismember(key, member)
		if @dict.has_key?(key)
			if @dict[key].class == Array
				return true unless @dict[key].index(member).nil?
			else
				raise STRC::Exception .new "ERR Operation against a key holding the wrong kind of value"
			end
		end
		return false
	end

	# Returns an array of members of the set
	def smembers(key)
		if @dict.has_key?(key)
			if @dict[key].class == Array
				return @dict[key]
			else
				raise STRC::Exception .new "ERR Operation against a key holding the wrong kind of value"
			end
		else
			return []
		end
	end

	# Gets the length of a set
	def scard(key)
		if @dict.has_key?(key)
			if @dict[key].class == Array
				@dict[key].length
			else
				raise STRC::Exception.new "ERR Operation against a key holding the wrong kind of value"
			end
		else
			return 0
		end
	end
end