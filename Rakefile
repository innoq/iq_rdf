require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/rdoctask'
require 'rake/testtask'

Rake::RDocTask.new do |rdoc|
  files = ['README.rdoc', 'LICENSE', 'lib/**/*.rb', 'rails/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.rdoc" # page to start on
  rdoc.title = "IqRdf Documentation"
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
