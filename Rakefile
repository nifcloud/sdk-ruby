require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/test_*.rb'
    test.verbose = true
    test.rcov_opts << "--exclude /gems/,/Library/,spec"
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: [sudo] gem install rcov"
  end
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "NIFTY Cloud SDK documentation"
  rdoc.main = "README.rdoc"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('LICENSE*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '--line-numbers'
  rdoc.options << '-c UTF-8'
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    #t.files   = ['lib/**/*.rb']
  end
rescue LoadError
  puts "YARD (or a dependency) not available. Install it with: [sudo] gem install yard"
end

desc "Generate a perftools.rb profile"
task :profile do
  system("CPUPROFILE=perftools/ec2prof RUBYOPT=\"-r`gem which perftools | tail -1`\" ruby sample/describe-instances.rb")
  system("pprof.rb --text --ignore=Gem perftools/ec2prof > perftools/ec2prof-results.txt")
  system("pprof.rb --dot --ignore=Gem perftools/ec2prof > perftools/ec2prof-results.dot")
end

