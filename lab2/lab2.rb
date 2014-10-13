
require "./limits" #библиотечка разбора входных значени. должна находиться в той же директории, или указать путь.
require "matrix" # системная библиотека для матриц

class Diffseeker # собственно содержит последовательности и таблицу штрафов за гепы и прочее

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

seeker = Diffseeker.new("input2.txt","parameter2.txt") # инициализация

class Matrix
    def []=(i,j,k)
        @rows[i][j]=k
    end # добавление метода записи в матрицы, а то они по дефолту immutable
end

class VunshPH # считает по методу Нидлмана-Вунша

    attr_accessor :seeker
    attr_accessor :matrix
    attr_accessor :result

    # инициализация сразу запускает расчёт
    def initialize(seeker)
        @seeker = seeker
        @matrix = Matrix.zero(@seeker.seq1.length+1,@seeker.seq2.length+1) 
        start_gap_fill
        count_matrix
        back_way
    end

    #заполняется первая строка и столбец
    def start_gap_fill
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

    # обратный ход
    def back_way 
        #номера текущих позиций в строках
        seq1_iter = @matrix.row_count-2
        seq2_iter = @matrix.column_count-2

        # номера текущей позиции в матрице
        mat_row = @matrix.row_count-1
        mat_col = @matrix.column_count-1

        dir = 0

        #результирующие строки
        res_seq1 = ""
        res_seq2 = ""

        loop do
            
            break if ((mat_row <= 0)&& (mat_col <= 0))

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
        @result = {"res1" => res_seq1.reverse, "res2" => res_seq2.reverse}
    end

end

vunshpunsh = VunshPH.new(seeker)
puts "res1 : #{vunshpunsh.result["res1"]}"
puts "res2 : #{vunshpunsh.result["res2"]}"

#честно - немного странный результат для второго параметра.
#проверил алгоритм - вроде нигде не напутал, но смущает, что направления не храню, может в этом всё дело.  
#но если хранить направления - тогда не полуается множественности путей.
#с ограниченным количеством геп - пока никаких стоящих идей в голову не пришло, кроме совсем простых - подсчётов при вставке,
#ограничения матрицы с боков. 
