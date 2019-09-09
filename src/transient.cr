require "http"
require "file_utils"
require "logger"
require "kemal"
require "redis"
require "./blahgen"
require "./db"

module Transient

    LOG = Logger.new(STDOUT)

    LOG.info("Starting setup...")

    get "/" do |env|
%{Transient!

Yet another ephemeral file hosting service made mainly to try out my knowledge of HTTP and databases in practice.

How does it work?
1. POST a file to https://0.0.0.0:3000/. You will get a passcode.
2. GET a file you uploaded from https://0.0.0.0:3000/dl/<passcode>/<name_of_file>/
3. Your file will be deleted in a day or after the first download, whichever comes first.

Happy uploading!

Made with <3 by Circl3s.
}
    end

    post "/" do |env|   #TODO: Give a response.
        HTTP::FormData.parse(env.request) do |upload|
            filename = upload.filename
            if !filename.is_a?(String)
                LOG.warn("It seems someone's trying to upload a file with no name? Interesting...")
            else
                blah = Blah.gen(5)
                FileUtils.mkdir("./files/#{blah}")
                file_path = "./files/#{blah}/#{filename}"
                File.open(file_path, "w") do |f|
                    IO.copy(upload.body, f)
                end
                
                DB.write(blah, filename)
                "Successfully uploaded #{filename}!\n\nYour passcode is: \n\n#{blah}\n\nDon't lose it!\nIf you want to retrieve your file, just go to https://0.0.0.0:3000/dl/#{blah}/#{filename}"
            end
        end
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
            "No such file or the passcode and name don't match."
        end
    end

    LOG.info("Starting server!")
    Kemal.run
end