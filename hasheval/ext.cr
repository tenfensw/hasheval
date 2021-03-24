# string extensions that are just rly vital
require "big"

class String
	# convenience wrapper around calling `starts_with?` and
	# `ends_with?` for the specified operands
	def starts_and_ends_with?(beginning, ending)
		# convenience wrapper
		return self.starts_with?(beginning) && self.ends_with?(ending)
	end

	# convenience wrapper, but in case when the string starts
	# and ends with the same operands
	def starts_and_ends_with?(both)
		# also a convenience wrapper
		return self.starts_and_ends_with?(both, both)
	end

	# convenience wrapper for lowercase comparison with two 
	# other strings
	def either_is?(one : String, two : String)
		return (self.downcase == one.downcase || self.downcase == two.downcase)
	end

	# validates if the string is a number that can be `Int32`
	# or not
	def is_int32?
		return (self.to_i32? != nil)
	end

	# validates if the string is a number that can be `BigFloat`
	# or not
	def is_big_f?
		begin
			self.to_big_f
			return true
		rescue
			return false
		end
	end

	# removes all tabs and whitespaces from string excluding
	# the ones in the double-quotes substrings
	def remove_whitespaces
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

	
	# removes all double-quotes substrings
	def remove_quotes
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

	# proper split (respecting double-quoted substrings as well
	# as the '\\' escape character)
	def split_respecting_quotes(delimiter : Char) : Array(String)
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

	# replace single-quoted substrings with double-quoted
	# ones
	def replace_single_with_double
		inside_single = false
		inside_quotes = false
		inside_escape = false
		result = Array(Char).new

		self.each_char do |character|
			if inside_single
				if character == '"'
					result.push('\\') # escape needed when converting
				end

				result.push(character)

				if character == '\''
					# stop single quoting
					result.pop
					result.push('"')

					inside_single = false
				end
			elsif inside_quotes
				# things are fine here
				if character == '"'
					inside_quotes = false
				else
					result.push(character)
				end
			elsif character == '\'' && !inside_escape
				inside_single = true # inside single quotes now
			elsif character == '"' && !inside_escape
				inside_quotes = true # inside double quotes now
			else
				result.push(character)
			end

			if inside_escape && character != '\\'
				inside_escape = false
			end
		end

		return result.join
	end

	# undouble-quoted string
	def to_unquoted_s
		return self.gsub("\\\"", "<ESCAPED_Q>").gsub("\"", "").gsub("<ESCAPED_Q>", "\"")
	end
end
