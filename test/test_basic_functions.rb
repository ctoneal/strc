require 'helper'

class TestBasicFunctions < Test::Unit::TestCase
	def setup
		@test = STRC.new
	end

	context "set" do
		should "be able to set the value of a new key" do
			result = @test.set("test_key", 20)
			assert_equal("OK", result)
		end

		should "be able to set the value of an existing key" do
			@test.set("test_key", 20)
			result = @test.set("test_key", 30)
			assert_equal("OK", result)
		end

		should "be able to set different types as values" do
			result = @test.set("test_key", "poop")
			assert_equal("OK", result)
		end

		should "be able to set different types as keys" do
			result = @test.set(15, "abcde")
			assert_equal("OK", result)
		end
	end

	context "setnx" do
		should "be able to set the value of a new key" do
			result = @test.setnx("test", 10)
			assert(result)
		end

		should "not set value if the key already exists" do
			@test.setnx("test", 10)
			result = @test.setnx("test", 50)
			assert(!result)
			value = @test.get("test")
			assert_equal(10, value)
		end
	end

	context "get" do
		should "be able to get the value of a key" do
			@test.set("test_key", 15)
			result = @test.get("test_key")
			assert_equal(15, result)
		end

		should "return nil for nonexistant keys" do
			result = @test.get("blah")
			assert_nil(result)
		end
	end

	context "append" do
		should "append to a string" do
			@test.set("test", "Hello")
			@test.append("test", " World")
			value = @test.get("test")
			assert_equal("Hello World", value)
		end

		should "return the new length of the string" do
			@test.set("test", "Hello")
			result = @test.append("test", " World")
			assert_equal("Hello World".length, result)
		end

		should "set if key doesn't exist" do
			@test.append("test", "poop")
			result = @test.get("test")
			assert_equal("poop", result)
		end

		should "not work for non string values" do
			@test.set("test", 15)
			assert_raise(STRC::Exception) { @test.append("test", "poop")}
		end
	end

	context "incr" do
		should "increment integers" do
			@test.set("poop", 10)
			@test.incr("poop")
			assert_equal(11, @test.get("poop"))
		end

		should "not increment other types" do
			@test.set("poop", "aaa")
			assert_raise(STRC::Exception) { @test.incr("poop")}
		end

		should "return new value" do
			@test.set("poop", 10)
			result = @test.incr("poop")
			assert_equal(11, result)
		end
	end

	context "incrby" do
		should "be able to increment by value" do
			@test.set("poop", 10)
			@test.incrby("poop", 10)
			assert_equal(20, @test.get("poop"))
		end
	end

	context "decr" do
		should "decrement integers" do
			@test.set("poop", 10)
			@test.decr("poop")
			assert_equal(9, @test.get("poop"))
		end

		should "not decrement other types" do
			@test.set("poop", "aaa")
			assert_raise(STRC::Exception) { @test.decr("poop")}
		end
	
		should "return new value" do
			@test.set("poop", 10)
			result = @test.decr("poop")
			assert_equal(9, result)
		end
	end

	context "decrby" do
		should "be able to decrement by value" do
			@test.set("poop", 10)
			@test.decrby("poop", 10)
			assert_equal(0, @test.get("poop"))
		end
	end
end