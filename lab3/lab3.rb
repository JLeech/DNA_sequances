require "./limits" 
require "matrix" 

class Matrix
    def []=(i,j,k)
        @rows[i][j]=k
    end # добавление метода записи в матрицы, а то они по дефолту immutable
end

class Diffseeker 

    attr_accessor :seq1
    attr_accessor :seq2
    attr_accessor :limits

    def initialize(sequences_file, parameter_file) # инициализация искателя различий
        @seq1 = ""
        @seq2 = ""
        get_sec(sequences_file)
        @limits = Limits.new(parameter_file)
    end

    def read_seq(raw_lines,index,seq)
        sequence = ""
        loop do 
            index +=1
            break if (index >= raw_lines.length) || (raw_lines[index].include?(">")) 
            sequence += raw_lines[index].gsub(" ","").strip!
        end
        self.send("#{seq}=",sequence)
        return index-=1
    end

    def get_sec(file) 
        sequences = []
        raw_lines = IO.readlines(file)
        index = 0
        loop do
            if raw_lines[index].include?(">")
                if @seq1.empty?
                    index = read_seq(raw_lines,index,"seq1")
                elsif @seq2.empty?
                    index = read_seq(raw_lines,index,"seq2")
                end
            end
            index +=1
            break if index >= raw_lines.length
        end
    end
end

class VunshPH # считает по методу оптимальной памяти

    attr_accessor :seeker
    attr_accessor :matrix
    attr_accessor :result

    # инициализация сразу запускает расчёт
    def initialize(seeker)
        @seeker = seeker
        @matrix = Matrix.zero(@seeker.seq1.length+1,@seeker.seq2.length+1)
        @result = {}
        start_gap_fill
        count_matrix
        count_mem(0,0,@matrix.row_count-1,@matrix.column_count-1)
    end

    def count_mem(top_row,top_column,down_row,down_column)
    	if top_row == down_row
            return
        end
        if ( @result.include?(top_row) && (down_row == top_row +1) ) 
            top_row = down_row
        end

        row_pos = ((down_row + top_row) / 2.0 ).floor
        if @result.keys.include?(row_pos)

        else
            count_matrix_row(row_pos,down_column)
            @result[row_pos],column = get_max_on_row(@matrix.row(row_pos).to_a)
            #puts @result
            count_mem(top_row,top_column,row_pos,column)
            count_mem(row_pos,column,down_row,down_column)
        end
    end

    def count_matrix_row(row_pos,down_column)

        fir_row = []
        sec_row = [0]
        for i in 0..down_column
            fir_row.push(i * @seeker.limits.gap)
        end
        for col in 1..row_pos
            diff = @seeker.limits.penalty[@seeker.seq1[0]][@seeker.seq2[col]].to_i
            up = fir_row[col] + diff
            left = sec_row[col-1] + diff
            diag = fir_row[col-1] + diff
            sec_row.push([up,left,diag].max) 
        end
        puts "fr: #{fir_row}"
        puts "sc: #{sec_row}"
    end

    def get_max_on_row(row)
        max= row[0]
        place = 0
        for i in 0..row.size-1
            max = row[i] if row[i] > max
            place = i
        end
        return [max,place]
    end



    #заполняется первая строка и столбец
    def start_gap_fill()
        for i in 0..(@matrix.row_count-1)
            @matrix[i,0] = i * @seeker.limits.gap
        end     

        for j in 0..(@matrix.column_count-1)
            @matrix[0,j] = j * @seeker.limits.gap
        end
    end

    # метод для относительно красивой печати матрицы
    def print_matrix(mat)
        for i in 0..(mat.row_count-1)
            for j in 0..(mat.column_count-1)
                printf " #{mat[i,j]}"
            end
            puts
        end
    end 

    # получение наилучшего пути из трёх(вверх, вправо, диагональ)
    def get_max(i,j)
        diff = @seeker.limits.penalty[@seeker.seq1[i-1]][@seeker.seq2[j-1]].to_i    
        up = @matrix[i,j-1] + diff
        left = @matrix[i-1,j] + diff
        diag = @matrix[i-1,j-1] + diff
        return [up,left,diag].max
    end 

    #заполнение матрицы
    def count_matrix
        for i in 1..(@matrix.row_count-1)
            for j in 1..(@matrix.column_count-1)
                max = get_max(i,j)
                @matrix[i,j] = max
            end
        end
    end 

end

seeker = Diffseeker.new("input2.txt","parameter2.txt") 
vunsh = VunshPH.new(seeker)
vunsh.print_matrix(vunsh.matrix)

