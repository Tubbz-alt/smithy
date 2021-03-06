Given /^my hostname is "([^"]*)"$/ do |hostname|
    ENV['HOSTNAME'] = hostname
end

Given /^a software root in "([^"]*)" exists$/ do |path|
  FileUtils.mkdir(path) unless File.directory?(path)
  @temp_swroot = path
end

Given /^an architecture folder named "([^"]*)" exists$/ do |arch|
  @arch = arch
  @full_swroot = File.join(@temp_swroot, arch)
  FileUtils.mkdir(@full_swroot) unless File.directory?(@full_swroot)
end

Given /^my config file contains:$/ do |string|
  config = "tmp/smithyrc"
  @config_backup = ENV['SMITHY_CONFIG']
  File.open(config, "w+") do |file|
    file.puts string
  end
  ENV['SMITHY_CONFIG'] = File.join(Dir.pwd, config)
end

Then /^a file named "([^"]*)" should be group writable$/ do |file|
  mode = File.stat(file).mode.to_s(8)
  group_bit = mode[mode.size-2].to_i
  unless group_bit >= 6 && group_bit <= 7
    raise "#{file} is not group writeable"
  end
end

Then /^a file named "([^"]*)" should not be group writable$/ do |file|
  mode = File.stat(file).mode.to_s(8)
  group_bit = mode[mode.size-2].to_i
  unless group_bit == 4 || group_bit == 5
    raise "#{file} is group writeable"
  end
end

Then /^a file named "([^"]*)" should be executable$/ do |file|
  raise "#{file} is not executable" unless File.executable?(file)
end

Then /^a file named "([^"]*)" should have a group name of "([^"]*)"$/ do |file, group|
  Etc.getgrgid(File.stat(file).gid).name.should == group
end

Given /^a tarfile named "([^"]*)"$/ do |tarfile|
  tarfile =~ /(.*).tar.gz/
  basename = $1
  step "I run `mkdir -p #{basename}`"
  step "I run `touch #{basename}/configure`"
  step "I run `tar cf #{basename}.tar #{basename}`"
  step "I run `gzip #{basename}.tar`"
end

Then /^show me the files$/ do
  puts `tree #{@temp_swroot}`
end

Then /^a symlink named "(.*?)" should exist$/ do |file|
  File.symlink?(file).should == true
end
