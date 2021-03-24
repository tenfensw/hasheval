# basically some useful extensions to make HashEval seamlessly
# usable
require "./eval.cr"

class Hash
	# autodetects the specified stringified hash type and evaluates 
        # it into a `ResultingHash`
        #
        # throws `ParsingException` in case of a syntax or any other
        # internal error
	def self.from_s(raw : String)
		return HashEval.eval(raw)
	end

	# same as `from_s`
	def self.from_string(raw : String)
		return HashEval.eval(raw)
	end

	# stringify hash contents in Haml HTML hash syntax form
	def to_haml_attributes
		output = "("

		self.each do |kv, vv|
			if !vv.responds_to?(:to_s) || !kv.responds_to?(:to_s)
				raise "#{kv} and #{vv} should both be convertable to String (respond to .to_s method) for this to work"
			end

			output += [kv.to_s, '"' + vv.gsub("\"", "\\\"") + '"'].join('=') + ' '
		end

		output = output.strip + ')'
		return output
	end
end

class String
	# same as `Hash#from_s`
	def to_hash
		return Hash.from_s(self)
	end
end
