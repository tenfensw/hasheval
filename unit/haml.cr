describe HashEval do
	it "evaluates Haml HTML attribute syntaxed hashes into something acceptable" do
		ivalue = ["programming", "furry_fandom"].join(' ')
		input = "(name=Tim surname='K' interests=\"#{ivalue}\")"

		HashEval.eval(input)["interests"].must_equal(ivalue)
	end
end
