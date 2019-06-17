module Blah
    extend self

    VOWELS = ["a", "e", "i", "o", "u", "y"]
    CONSONANTS = ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "x", "z", "w"]
    
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