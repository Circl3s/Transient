require "http"
require "file_utils"
require "logger"
require "kemal"
require "redis"
require "kilt/slang"
require "./blahgen"
require "./db"

module Transient

    LOG = Logger.new(STDOUT)

    LOG.info("Starting setup...")

    FileUtils.mkdir("./files") unless Dir.exists?("./files")

    ADDRESS = "thetahq.klapa.eu/maak"

    MES = %{Transient!

Yet another ephemeral file hosting service made mainly to try out my knowledge of HTTP and databases in practice.

How does it work?
1. POST a file to https://#{ADDRESS}/. You will get a passcode.
2. GET a file you uploaded from https://#{ADDRESS}/dl/[passcode]/[name_of_file]/
3. Your file will be deleted in a day or after the first download, whichever comes first.

Happy uploading!

Made with <3 by Circl3s.
}

    get "/" do |env|
        MES
    end

    post "/" do |env|
        var = ""
        HTTP::FormData.parse(env.request) do |upload|
            filename = upload.filename
            if !filename.is_a?(String)
                LOG.warn("It seems someone's trying to upload a file with no name? Interesting...")
            else
                blah = Blah.gen(5)
                FileUtils.mkdir("./files/#{blah}")
                file_path = "./files/#{blah}/secret"
                File.open(file_path, "w") do |f|
                    IO.copy(upload.body, f)
                end
                
                DB.write(blah, filename)
                var = "Successfully uploaded #{filename}!\n\nYour passcode is: \n\n#{blah}\n\nDon't lose it!\nIf you want to retrieve your file, just go to https://#{ADDRESS}/dl/#{blah}/#{filename}"
            end
        end
        var
    end

    get "/dl/:pass/:name" do |env|
        pass = env.params.url["pass"]
        name = env.params.url["name"]
        begin
            path = DB.read(pass, name)
            send_file(env, path)
            FileUtils.rm(path)
            if Dir.empty?("./files/#{pass}")
                FileUtils.rmdir("./files/#{pass}")
            end
        rescue err
            env.response.status = HTTP::Status::NOT_FOUND
            "No such file or the passcode and name don't match."
        end
    end

    SYNONYMS = ["Destroyed", "Deleted", "Obliterated", "Nuked", "Consumed", "Crushed", "Ended", "Eradicated", "Wiped out", "Annihilated", "Aborted", "Annuled", "Butchered", "Slayed", "Trashed", "Erased", "Killed", "Smashed", "Exterminated"]

    spawn do
        while true
            LOG.info("It is I - the garbage man!")
            dir = Dir.new("./files")
            count = 0

            dir.each_child do |entry|
                if DB.check(entry) == true
                    FileUtils.rm_rf("./files/#{entry}")
                    LOG.warn("#{SYNONYMS.sample} #{entry}!")
                    count += 1
                end
            end
        LOG.info("The garbage man has finished his work - #{count} entries removed.")
        sleep 1.hours
        end
    end

    LOG.info("Starting server!")
    Kemal.run(666)
end