require "./transient"

module DB
    extend self
    Transient::LOG.info("Connecting to Redis...")
    REDIS = Redis.new

    def write(pass, file)
        REDIS.setex(pass, 86400, file)
        Transient::LOG.info("Created new key: #{pass} = #{file}")
    end

    def read(pass, file)
        Transient::LOG.info("Looking for #{pass}:#{file}")
        local = REDIS.get(pass)
        if local == file
            REDIS.del(pass)
            return "./files/#{pass}/secret"
        else
            return "0"
        end
    end

    def check(pass)
        ttl = REDIS.ttl(pass)
        if ttl <= 0
            return true
        else
            return false
        end
    end

    Transient::LOG.info("Connected successfully!")
end