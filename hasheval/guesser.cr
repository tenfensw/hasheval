# type guessing and conversion lies here

require "./ext.cr"

module HashEval
	class ParsingException < Exception
		# custom exception
	end

	enum Type
		# autodetected hash types
		Native
		JSONy
		HamlAttributes
	end

	enum OType
		# subvariable type
		SymbolString
		RegularString
		FloatingPoint
		Integer
		TrueFalse
		VariableReference
		NilReference
	end

	def self.evaluate_supported_type(original : String) : Tuple(String | Float64 | Int32 | Bool | Nil, OType)
		# string to type
		
		if original.size < 1 || original.downcase == "nil" || original.downcase == "null"
			# this is de facto nil
			return {nil, OType::NilReference}
		end

		if original.starts_and_ends_with?('"')
			# a string, obv
			return {original[1...-1].gsub("\\\"", "\""), OType::RegularString}
		elsif original.starts_with?(':')
			# obv, a symbol
			return {original[1...], OType::SymbolString}
		elsif original.downcase.either_is?("true", "false")
			# boolean
			return {original.downcase == "true", OType::TrueFalse}
		elsif original.is_int32?
			return {original.to_i32, OType::Integer}
		elsif original.is_float64?
			return {original.to_f64, OType::FloatingPoint}
		else
			return {original, OType::VariableReference}
		end
	end

	private def self.extract_pair_values(pair : String, seperator : String = "=>")
		if pair.size < 1 || !pair.remove_quotes.includes?(seperator)
			raise ParsingException.new("Empty unprocessable key-value pair \"#{pair}\" (maybe you're having two commas in a row somewhere in your hash?)")
		end
		
		key_end_index = pair.index(seperator) || 0
		key_evaluated, key_evaluated_type = evaluate_supported_type(pair[0...key_end_index])

		# in case it's a JSON pair and the first argument is an
		# unresolved symbol
		if key_evaluated_type == OType::VariableReference
			if seperator == ":"
				key_evaluated_type = OType::SymbolString
			else
				raise ParsingException.new("Since hash evaluation in Crystal is essentially simulated, you cannot evaluate variables or constants, unfortunately (sorry, btw, that's the culprit - #{key_evaluated})")
			end
		elsif ![OType::SymbolString, OType::RegularString].includes?(key_evaluated_type)
			raise ParsingException.new("Only strings and symbols are supported as hash keys at the moment (surround #{key_evaluated} into double-quotes or convert it into a symbol maybe?)")
		end

		# now evaluate the value
		value_start_index = key_end_index + seperator.size
		value_evaluated, value_evaluated_type = evaluate_supported_type(pair[value_start_index...])

		if value_evaluated_type == OType::VariableReference
			raise ParsingException.new("Since hash evaluation in Crystal is essentially simulated, you cannot evaluate variables or constants, unfortunately (sorry, btw, that's the culprit - #{key_evaluated})")
		end

		return {key_evaluated, value_evaluated}
	end

	private def self.guess_type(prepr : String) : Type
		if prepr.starts_and_ends_with?('{', '}')
			return (prepr.remove_quotes.includes?("=>") ? Type::Native : Type::JSONy)
		elsif prepr.starts_and_ends_with?('(', ')')
			return Type::HamlAttributes
		end

		raise ParsingException.new("Cannot detect hash type for hash #{prepr}")
	end
end
