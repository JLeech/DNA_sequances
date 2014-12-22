require "./limits" 
require "matrix" 

class Sector

    attr_accessor :column
    attr_accessor :max

    def initialize(max, column)
        @max = max
        @column = column
    end
end    

class Matrix
    def []=(i,j,k)
        @rows[i][j]=k
    end # добавление метода записи в матрицы, а то они по дефолту immutable
end

class Diffseeker 

    attr_accessor :seq1
    attr_accessor :seq2
    attr_accessor :limits

    def initialize(sequences_file, parameter_file) # инициализация
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
        #@matrix = Matrix.zero(+1,@seeker.seq2.length+1)
        @result = {}
        count_mem(0,0,@seeker.seq1.length,@seeker.seq2.length)
        back_way
    end

    #основной метод по которому идёт цикл
    def count_mem(top_row,top_column,down_row,down_column)
        if top_row == down_row
            return
        end
        #избавление от краевых результатов
        if ( @result.include?(top_row) && (down_row == top_row +1) ) 
            top_row = down_row
        end
        # округление до ближайших целых при делении, на определение номера строки
        row_pos = ((down_row + top_row) / 2.0 ).floor
        if @result.keys.include?(row_pos)

        else
            # собственно построение строк матрицы и опрпделение максимальных элементов
            counted_row = count_matrix_row(row_pos,down_column)
            #puts "lf: #{counted_row}"
            @result[row_pos],column = get_max_on_limited_row(counted_row,top_column,down_column)
            #puts "max: #{@result[row_pos].max}"
            # тут рекурсивно вызываются методы для верхней и нижней половины матрицы.
            # границы, очевидно, разные
            count_mem(top_row,top_column,row_pos,column)
            count_mem(row_pos,column,down_row,down_column)
        end
    end

    # в этом методе происходит построение строки.
    # как видно, в цикле в памяти всегда 2 строки, причём необходимой конечной длины

    def count_matrix_row(row_pos,down_column)
        fir_row = []
        sec_row = []
        for i in 0..down_column
            fir_row.push(i * @seeker.limits.gap)
        end

        if row_pos == 0
        else
            for row in 1..row_pos
                sec_row = [row * @seeker.limits.gap]
                for position in 1..down_column
                    diff = @seeker.limits.penalty[@seeker.seq1[row-1]][@seeker.seq2[position-1]].to_i
                    up = fir_row[position] + diff
                    left = sec_row[position-1] + diff
                    diag = fir_row[position-1] + diff
                    sec_row.push([up,left,diag].max)
                end
                fir_row = sec_row
            end 
        end
        return fir_row
    end

    #просто получение максимального элемента из определённого ренджа строки
    def get_max_on_limited_row(row,left_limit,right_limit)
        max = row[0]
        place = 0
        
        
        if left_limit == right_limit
            sector = Sector.new(row[right_limit],right_limit)
            return [sector,right_limit]
        end
        for i in left_limit..right_limit
            if row[i] > max
                max = row[i] 
                place = i 
            end
        end
        
        sector = Sector.new(max,place)

        return [sector,place]
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


      def construct_result_seq
        #номера текущих позиций в строках
        seq1_iter = @seeker.seq1.length - 1
        seq2_iter = @seeker.seq2.length - 1

        dir = 0

        #результирующие строки
        res_seq1 = ""
        res_seq2 = ""

        rang = @seeker.seq1.length..1

        (rang.first).downto(rang.last).each do |i|


        end
=begin
        for i in 0..

            up = nil
            side = nil
            diag =  nil

            # условия для границ матрицы
            if mat_row > 0 
                up = @matrix[mat_row-1,mat_col]
            end
            if mat_col > 0 
                side = @matrix[mat_row,mat_col-1]
            end
            if ((mat_col > 0)&&(mat_row > 0))
                diag = @matrix[mat_row-1,mat_col-1]
            end

            tmp = []
            
            tmp << up if (!up.nil?)
            tmp << side if (!side.nil?)
            tmp << diag if (!diag.nil?)

            max = tmp.max
            #определение направления
            dir = -1 if side == max
            dir = 1 if up == max
            dir = 0 if diag == max

            # действия при перемещении
            if dir == 0
                mat_col -=1
                mat_row -=1

                res_seq1 << @seeker.seq1[seq1_iter]
                res_seq2 << @seeker.seq2[seq2_iter]
                seq1_iter -=1
                seq2_iter -=1

            end
            if dir == -1
                mat_col -=1
                
                res_seq1 << "_"
                res_seq2 << @seeker.seq2[seq2_iter]

                seq2_iter -=1
            end
            if dir == 1

                res_seq2 << "_"
                res_seq1 << @seeker.seq1[seq1_iter]            

                seq1_iter -=1
                mat_row -=1
            end

        end
=end        
        @result = {"res1" => res_seq1.reverse, "res2" => res_seq2.reverse}
    end

end

seeker = Diffseeker.new("input2.txt","parameter2.txt") 
vunsh = VunshPH.new(seeker)
#vunsh.print_matrix(vunsh.matrix)

