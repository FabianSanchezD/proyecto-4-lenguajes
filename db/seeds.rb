puts "Limpiando datos previos..."
Match.delete_all
Team.delete_all
Group.delete_all

DRAW = {
  "A" => [["México", 1], ["Sudáfrica", 3], ["Corea del Sur", 2], ["República Checa", 4]],
  "B" => [["Canadá", 1], ["Bosnia y Herzegovina", 4], ["Catar", 3], ["Suiza", 2]],
  "C" => [["Brasil", 1], ["Marruecos", 2], ["Haití", 4], ["Escocia", 3]],
  "D" => [["Estados Unidos", 1], ["Paraguay", 3], ["Australia", 2], ["Turquía", 4]],
  "E" => [["Alemania", 1], ["Curazao", 4], ["Costa de Marfil", 3], ["Ecuador", 2]],
  "F" => [["Países Bajos", 1], ["Japón", 2], ["Suecia", 4], ["Túnez", 3]],
  "G" => [["Bélgica", 1], ["Egipto", 3], ["Irán", 2], ["Nueva Zelanda", 4]],
  "H" => [["España", 1], ["Cabo Verde", 4], ["Arabia Saudita", 3], ["Uruguay", 2]],
  "I" => [["Francia", 1], ["Senegal", 2], ["Irak", 4], ["Noruega", 3]],
  "J" => [["Argentina", 1], ["Argelia", 3], ["Austria", 2], ["Jordania", 4]],
  "K" => [["Portugal", 1], ["RD del Congo", 4], ["Uzbekistán", 3], ["Colombia", 2]],
  "L" => [["Inglaterra", 1], ["Croacia", 2], ["Ghana", 4], ["Panamá", 3]]
}.freeze

puts "Creando grupos, selecciones y calendarios..."
DRAW.each do |name, teams|
  group = Group.create!(name: name)
  teams.each { |team_name, pot| Team.create!(name: team_name, group: group, pot: pot) }
  Schedule::GroupFixtureGenerator.new(group).call
end

puts "Listo: #{Group.count} grupos, #{Team.count} selecciones, #{Match.count} partidos."
