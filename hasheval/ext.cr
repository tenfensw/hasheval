# string extensions that are just rly vital

class String
	def starts_and_ends_with?(beginning, ending)
		# convenience wrapper
		return self.starts_with?(beginning) && self.ends_with?(ending)
	end

	def starts_and_ends_with?(both)
		# also a convenience wrapper
		return self.starts_and_ends_with?(both, both)
	end

	def either_is?(one : String, two : String)
		# convenience wrapper for lowercase comparison with
		# two other strings
		return (self.downcase == one.downcase || self.downcase == two.downcase)
	end

	def is_int32?
		return (self.to_i32? != nil)
	end

	def is_float64?
		return (self.to_f64? != nil)
	end

	def remove_whitespaces
		# removes all tabs and whitespaces
		inside_quotes = false
		result = Array(Char).new

		self.each_char do |character|
			if !character.whitespace? || inside_quotes
				result.push(character)

				if character == '"'
					inside_quotes = !inside_quotes
				end
			end
		end

		return result.join
	end

	def remove_quotes
		# removes all double-quotes substring
		inside_quotes = false
		result = Array(Char).new

		self.each_char do |character|
			if character == '"'
				inside_quotes = !inside_quotes
			elsif !inside_quotes
				result.push(character)
			end
		end

		return result.join
	end

	def split_respecting_quotes(delimiter : Char) : Array(String)
		# proper split (respecting double-quoted strings as well
		# as the '\\' escape character)

		result = Array(String).new
		line = Array(Char).new

		inside_quotes = false
		inside_escape = false

		self.each_char do |character|
			line.push(character)

			if inside_escape
				inside_escape = false
			elsif character == '"'
				inside_quotes = !inside_quotes
			elsif character == '\\'
				line.pop
				inside_escape = true
			elsif character == delimiter && !inside_quotes
				line.pop

				if line.size >= 1
					result.push(line.join) # no empty strings
				end
				line = Array(Char).new
			end
					
		end

		if line.size >= 1
			result.push(line.join)
		end

		return result
	end
end
