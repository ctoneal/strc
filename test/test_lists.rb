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
end