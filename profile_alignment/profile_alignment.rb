require "./limits" 
require "./subsequances"
require "./vunsh"
require "matrix" 

class Matrix
    def []=(i,j,k)
        @rows[i][j]=k
    end # добавление метода записи в матрицы, а то они по дефолту immutable
end

class Profile
	attr_accessor :limits
	attr_accessor :data

	def initialize(limits_file,data_file)
		@limits = Limits.new(limits_file)
		@data = Subsequances.new(data_file)
	end

	def print
		puts data.sequances.count
		puts data.main_sequance.data
	end

	def print_probabilities
		@data.sequances.each do |seq|
			puts seq.probability
		end
	end

	def count_alignment
		@data.sequances.each do |seq|
			seq_to_check = Diffseeker.new(seq,@data.main_sequance,@limits)
			vunsh = Vunsh.new(seq_to_check)
			vunsh.count_vunsh
		end
	end

end


limit_file = "./penalty_matrix"
data_file = "./ADH_DB.txt"

prof = Profile.new(limit_file,data_file)
prof.count_alignment
#prof.print_probabilities