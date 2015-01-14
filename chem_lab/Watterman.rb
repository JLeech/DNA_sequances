
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

class VunshWater # считает по методу Нидлмана-Вунша и Смита-Ваттермана

    attr_accessor :seeker
    attr_accessor :matrix_vunsh
    attr_accessor :matrix_water
    
    attr_accessor :result_vunsh
    attr_accessor :result_water


    def initialize(seeker)
        @seeker = seeker
        @matrix_vunsh = Matrix.zero(@seeker.seq1.length+1,@seeker.seq2.length+1) 
        @matrix_water = Matrix.zero(@seeker.seq1.length+1,@seeker.seq2.length+1) 
    end

    def count_vunsh
        start_gap_fill_vunsh
        count_matrix_vunsh
        back_way_vunsh
    end

    def count_water 
        count_matrix_water
        print_matrix(@matrix_water)
        max_elems = find_start_elem
        back_way_water(max_elems)
    end

    def back_way_water(max_elems) 
        #номера позиций в строках(выводится только найденная максимальная последовательность)
        seq1_iter = max_elems["i"]-1
        seq2_iter = max_elems["j"]-1

        # номера текущей позиции в матрице
        mat_row = max_elems["i"]
        mat_col = max_elems["j"]

        dir = 0

        #результирующие строки
        res_seq1 = ""
        res_seq2 = ""

        loop do

            up = nil
            side = nil
            diag =  nil

            # условия для границ матрицы
            if mat_row > 0 
                up = @matrix_water[mat_row-1,mat_col]
            end
            if mat_col > 0 
                side = @matrix_water[mat_row,mat_col-1]
            end
            if ((mat_col > 0)&&(mat_row > 0))
                diag = @matrix_water[mat_row-1,mat_col-1]
            end

            tmp = []
            
            tmp << up if (!up.nil?)
            tmp << side if (!side.nil?)
            tmp << diag if (!diag.nil?)

            max = tmp.max

            #выход если максимальный элемент занулился
            break if (max == 0) 
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
        @result_water = {"res1" => res_seq1.reverse, "res2" => res_seq2.reverse}
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

    def count_matrix_water
        for i in 1..(@matrix_water.row_count-1)
            for j in 1..(@matrix_water.column_count-1)
                max = get_max(i,j,"water")
                @matrix_water[i,j] = max
            end
        end
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
    def get_max(i,j,method_id)
        diff = @seeker.limits.penalty[@seeker.seq1[i-1]][@seeker.seq2[j-1]].to_i    
        up = @matrix_vunsh[i,j-1] + diff
        left = @matrix_vunsh[i-1,j] + diff
        diag = @matrix_vunsh[i-1,j-1] + diff
        return [up,left,diag].max if method_id == "vunsh"
        return [up,left,diag,0].max if method_id == "water"

    end 

    #заполнение матрицы
    def count_matrix_vunsh
        for i in 1..(@matrix_vunsh.row_count-1)
            for j in 1..(@matrix_vunsh.column_count-1)
                max = get_max(i,j,"vunsh")
                @matrix_vunsh[i,j] = max
            end

        end
    end 

    # обратный ход
    def back_way_vunsh 
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
                up = @matrix_vunsh[mat_row-1,mat_col]
            end
            if mat_col > 0 
                side = @matrix_vunsh[mat_row,mat_col-1]
            end
            if ((mat_col > 0)&&(mat_row > 0))
                diag = @matrix_vunsh[mat_row-1,mat_col-1]
            end

            tmp = []
            
            tmp << up if (!up.nil?)
            tmp << side if (!side.nil?)
            tmp << diag if (!diag.nil?)

            max = tmp.max
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


vunshpunsh = VunshWater.new(seeker)
vunshpunsh.count_vunsh
vunshpunsh.count_water
puts "res1 : #{vunshpunsh.result_vunsh["res1"]}"
puts "res2 : #{vunshpunsh.result_vunsh["res2"]}"

puts "res1 : #{vunshpunsh.result_water["res1"]}"
puts "res2 : #{vunshpunsh.result_water["res2"]}"

# рассчёт проходит сразу для двух методов. результаты у консоль
# Смит - Ваттерман для одной максимальной локальной подпоследовательности
# пока что на Ruby;