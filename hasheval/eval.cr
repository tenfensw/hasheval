require "./guesser.cr"

module HashEval
	# evaluate the specified hash string assuming it has Ruby 1.9
	# simplified hash syntax or the ordinary one
	private def self.eval_native(chopped : String, delimeter : String = "=>") : Hash(String, Bool | BigFloat | Int32 | String | Nil)
		result = Hash(String, Bool | BigFloat | Int32 | String | Nil).new

		# get all pairs raw
		pairs_raw = chopped.remove_whitespaces.split_respecting_quotes(',')

		# now process the pairs
		pairs_raw.each do |pair|
			keyv, valuev = extract_pair_values(pair, delimeter)
			result.put(keyv.to_s, valuev) {}
		end
		
		return result
	end

	# autodetects the specified stringified hash type and evaluates 
	# it into a `Hash(String, Bool | BigFloat | Int32 | String | Nil)`
	#
	# throws `ParsingException` in case of a syntax or any other
	# internal error
	def self.eval(raw : String)
		# eval function
		raw_chopped = raw.chomp.strip

		# first guess the type
		type = guess_type(raw_chopped)

		case type
		when Type::Native
			return eval_native(raw_chopped[1...-1])
		when Type::JSONy
			return eval_native(raw_chopped[1...-1], ":")
		when Type::HamlAttributes
			return eval_haml_attributes(raw_chopped[1...-1])
		end

		# never reaches there, but is needed to calm Crystal 1.0
		# compiler down
		return Hash(String, Bool | BigFloat | Int32 | String | Nil).new
	end
end

