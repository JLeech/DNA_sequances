#simple_shift не хочет работать для input2, исправлю.
#пояснения в низу файла

require "./limits" #библиотечка разбора входных значени. должна находиться в той же директории, или указать путь.
require "./subsequence" #библиотечка подпоследовательностей. Для алгоритма константных подпоследовательностей

class Diffseeker

    attr_accessor :seq1
    attr_accessor :seq2
    attr_accessor :limits

    def initialize(sequences_file, parameter_file) # инициализация искателя различий
        get_sec(sequences_file)
        @limits = Limits.new(parameter_file)
    end

    def get_sec(file) # получение последовательностей из файла. Не поддерживаюстся многострочные, но это легко сделать
        sequences = []
        raw_lines = IO.readlines(file)
        for i in 0..raw_lines.length-1
            if raw_lines[i].start_with?(">seq")
                sequences << raw_lines[i+1]
            end
        end
        @seq1 = sequences[0].strip
        @seq2 = sequences[1].strip
    end

    def get_diffs(up_sec, down_sec) # алгоритм расчёта штрафов в последовательностях
        penalty = 0
        for index in 0..up_sec.length-1
            if down_sec[index] && (down_sec[index] != ' ')
                penalty += limits.penalty[ up_sec[index] ][ down_sec[index] ].to_i
            else
                penalty += limits.gap
            end
        end
        return penalty
    end

    def gap_only_full_check_algo # Полный перебор. НИКОГДА НЕ ЗАПУСКАТЬ СЛОЖНОСТЬ ~ O(C_(s2.l ^ 2) ^ s2.l) * O(get_diff)
        max_points = - 999
        places = ""
        for index in 0..seq2.length-1
            seq2.length.times do 
                places.concat("#{index}")
            end
        end
        possibilities = places.split(//).combination( seq2.length ).to_a
        possibilities.each do |positions|
            tmp_seq2 = @seq2
            positions.each do |pos|
                tmp_seq2.insert(pos, ' ')
            end
            cur_points = get_diffs(seq1,tmp_seq2)
            max_points = cur_points if cur_points >> max_points
        end
        return max_points
    end

    def update_move_position(index_up,index_down,seq2,current_up,current_down) # обновление текущей позиции в предсказывающем сдвиге
        seq2.insert(index_down,' ')
        index_down +=1
        index_up +=1
        current_up = seq1[index_up]
        current_down = seq2[index_down]
        return [index_up,index_down,seq2,current_up,current_down]
    end

    def move_score(seq1,seq2,index_up,index_down) #расчёт очков за два предсказывающих сдвига
        score = 0
        
        index_up,index_down,seq2,current_up,current_down = update_move_position(index_up,index_down,seq2,current_up,current_down)
        if current_up == current_down

        else
            index_up,index_down,seq2,current_up,current_down = update_move_position(index_up,index_down,seq2,current_up,current_down)
        end
        score = get_diffs(seq1,seq2)

        return {:seq1 => seq1,:seq2 => seq2,:index_up => index_up,:index_down => index_down,:score => score}
    end

    def simple_shift #алгоритм простого сдвига
        tmp_seq1 = @seq1
        tmp_seq2 = @seq2
        best_match = {}
        best_score = 0
        index_up = 0
        index_down = 0
        score = 0
        while index_up <= @seq1.length-1 do
            current_up = tmp_seq1[index_up]
            current_down = tmp_seq2[index_down]
            if current_down == current_up
                score += limits.penalty[current_up][current_down].to_i
                index_up +=1
                index_down +=1
            else
                move_results = move_score(tmp_seq1,tmp_seq2,index_up,index_down)
                puts move_results
                if move_results[:score] >= best_score
                    tmp_seq1 = move_results[:seq1] 
                    tmp_seq2 = move_results[:seq2]
                    index_up = move_results[:index_up]
                    index_down = move_results[:index_down]
                    best_score = move_results[:score]
                    
                    index_up += 1
                    index_down += 1
                    
                    best_match["seq1"] = tmp_seq1
                    best_match["seq2"] = tmp_seq2
                else
                    index_up += 1
                    index_down += 1
                end

            end 
        end
        puts "score #{best_score}"
        puts best_match["seq1"]
        puts best_match["seq2"]
    end

    def get_max_constant_sequences 
        
    end

    def mod(number) #просто модуль
        if number >=0 
            return number
        else
            return -number
        end
    end

    def get_sub_words (sequence) 
      accumulator = []
      (0..sequence.length).inject([]){|out_var,out_iter|
        (1..sequence.length - out_iter).inject(out_var){|in_var,in_iter|
          in_var << sequence[out_iter,in_iter]
          accumulator << Subsequence.new(sequence,out_iter,in_iter)
        }
      }.uniq
      return accumulator
    end

end


seeker = Diffseeker.new("input1.txt","parameter1.txt") # указываются файлы в текущей директории или просто пути

seeker.simple_shift
#