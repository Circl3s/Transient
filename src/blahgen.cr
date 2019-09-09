module Blah
    extend self

    VOWELS = ["a", "e", "i", "o", "u", "y",
              "A", "E", "I", "O", "U", "Y"]
              
    CONSONANTS = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "x", "z", "w",
                  "B", "C", "D", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "V", "X", "Z", "W"]
    
    def gen(length)
        str = ""
        length.times do |i|
            str = str + syl()
        end
        return str
    end

    def syl()
        return CONSONANTS.sample + VOWELS.sample
    end
end