task default: :test
task default: :test2

desc 'Say hello!'
task :hello do
  puts "hello, world!"
end

desc 'Run my tests!'
task :test do
  sh "bundle exec mrspec"
end

desc 'rubocop runner'
task :test2 do
  sh "rubocop --fail-fast"
end

