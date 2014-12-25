class Sequance
	attr_accessor :name
	attr_accessor :data
	attr_accessor :triples

	def initialize(name)
		@name = name
		@triples = {}
	end

	def count_triples
		@data.split("").each_with_index do |start,iter| 
			break if iter >= (@data.length-2) 
				
			triple = "#{@data[iter]}#{@data[iter+1]}#{@data[iter+2]}"
			if triples[triple] == nil
				triples[triple] = data.enum_for(:scan, /#{triple}/).map { Regexp.last_match.begin(0) }
			end
		end
	end
end

class Subsequances

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
						seq.count_triples
						@sequances << seq
						accum = "" 
					end

					seq = Sequance.new(line)
				else
					accum += line.strip!
				end
			end
		end
	end

end	

