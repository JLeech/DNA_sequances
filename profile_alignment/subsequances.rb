class Sequance
	attr_accessor :name
	attr_accessor :data
	attr_accessor :probability

	def initialize(name)
		@name = name
	end


	def count_probability
		prob = {}
		data.each_char do |char|
			if prob[char].nil?
				prob[char] = 1.0
			else
				prob[char] += 1.0
			end
		end
		prob.each_key do |key|
			prob[key] = prob[key]/data.length
		end
		@probability = prob
	end
end

class Subsequances

	attr_accessor :main_sequance
	attr_accessor :sequances
	attr_accessor :raw_lines

	def initialize(file)
		@raw_lines = IO.readlines(file)
		@sequances = []
		process_lines
	end

	def process_lines
		accum = ""
		seq = nil
		@raw_lines.each do |line|
			unless line.strip.empty?
				if line.start_with?(">")
					unless  seq.nil?
						seq.data = accum
						seq.count_probability
						@sequances << seq
						accum = "" 
					end
					seq = Sequance.new(line)
				else
					accum += line.strip!
				end
			end
		end
		@main_sequance = @sequances.first
		@sequances.delete_at(0)
	end

end	

