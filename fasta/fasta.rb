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
	
	def initialize(limits,data)
		@limits = limits
		@data = data
	end

	

end




limits = Limits.new("./penalty_matrix")
data = Subsequances.new("./ADH_DB.txt")
puts data.sequances.count
puts data.sequances.first.triples
