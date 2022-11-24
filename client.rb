#!/usr/bin/env ruby

#==========================================
# Title:  Script-Network
# Author: Bruno DA COSTA CUNHA
# Date:    20/03/2022
#==========================================


require "socket"
s = TCPSocket.open(ARGV[0], ARGV[1].to_i) # Création de la socket et connexion
while line = STDIN.gets do # pour toutes les lignes de l'entrée standard
    s.puts line # émission de la ligne vers le serveur
    break if line.chomp == "exit" # chomp retire l'\n' final
    puts s.gets # Affiche la ligne en provenance du serveur
end
s.close # fermeture de la socket
