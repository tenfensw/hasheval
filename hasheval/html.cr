# the Haml HTML attributes hash syntax parser
require "./ext.cr"

module HashEval
	private def self.eval_haml_attributes(chopped : String) : Hash(String, String)
		# this one is much simpler
		result = Hash(String, String).new

		# first, get all the pairs
		pairs_raw = chopped.replace_single_with_double.split_respecting_quotes(' ')

		pairs_raw.each do |pair_raw|
			pair = pair_raw.to_unquoted_s # no quotes at all
			pair_split = pair.split('=')

			keyv = pair_split.shift
			valuev = pair_split.join('=')

			if valuev.empty?
				# repeat the HTML key instead
				valuev = keyv
			end

			result.put(keyv, valuev) {}
		end

		return result
	end
end
