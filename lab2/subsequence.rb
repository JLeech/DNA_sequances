class Subsequence
    attr_accessor :parent_sequence
    attr_accessor :start
    attr_accessor :end
    attr_accessor :sub_sequence

    def initialize(parent_sequence,start,stop) #положение подстроки в строке, родительская строка, подстрока
        @start = start
        @stop = stop
        @parent_sequence = parent_sequence
        sub_sequence = parent_sequence[start,stop]
    end
end