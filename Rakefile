Dir.glob("tasks/*.rake").each { |r| import r }

task :release do
  sh "scripts/release"
end

task :default do
  sh "make"
end

