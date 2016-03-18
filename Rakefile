task default: :test
task defualt: :rubocop
task default: :test2

desc 'Say hello!'
task :hello do
  puts "hello, world!"
end

desc 'Run my tests!'
task :test do
  sh "bundle exec mrspec"
end

desc 'rubocop test'
task :rubocop do
  sh "rubocop"
end

desc 'rubocop runner'
task :test2 do
  sh "rubocop"
end
