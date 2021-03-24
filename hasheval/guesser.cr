# type guessing and conversion lies here (it's mostly private)
require "./ext.cr"

module HashEval
	# custom exception that is thrown by all HashEval
	# methods in case a syntax error is caught
	class ParsingException < Exception
	end

	# autodetected hash types (internal)
	private enum Type
		Native
		JSONy
		HamlAttributes
	end

	# subvariable type (internal)
	private enum OType
		SymbolString
		RegularString
		FloatingPoint
		Integer
		TrueFalse
		VariableReference
		NilReference
	end

	# evaluates the specified string into a built-in Crystal type
	private def self.evaluate_supported_type(original : String) : Tuple(String | BigFloat | Int32 | Bool | Nil, OType)		
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
		elsif original.is_big_f?
			return {original.to_big_f, OType::FloatingPoint}
		else
			return {original, OType::VariableReference}
		end
	end

	# preprocesses the key-value pair accordingly
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

	# guess the hash type
	private def self.guess_type(prepr : String) : Type
		if prepr.starts_and_ends_with?('{', '}')
			return (prepr.remove_quotes.includes?("=>") ? Type::Native : Type::JSONy)
		elsif prepr.starts_and_ends_with?('(', ')')
			return Type::HamlAttributes
		end

		raise ParsingException.new("Cannot detect hash type for hash #{prepr}")
	end
end
