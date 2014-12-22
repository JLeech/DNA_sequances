class Limits
    attr_accessor :gap
    attr_accessor :insert
    attr_accessor :delete
    attr_accessor :alphabet
    attr_accessor :penalty

    attr_accessor :raw_lines

    def initialize(file)
        @penalty = {}
        @gap = 0
        @insert = 0
        @delete = 0
        self.raw_lines = IO.readlines(file)
        get_gap_insert_delete
        get_alphabet
        get_penalties
    end

    private

    def get_gap_insert_delete # считывание очков за вставку/удаление
        idents = ["gap","delete","insert"]
        raw_lines.each { |line| idents.each { |id| self.send("#{id}=",line.to_i) if line.include?(id) } }
    end

    def get_alphabet #получение алфавита
        idents = ["Alphabet", "Alfabet"]
        raw_lines.each_with_index do |line, index|
            idents.each do |ident|
                if line.include?(ident) 
                   self.alphabet = raw_lines[index+1].split(" ") 
                   return
                end
            end
        end
    end

    def get_penalties #получение матрицы штрафов
        matrix_pos = 0
        idents = ["matrix"]
        raw_lines.each_with_index { |line, index| idents.each { |id| matrix_pos = index+1 if line.include?(id) } }
        @alphabet.each_with_index do |raw, iter|
            iter += matrix_pos
            tmp = Hash.new()
            raw_lines[iter].split(" ").each_with_index { |amount, index| tmp[@alphabet[index]] = amount } 
            @penalty[raw] = tmp
        end
    end
end
