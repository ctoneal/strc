require 'helper'

class TestHashes < Test::Unit::TestCase
	def setup
		@test = STRC.new
		@test.hset("poop", "a", 1)
		@test.hset("poop", "qwe", "aaa")
	end

	context "hset" do
		should "create a new hash" do
			@test.hset("test", "a", 1)
			assert(@test.exists("test"))
			assert_equal(1, @test.hget("test", "a"))
		end

		should "add fields to existing hashes" do
			@test.hset("poop", "b", 2)
			assert_equal(2, @test.hget("poop", "b"))
		end

		should "set existing fields in hashes" do
			@test.hset("poop", "a", 15)
			assert_equal(15, @test.hget("poop", "a"))
		end
	end

	context "hsetnx" do
		should "set a field if it doesn't exist" do
			@test.hsetnx("poop", "b", 10)
			assert_equal(10, @test.hget("poop", "b"))
		end

		should "not set to a field if it exists" do
			@test.hsetnx("poop", "qwe", 100)
			assert_not_equal(100, @test.hget("poop", "qwe"))
		end
	end

	context "hget" do
		should "return value for field" do
			assert_equal(1, @test.hget("poop", "a"))
		end

		should "return nil for nonexistant fields" do
			assert_nil(@test.hget("poop", "b"))
		end
	end

	context "hdel" do
		should "delete fields" do
			@test.hdel("poop", "a")
			assert_nil(@test.hget("poop", "a"))
		end

		should "return number of deleted fields" do
			result = @test.hdel("poop", "a")
			assert_equal(1, result)
			result = @test.hdel("poop", "asdf")
			assert_equal(0, result)
		end
	end

	context "hexists" do
		should "return true if field exists" do
			assert(@test.hexists("poop", "a"))
		end

		should "return false if field doesn't exist" do
			assert(!@test.hexists("poop", "asdf"))
		end
	end

	context "hgetall" do
		should "return an array of keys and values" do
			assert_equal(["a", 1, "qwe", "aaa"], @test.hgetall("poop"))
		end
	end

	context "hkeys" do
		should "return an array of keys" do
			assert_equal(["a", "qwe"], @test.hkeys("poop"))
		end
	end

	context "hvals" do
		should "return an array of values" do
			assert_equal([1, "aaa"], @test.hvals("poop"))
		end
	end

	context "hlen" do
		should "give number of keys in hash" do
			assert_equal(2, @test.hlen("poop"))
		end
	end
end