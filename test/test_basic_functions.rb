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

	context "exists" do
		should "return true if the key exists" do
			@test.set("test", 1)
			assert(@test.exists("test"))
		end

		should "return false if the key doesn't exist" do
			assert(!@test.exists("test"))
		end
	end

	context "del" do
		should "delete a key" do
			@test.set("test", 1)
			deleted = @test.del("test")
			assert_equal(1, deleted)
			assert(!@test.exists("test"))
		end

		should "delete multiple keys" do
			@test.set("test", 1)
			@test.set("poop", 2)
			@test.set("blah", 4)
			deleted = @test.del("test", "poop")
			assert_equal(2, deleted)
			assert(!@test.exists("test"))
			assert(!@test.exists("poop"))
			assert(@test.exists("blah"))
		end
	end

	context "randomkey" do
		should "return a random key from the database" do
			keys = ["test", "poop", "blah"]
			keys.each do |key|
				@test.set(key, 1)
			end
			random = @test.randomkey
			assert_not_nil(keys.index(random))
		end
	end

	context "rename" do
		should "rename a key" do
			@test.set("poop", 1)
			@test.rename("poop", "abc")
			value = @test.get("abc")
			assert_equal(1, value)
		end

		should "overwrite existing keys" do
			@test.set("poop", 1)
			@test.set("abc", 2)
			@test.rename("poop", "abc")
			value = @test.get("abc")
			assert_equal(1, value)
		end
	end

	context "renamenx" do
		should "rename a key" do
			@test.set("poop", 1)
			@test.renamenx("poop", "abc")
			value = @test.get("abc")
			assert_equal(1, value)
		end

		should "not overwrite existing keys" do
			@test.set("poop", 1)
			@test.set("abc", 2)
			@test.renamenx("poop", "abc")
			value = @test.get("abc")
			assert_equal(2, value)
		end
	end
end