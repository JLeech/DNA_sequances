require "./limits" 
require "./subsequances"
require "./limited_vunsh"
require "matrix" 

class Matrix
    def []=(i,j,k)
        @rows[i][j]=k
    end # добавление метода записи в матрицы, а то они по дефолту immutable
end

class Fasta

	attr_accessor :limits
	attr_accessor :data
	attr_accessor :match_line_length
	attr_accessor :low_limit_score

	def initialize(limits_file,data_file)
		@limits = Limits.new(limits_file)
		@data = Subsequances.new(data_file)
		read_match_line_length
	end

	#чтение данных о минимальной длинне совпадающих символов из файла
	def read_match_line_length
		properties_lines = IO.readlines("properties")
		properties_lines.each { |line| @match_line_length = line.split(" ").last.to_i if line.start_with?("length of lines") }
		properties_lines.each { |line| @low_limit_score = line.split(" ").last.to_i if line.start_with?("low limit score") }
	end


	# основной метод
	def cut_no_points
		puts @data.sequances.length
		@data.sequances.each_with_index do |seq, index|
			diags_positions = []
			limit_lines = []
			# поиск диагоналей необходимой длинны
			for iter in 0..(seq.data.length-1-@match_line_length)
				diags_for_row = find_diags(seq.data,iter,@data.main_sequance.data)
				diags_positions += (diags_for_row) unless diags_for_row.empty?
			end
			#поиск правой и левой линии границы
			limit_lines = find_limit_lines(diags_positions,seq.data.length,@data.main_sequance.data.length)
			#puts limit_lines
			seq_to_check = Diffseeker.new(seq.data,@data.main_sequance.data,@limits)
			limited_vunsh = Vunsh.new(seq_to_check)
			limited_vunsh.set_limits(limit_lines.first,limit_lines.last)
			limited_vunsh.count_limited_vunsh
			if limited_vunsh.score > @low_limit_score
				vunsh = Vunsh.new(seq_to_check)
				vunsh.count_vunsh
				puts "passed: #{vunsh.score}"
			end
		end
	end


	#нахождение правой и левой границ области построения
	def find_limit_lines(positions,height,width)
		row = "row"
		column = "column"
		left_line = {row => positions.first[row], column => positions.first[column]}
		right_line = {row => positions.first[row], column => positions.first[column]}

		#можно раскомментировать чтобы посмотреть нагляжно на позиции совпадений
		#комментариии ниже так же нужно расскоментировать
=begin
		matr = Matrix.zero(height+1,width+1)
		positions.each do |pos|
			matr[pos[row],pos[column]] = 1
		end
=end

		left_line_length = get_line_length(left_line,height,width)
		right_line_length = get_line_length(right_line,height,width)
		positions.each do |position|
			# поиск правой
			if ((position[row] <= right_line[row]) || (position[column] >= right_line[column]))
				line_length = get_line_length(position,height,width)
				if right_line_length > line_length
					right_line_length = line_length
					right_line = position
				end
			end
			#поиск левой
			if ((position[row] >= left_line[row]) || (position[column] <= left_line[column]))
				line_length = get_line_length(position,height,width)
				if left_line_length > line_length
					left_line_length = line_length
					left_line = position
				end
			end

		end
=begin
		matr[right_line[row],right_line[column]] = 3
		matr[left_line[row],left_line[column]] = 3
		for i in 0..matr.row_count-1
			for j in 0..matr.column_count-1
				if ((right_line[row] - i == right_line[column] - j) || (left_line[row] - i == left_line[column] - j) )
					matr[i,j] = 7
				end
			end
		end
		print_matrix(matr)
=end

		return [left_line,right_line]
	end

	#получение длинны ограничительной линии
	def get_line_length(position,height,width)
		height_iter = position["row"]
		width_iter = position["column"]
		length = 1
		loop do
			height_iter += 1
			width_iter += 1
			break if ((height_iter >= height +1 ) || (width_iter >= width + 1))
			length += 1
		end

		height_iter = position["row"]
		width_iter = position["column"]

		loop do
			height_iter -= 1
			width_iter -= 1
			break if ((height_iter < 0 ) || (width_iter < 0))
			length += 1
		end

		return length

	end

	#поиск диагоналей требуемой длинны
	def find_diags(sequance,row,main)
		positions = []
		index = 0
		char_to_match = sequance[row]
		main.each_char do |char|
			positions.push(index) if char == char_to_match
			index += 1
		end

		matrix_positions = []
		positions.each_with_index do |column,index|
			delete_flag = delete_position?(row,column,sequance,main)
			if delete_flag
				positions.delete_at(index)
			else
				matrix_positions.push({"row" => row,"column" => column}) 
			end
		end
		return matrix_positions

		#puts "#{matrix_positions}"
		#left_right = {}
		#left_right = get_left_right_lines(positions)
		#puts ":#{positions}"
		
	end

	# удаление позиции, если диагональ, начинающаяся с неё меньше требуемой
	def delete_position?(row,column,sequance,main)
		subseq = sequance[row..row+match_line_length-1] 
		main_subseq = main[column..column+match_line_length-1]
		if ((subseq == main_subseq) && (main_subseq.length == match_line_length))
			return false
		end
		return true
	end

	def print
		puts data.sequances.count
		puts data.main_sequance.data
	end

	def print_matrix(mat)
        for i in 0..(mat.row_count-1)
            for j in 0..(mat.column_count-1)
                printf " #{mat[i,j]}"
            end
            puts
        end
    end 


end

limit_file = "./penalty_matrix"
data_file = "./ADH_DB.txt"

fasta = Fasta.new(limit_file,data_file)
fasta.cut_no_points


