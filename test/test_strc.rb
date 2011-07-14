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
end
