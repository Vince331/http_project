task default: :test
task defualt: :rubocop

desc 'Say hello!'
task :hello do
  puts "hello, world!"
end

desc 'Run my test!'
task :test do
  sh "bundle exec mrspec"
end

desc 'rubocop test'
task :rubocop do
  sh "rubocop --fail-fast"
end
