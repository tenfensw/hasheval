require "./guesser.cr"

module HashEval
	def self.eval_native(chopped : String) : Hash(String, Bool | Float64 | Int32 | String | Nil)
		result = Hash(String, Bool | Float64 | Int32 | String | Nil).new

		# get all pairs raw
		pairs_raw = chopped.remove_whitespaces.split_respecting_quotes(',')

		# now process the pairs
		pairs_raw.each do |pair|
			keyv, valuev = extract_pair_values(pair, "=>")
			result.put(keyv.to_s, valuev) {}
		end
		
		return result
	end

	def self.eval(raw : String)
		# eval function
		raw_chopped = raw.chomp.strip

		# first guess the type
		type = guess_type(raw_chopped)

		case type
		when Type::Native
			return self.eval_native(raw_chopped[1...-1])
		else
			raise ParsingException.new("TODO")
		end
	end
end

