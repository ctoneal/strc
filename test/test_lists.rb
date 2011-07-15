require 'helper'

class TestLists < Test::Unit::TestCase
	def setup
		@test = STRC.new
		@test.rpush("poop", "a", "b", "c")
	end

	context "lrange" do
		should "return a range of elements" do
			result = @test.lrange("poop", 1, 2)
			assert_equal(["b", "c"], result)
		end

		should "be zero based" do
			result = @test.lrange("poop", 0, 0)
			assert_equal(["a"], result)
		end

		should "work with negative numbers" do
			result = @test.lrange("poop", -3, 2)
			assert_equal(["a", "b", "c"], result)
		end

		should "indexing out should give an empty list" do
			result = @test.lrange("poop", 5, 10)
			assert_equal([], result)
		end
	end

	context "llen" do
		should "return length of the list" do
			result = @test.llen("poop")
			assert_equal(3, result)
		end
	end

	context "rpush" do
		should "create a new list" do
			@test.rpush("asdf", "abc")
			assert(@test.exists("asdf"))
			assert_equal(["abc"], @test.lrange("asdf", 0, -1))
		end

		should "push onto the end of existing lists" do
			@test.rpush("poop", "d", "e")
			assert_equal(["a", "b", "c", "d", "e"], @test.lrange("poop", 0, -1))
		end

		should "return new length of list" do
			len = @test.rpush("poop", "d", "e")
			assert_equal(@test.lrange("poop", 0, -1).length, len)
		end
	end

	context "rpushx" do
		should "not be able to create a new list" do
			@test.rpushx("asdf", "abc")
			assert(!@test.exists("asdf"))
		end
	end

	context "rpop" do
		should "return the last element in the list" do
			element = @test.rpop("poop")
			assert_equal("c", element)
		end

		should "remove the last element in the list" do
			@test.rpop("poop")
			assert_equal(["a", "b"], @test.lrange("poop", 0, -1))
		end
	end

	context "lpush" do
		should "create a new list" do
			@test.lpush("asdf", "abc")
			assert(@test.exists("asdf"))
			assert_equal(["abc"], @test.lrange("asdf", 0, -1))
		end

		should "push onto the beginning of existing lists" do
			@test.lpush("poop", "d", "e")
			assert_equal(["d", "e", "a", "b", "c"], @test.lrange("poop", 0, -1))
		end

		should "return new length of list" do
			len = @test.lpush("poop", "d", "e")
			assert_equal(@test.lrange("poop", 0, -1).length, len)
		end
	end

	context "lpushx" do
		should "not be able to create a new list" do
			@test.lpushx("asdf", "abc")
			assert(!@test.exists("asdf"))
		end
	end

	context "lpop" do
		should "return the first element in the list" do
			element = @test.lpop("poop")
			assert_equal("a", element)
		end

		should "remove the first element in the list" do
			@test.lpop("poop")
			assert_equal(["b", "c"], @test.lrange("poop", 0, -1))
		end
	end

	context "lindex" do
		should "return value at index" do
			result = @test.lindex("poop", 1)
			assert_equal("b", result)
		end

		should "work with negative numbers" do
			result = @test.lindex("poop", -2)
			assert_equal("b", result)
		end

		should "return nil for out of range" do
			result = @test.lindex("poop", 10)
			assert_nil(result)
		end
	end

	context "lset" do
		should "set value at index" do
			@test.lset("poop", 2, "test")
			assert_equal("test", @test.lindex("poop", 2))
		end
	end

	context "ltrim" do
		should "trim the list to the range" do
			@test.ltrim("poop", 1, -1)
			assert_equal(["b", "c"], @test.lrange("poop", 0, -1))
		end
	end

	context "rpoplpush" do
		should "take an element from the end of one list and put it on the front of another" do
			@test.lpush("asdf", "123")
			@test.rpoplpush("poop", "asdf")
			assert_equal(["a", "b"], @test.lrange("poop", 0, -1))
			assert_equal(["c", "123"], @test.lrange("asdf", 0, -1))
		end
	end
end