describe HashEval do
	it "works with regular hashes that are String<=>String" do
		ihash = {"name" => "Tim", "surname" => "K"}
		HashEval.eval(ihash.to_s).must_equal(ihash)
	end

	it "converts the hashes with Symbol keys appropriately" do
		ihash = { :name => "Tim", :surname => "K", :os => "macOS" }
		HashEval.eval(ihash.to_s)["os"].must_equal(ihash[:os])
	end
end
