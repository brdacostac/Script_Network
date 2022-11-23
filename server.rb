#!/usr/bin/env ruby
 
require 'socket'
server = TCPServer.new ARGV[0] # socket d'écoute attaché au port passé en argument 
loop do # boucle infinie
    client = server.accept    # attente d'une connexion
    while request=client.gets.chomp do # pour toutes les lignes reçues
        case request
            when "time"     then client.puts "#{Time.now}" # émission de la réponse
            when "exit"     then break
            else client.puts "error"
        end 
    end
    client.close # fermeture de la connexion
end
