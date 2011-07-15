require 'helper'

class TestSets < Test::Unit::TestCase
	def setup
		@test = STRC.new
	end
	context "sadd" do
		should "create a new set" do
			result = @test.sadd("test_key", "poop")
			assert_equal(1, result)
		end

		should "be able to add multiple items" do
			result = @test.sadd("test_key", "poop", "abc")
			assert_equal(2, result)
		end

		should "be able to add to an existing set" do
			@test.sadd("test_key", "poop")
			result = @test.sadd("test_key", "blah")
			assert_equal(1, result)
		end

		should "not be able to add to something not a set" do
			@test.set("test_key", "blah")
			assert_raise(STRC::Exception) { @test.sadd("test_key", "poop") }
		end
	end

	context "sismember" do
		should "return true if the set contains the object" do
			@test.sadd("test_key", "poop", "blah", "abc")
			result = @test.sismember("test_key", "poop")
			assert(result)
		end

		should "return false if the set does not contain the object" do
			@test.sadd("test_key", "poop", "blah", "abc")
			result = @test.sismember("test_key", "xyz")
			assert(!result)
		end
	end

	context "scard" do
		should "return the number of items in the set" do
			@test.sadd("test_key", "poop", "blah", "abc")
			result = @test.scard("test_key")
			assert_equal(3, result)
		end

		should "return 0 for nonexistant keys" do
			result = @test.scard("blahblahblah")
			assert_equal(0, result)
		end
	end

	context "srem" do
		should "remove an item from the set" do
			@test.sadd("test_key", "poop", "blah", "abc")
			result = @test.srem("test_key", "poop")
			assert(result)
			assert_equal(2, @test.scard("test_key"))
		end

		should "not remove if the member isn't in the set" do
			@test.sadd("test_key", "poop", "blah", "abc")
			result = @test.srem("test_key", "xyz")
			assert(!result)
			assert_equal(3, @test.scard("test_key"))
		end
	end

	context "smembers" do
		should "return an array of items" do
			@test.sadd("test_key", "poop", "blah", "abc")
			result = @test.smembers("test_key")
			assert_equal(["poop", "blah", "abc"], result)
		end

		should "return an empty array for nonexistant keys" do
			result = @test.smembers("aaaaaa")
			assert_equal([], result)
		end
	end

	context "sinter" do
		should "return the intersection of two sets" do
			@test.sadd("set1", "poop", "abc", "xyz")
			@test.sadd("set2", "123", "456", "poop", "xyz")
			result = @test.sinter("set1", "set2")
			assert_equal(["poop", "xyz"], result)
		end

		should "be the same as smembers if passed one set" do
			@test.sadd("set1", "poop", "abc", "xyz")
			result = @test.sinter("set1")
			assert_equal(["poop", "abc", "xyz"], result)
		end
	end

	context "sinterstore" do
		should "work like sinter, but store in destination" do
			@test.sadd("set1", "poop", "abc", "xyz")
			@test.sadd("set2", "123", "456", "poop", "xyz")
			@test.sinterstore("new", "set1", "set2")
			result = @test.smembers("new")
			assert_equal(["poop", "xyz"], result)
		end
	end

	context "sdiff" do
		should "return items that are only in the first set" do
			@test.sadd("set1", "a", "b", "c", "d")
			@test.sadd("set2", "c")
			@test.sadd("set3", "a", "c", "e")
			result = @test.sdiff("set1", "set2", "set3")
			assert_equal(["b", "d"], result)
		end
	end

	context "sdiffstore" do
		should "work like sdiff, but store in destination" do
			@test.sadd("set1", "a", "b", "c", "d")
			@test.sadd("set2", "c")
			@test.sadd("set3", "a", "c", "e")
			@test.sdiffstore("new", "set1", "set2", "set3")
			result = @test.smembers("new")
			assert_equal(["b", "d"], result)
		end
	end

	context "sunion" do
		should "give all unique members of given sets" do
			@test.sadd("set1", "a", "b", "c", "d")
			@test.sadd("set2", "c")
			@test.sadd("set3", "a", "c", "e")
			result = @test.sunion("set1", "set2", "set3")
			assert_equal(["a", "b", "c", "d", "e"], result)
		end
	end

	context "sunionstore" do
		should "work like sunion, but store in destination" do
			@test.sadd("set1", "a", "b", "c", "d")
			@test.sadd("set2", "c")
			@test.sadd("set3", "a", "c", "e")
			@test.sunionstore("new", "set1", "set2", "set3")
			result = @test.smembers("new")
			assert_equal(["a", "b", "c", "d", "e"], result)
		end
	end

	context "smove" do
		should "move an item from one set to another" do
			@test.sadd("set1", "one" ,"two")
			@test.sadd("set2", "three")
			result = @test.smove("set1", "set2", "two")
			assert(result)
			members = @test.smembers("set1")
			assert_equal(["one"], members)
			members = @test.smembers("set2")
			assert_equal(["three", "two"], members)
		end
	end

	context "srandmember" do
		should "return a random member of a set" do
			@test.sadd("set1", "a", "b", "c", "d")
			result = @test.sismember("set1", @test.srandmember("set1"))
			assert(result)
		end

		should "return nil when key doesn't exist" do
			result = @test.srandmember("poop")
			assert_nil(result)
		end
	end

	context "spop" do
		should "return a random element from a set" do
			items = ["a", "b", "c", "d"]
			@test.sadd("set1", *items)
			result = @test.spop("set1")
			assert_not_nil(items.index(result))
		end

		should "remove the returned element from the set" do
			items = ["a", "b", "c", "d"]
			@test.sadd("set1", *items)
			result = @test.spop("set1")
			assert_equal(items.sort, (@test.smembers("set1") << result).sort)
		end
	end
end