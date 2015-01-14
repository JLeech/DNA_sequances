
require "./limits" #библиотечка разбора входных значени. должна находиться в той же директории, или указать путь.
require "matrix" # системная библиотека для матриц

class Diffseeker # собственно содержит последовательности и таблицу штрафов за гепы и прочее

    attr_accessor :seq1
    attr_accessor :seq2
    attr_accessor :limits

    def initialize(seq1,seq2, limits) # инициализация искателя различий
        @seq1 = seq1
        @seq2 = seq2
        @limits = limits
    end

end

class Matrix
    def []=(i,j,k)
        @rows[i][j]=k
    end # добавление метода записи в матрицы, а то они по дефолту immutable
end

class Vunsh # считает по методу Нидлмана-Вунша

    attr_accessor :seeker
    attr_accessor :matrix_vunsh
    attr_accessor :left_line
    attr_accessor :right_line
    attr_accessor :score

    attr_accessor :result_vunsh


    def initialize(seeker)
        @seeker = seeker
        @matrix_vunsh = Matrix.zero(@seeker.seq1.length+1,@seeker.seq2.length+1) 
        @score = 0
    end

    def set_limits(left_line, right_line)
        @left_line = left_line
        @right_line = right_line
    end

    def count_limited_vunsh
        start_gap_fill_vunsh
        count_limited_matrix_vunsh
        limited_back_way_vunsh
    end


    #заполняется первая строка и столбец
    def start_gap_fill_vunsh
        for i in 0..(@matrix_vunsh.row_count-1)
            @matrix_vunsh[i,0] = i * @seeker.limits.gap
        end     

        for j in 0..(@matrix_vunsh.column_count-1)
            @matrix_vunsh[0,j] = j * @seeker.limits.gap
        end
    end

    #заполнение матрицы
    def count_limited_matrix_vunsh
        for i in 1..(@matrix_vunsh.row_count-1)
            for j in 1..(@matrix_vunsh.column_count-1)
                break if (@right_line["row"] - i == @right_line["column"] - j)
                max = get_limited_max(i,j)
                @matrix_vunsh[i,j] = max
            end

        end
    end

    def find_start_elem
        max_i =0
        max_j =0
        max = 0
        for i in 1..(@matrix_water.row_count-1)
            for j in 1..(@matrix_water.column_count-1)
                if(@matrix_water[i,j] > max)
                    max_i = i
                    max_j = j
                    max = @matrix_water[i,j]
                end
            end
        end
        return {"i" => max_i,"j" => max_j}
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
    def get_limited_max(i,j)
        diff = @seeker.limits.penalty[@seeker.seq1[i-1]][@seeker.seq2[j-1]].to_i    
        
        diag = @matrix_vunsh[i-1,j-1] + diff
        
        #отсекаем левую проверку если ячейка прямо за линией
        if (@left_line["row"] - i-1 == @left_line["column"] - j )
            left = diag
        else
            left = @matrix_vunsh[i-1,j] + diff
        end
        
        #отсекаем верхнюю проверку если ячейка прямо под линией
        if (@right_line["row"] - i == @right_line["column"] - j-1)
            up = diag 
        else
            up = @matrix_vunsh[i,j-1] + diff 
        end
        return [up,left,diag].max

    end 

    # обратный ход
    def limited_back_way_vunsh 
        #номера текущих позиций в строках
        
        seq1_iter = @matrix_vunsh.row_count-2
        seq2_iter = @matrix_vunsh.column_count-2

        # номера текущей позиции в матрице
        mat_row = @matrix_vunsh.row_count-1
        mat_col = @matrix_vunsh.column_count-1

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
                #условия для границ линий отсечения
                unless (@right_line["row"] - mat_row-1 == @right_line["column"] - mat_col)
                    up = @matrix_vunsh[mat_row-1,mat_col]
                end
            end
            if mat_col > 0 
                unless (@left_line["row"] - mat_row == @left_line["column"] - mat_col-1 )
                    side = @matrix_vunsh[mat_row,mat_col-1]
                end
            end
            if ((mat_col > 0)&&(mat_row > 0))
                diag = @matrix_vunsh[mat_row-1,mat_col-1]
            end

            tmp = []
            
            tmp << up if (!up.nil?)
            tmp << side if (!side.nil?)
            tmp << diag if (!diag.nil?)

            max = tmp.max
            @score += max
            #определение направления
            dir = 1 if up == max
            dir = -1 if side == max
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

        @result_vunsh = {"res1" => res_seq1.reverse, "res2" => res_seq2.reverse}
    end
end