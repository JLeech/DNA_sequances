require "./limits" 
require "./subsequances"
require "matrix" 

class Matrix
    def []=(i,j,k)
        @rows[i][j]=k
    end # добавление метода записи в матрицы, а то они по дефолту immutable
end

class Fasta

	attr_accessor :limits
	attr_accessor :data
	attr_accessor :triples_number

	def initialize(limits_file,data_file)
		@limits = Limits.new(limits_file)
		@data = Subsequances.new(data_file)
		@triples_number = 5
	end

	def cut_no_points
		x = 0
		@data.sequances.each_with_index do |seq, index|
			counter = 0
			@data.main_sequance.triples.keys.each do |key|
				counter += seq.triples[key].count unless seq.triples[key].nil?
				#puts "x: #{seq.triples[key]}" unless seq.triples[key].nil?
			end

			if counter >= @triples_number
				
				puts counter
			end
		end
	end

	def print
		puts data.sequances.count
		puts data.main_sequance.data
	end


end

limit_file = "./penalty_matrix"
data_file = "./ADH_DB.txt"

fasta = Fasta.new(limit_file,data_file)
fasta.cut_no_points


