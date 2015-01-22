class Limits
    attr_accessor :alphabet
    attr_accessor :penalty
    attr_accessor :gap

    attr_accessor :raw_lines

    def initialize(file)
        @penalty = {}
        self.raw_lines = IO.readlines(file)
        raw_lines.delete_if { |line| line.start_with?("#")}
        get_alphabet
        get_matrix
        get_gap
    end

    private

    def get_alphabet
        @alphabet = raw_lines.first.split(" ")
        raw_lines.delete_at(0)
    end

    def get_gap
        @gap = penalty["*"][alphabet.first].to_i
    end

    def get_matrix
        formatted_lines = []
        raw_lines.each do |line|
            splitted = line.split(" ")
            splitted.delete_at(0)
            formatted_lines << splitted.join(" ")
        end
        @alphabet.each_with_index do |raw, iter|
            tmp = Hash.new()
            formatted_lines[iter].split(" ").each_with_index { |amount, index| tmp[@alphabet[index]] = amount } 
            @penalty[raw] = tmp
        end

    end

end
