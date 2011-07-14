require 'helper'

class TestStrc < Test::Unit::TestCase
	def setup
		@test = STRC.new
	end
	context "initialization" do 
		should "create a new instance" do
			assert_instance_of(STRC, @test)
		end
	end

	context "setting" do
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

	context "getting" do
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

	context "sets" do
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
	end
end
