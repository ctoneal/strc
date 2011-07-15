require 'set'

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

	# Set the value of a key only if it doesn't already exist.
	def setnx(key, value)
		unless exists(key)
			set(key, value)
			return true
		end
		return false
	end

	# Get the value for the given key
	def get(key)
		@dict[key]
	end

	# Append a value to a key
	def append(key, value)
		if exists(key)
			item = get(key)
			if item.class == String and value.class == String
				set(key, item + value)
			else
				raise STRC::Exception.new "ERR Operation against a key holding the wrong kind of value"
			end
		else
			set(key, value)
		end
		return get(key).length
	end

	# Decrement an integer
	def decr(key)
		decrby(key, 1)
	end

	# Decrement an integer by a certain amount
	def decrby(key, decrement)
		unless exists(key)
			set(key, 0)
		end
		value = get(key)
		if value.class == Fixnum
			set(key, value - decrement)
		else
			raise STRC::Exception.new "ERR Operation against a key holding the wrong kind of value"
		end
		get(key)
	end

	# Increment an integer
	def incr(key)
		incrby(key, 1)
	end

	# Increment an integer by a certain amount
	def incrby(key, increment)
		unless exists(key)
			set(key, 0)
		end
		value = get(key)
		if value.class == Fixnum
			set(key, value + increment)
		else
			raise STRC::Exception.new "ERR Operation against a key holding the wrong kind of value"
		end
		get(key)
	end

	# Key commands!

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

	# End of key commands~

	# Set commands!

	# Add a member to a set
	def sadd(key, *args)
		if args.length < 1
			raise STRC::Exception.new "Wrong number of arguments (1 for 2)"
		end
		set = get_s(key)
		added = 0
		args.each do |arg|
			unless set.include?(arg)
				set << arg
				added += 1
			end
		end
		@dict[key] = set
		return added
	end

	# Remove a member from a set
	def srem(key, member)
		if sismember(key, member)
			@dict[key].delete(member)
			return true
		else
			return false
		end
	end

	# Returns a list of m
	def sinter(*keys)
		sets = []
		keys.each do |key|
			sets << get_s(key)
		end
		inter = sets.shift
		sets.each do |set|
			inter &= set
		end
		return inter.to_a
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
			sets << get_s(key)
		end
		diff = sets.shift
		sets.each do |set|
			diff -= set
		end
		return diff.to_a
	end

	# Similar to SDIFF, but stores in destination instead of returning
	def sdiffstore(destination, *keys)
		elements = sdiff(*keys)
		sadd(destination, *elements)
	end

	# Move an item from one set to another
	def smove(source, destination, member)
		unless sismember(source, member)
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
		sets = []
		keys.each do |key|
			sets << get_s(key)
		end
		union = sets.shift
		sets.each do |set|
			union += set
		end
		return union.to_a
	end

	# Similar to SUNION, but stores in destination instead of returning
	def sunionstore(destination, *keys)
		elements = sunion(*keys)
		sadd(destination, *elements)
	end

	# Returns a random element from the set
	def srandmember(key)
		get_s(key).to_a.sample
	end

	# Randomly remove and return an item from the set
	def spop(key)
		element = srandmember(key)
		srem(key, element)
		return element
	end

	# Determine if the given value is a member of the set at key
	def sismember(key, member)
		set = get_s(key)
		return set.include?(member)
	end

	# Returns an array of members of the set
	def smembers(key)
		get_s(key).to_a
	end

	# Gets the length of a set
	def scard(key)
		set = get_s(key)
		return set.length
	end

	# Gets a set.  Private
	def get_s(key)
		set = Set.new
		if exists(key)
			set = get(key)
			unless set.class == Set
				raise STRC::Exception.new "ERR Operation against a key holding the wrong kind of value"
			end
		end
		return set
	end

	# End of set commands~

	# List commands!

	# Gets a list.  Private
	def get_l(key)
		list = []
		if exists(key)
			list = get(key)
			unless list.class == Array
				raise STRC::Exception.new "ERR Operation against a key holding the wrong kind of value"	
			end
		end
		return list
	end

	# Returns elements from key in the given range
	def lrange(key, start, stop)
		list = get_l(key)[start..stop]
		return list.nil? ? [] : list
	end

	# Returns length of list
	def llen(key)
		get_l(key).length
	end

	# Append values to a list
	def rpush(key, *values)
		list = get_l(key)
		list += values
		set(key, list)
		return list.length
	end

	# RPUSH if the list exists
	def rpushx(key, *values)
		if exists(key)
			rpush(key, *values)
		end
	end

	# Remove and get the last element in a list
	def rpop(key)
		list = get_l(key)
		element = list.pop
		set(key, list)
		return element
	end

	# Prepend values to a list
	def lpush(key, *values)
		list = get_l(key)
		list = values + list
		set(key, list)
		return list.length
	end

	# LPUSH if the list exists
	def lpushx(key, *values)
		if exists(key)
			lpush(key, *values)
		end
	end

	# Remove and get the first element in a list
	def lpop(key)
		list = get_l(key)
		element = list.shift
		set(key, list)
		return element
	end

	# Get an element from a list by its index
	def lindex(key, index)
		get_l(key)[index]
	end

	# Set value for an element at index in a list
	def lset(key, index, value)
		list = get_l(key)
		list[index] = value
		set(key, list)
	end

	# Trim a list to the specified range
	def ltrim(key, start, stop)
		set(key, lrange(key, start, stop))
	end

	# Removes an element from the end of one list and puts it at
	# the beginning of another
	def rpoplpush(source, destination)
		lpush(destination, rpop(source))
	end

	# End of list commands~

	# Hash commands!

	# Gets the hash at key.  Private.
	def get_h(key)
		hash = {}
		if exists(key)
			hash = get(key)
			unless hash.class == Hash
				raise STRC::Exception.new "ERR Operation against a key holding the wrong kind of value"	
			end
		end
		return hash
	end

	# Set file in hash stored at key to value.
	def hset(key, field, value)
		hash = get_h(key)
		hash[field] = value
		set(key, hash)
	end

	# Sets field in key only if it doesn't exist
	def hsetnx(key, field, value)
		unless hexists(key, field)
			hset(key, field, value)
			return true
		end
		return false
	end

	# Get value at field in hash at key
	def hget(key, field)
		get_h(key)[field]
	end

	# Deletes fields from hash
	def hdel(key, *fields)
		hash = get_h(key)
		deleted = 0
		fields.each do |field|
			unless hash.delete(field).nil?
				deleted += 1
			end
		end
		set(key, hash)
		return deleted
	end

	# Returns whether or not the field exists in key
	def hexists(key, field)
		get_h(key).has_key?(field)
	end

	# Returns an array of all fields and values in hash
	def hgetall(key)
		get_h(key).flatten
	end

	# Returns array of all keys in hash at key
	def hkeys(key)
		get_h(key).keys
	end

	# Returns array of all values in hash at key
	def hvals(key)
		get_h(key).values
	end

	# Returns number of fields in the hash
	def hlen(key)
		get_h(key).length
	end

	# End of hash commands~

	private :get_s, :get_l, :get_h
end