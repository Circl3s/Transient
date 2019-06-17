require "./transient"

module DB
    extend self
    REDIS = Redis.new

    def write(pass, file)
        REDIS.setex(pass, 600, file)
        puts "Created new key: #{pass} = #{file}"
    end

    def read(pass, file)
        puts "Looking for #{pass}:#{file}"
        local = REDIS.get(pass)
        if local == file
            REDIS.del(pass)
            return "./files/#{pass}/#{local}"
        else
            return "0"
        end
    end
end