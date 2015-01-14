class Sequance
	attr_accessor :name
	attr_accessor :data
	attr_accessor :triples

	def initialize(name)
		@name = name
		@triples = {}
	end

	def count_triples(triple_length)
		@data.split("").each_with_index do |start,iter|
			break if iter >= (@data.length-triple_length-1) 
			triple = @data[iter..(iter+triple_length-1)]
			if triples[triple] == nil
				triples[triple] = data.enum_for(:scan, /#{triple}/).map { Regexp.last_match.begin(0) }
			end
		end
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
		delete_unmatch_sequances
	end

	def delete_unmatch_sequances
		@sequances.each_with_index do |seq,index|
			@sequances.delete_at(index) if ((seq.triples.keys & main_sequance.triples.keys).empty?)
		end
	end

	def process_lines
		accum = ""
		seq = nil
		triple_length = 0
		properties_lines = IO.readlines("properties")		
		properties_lines.each { |line| triple_length = line.split(" ").last.to_i if line.start_with?("length of triples") }
		@raw_lines.each do |line|
			unless line.strip.empty?
				if line.start_with?(">")
					unless  seq.nil?
						seq.data = accum
						
						seq.count_triples(triple_length)
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

