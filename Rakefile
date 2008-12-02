=begin
  Copyright (C) 2008  tibuda

  This file is part of RXData Editor

  RXData Editor is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  RXData Editor is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with RXData Editor.  If not, see <http://www.gnu.org/licenses/>.
=end


APP = 'rxdataed'

VCS = '.svn'


if RUBY_PLATFORM =~ /(mswin|mingw|bccwin|wince)/i
  EXEC = "#{APP}.exe"
elsif RUBY_PLATFORM =~ /darwin/i
  EXEC = "#{APP}.app"
else
  EXEC = APP
end


src_files     = FileList[File.join('src', '**', '*.rb'), 'Rakefile']
extra_files   = FileList[File.join('src', 'rubyw.exe.manifest'),
                         File.join('**', '*.dll')]
doc_files     = FileList['TODO', 'README', 'COPYING']
po_files      = Dir.glob(File.join('po', '**', '*.po'))
plugin_files  = FileList[File.join('plugins', '**', '*.rb')]
project_files = src_files + extra_files + doc_files + po_files + plugin_files


task :default => [EXEC]


desc "Create binary executable"
task :build => [EXEC, :makemo]
file EXEC => src_files do |t|
  if RUBY_PLATFORM =~ /(mswin|mingw|bccwin|wince)/i
    sh("ruby rubyscript2exe.rb src/#{APP}.rb --rubyscript2exe-rubyw")
  else
    sh("rubyscript2exe src/#{APP}.rb --rubyscript2exe-rubyw")
  end
  mv("#{APP}_linux", t.name) if File.exists?("#{APP}_linux")
end


desc "Create tarball archive"
task :archive => ["#{APP}.tar.gz"]
file "#{APP}.tar.gz" => project_files do |t|
  require 'archive/tar'
  Archive::Tar.create(t.name, t.prerequisites, :compression => :gzip)
end


desc "Create zip archive"
task :zip => ["#{APP}.zip"]
file "#{APP}.zip" => project_files do |t|
  require 'archive/zip'
  # FIXME: directories are not used when creating the zip
  Archive::Zip.archive(t.name, t.prerequisites)
end


desc "Clear working directory"
task :clean do
  files = Dir.glob(File.join('**', '*~')) + FileList['*.tar.gz', '*.zip']
  files << EXEC if File.exists?(EXEC)
  rm(files) if files.size > 0
  rm_rf('doc') if File.directory?('doc')
end


file 'TODO' => src_files do |t|
  File.open(t.name, 'w') do |output|
    t.prerequisites.each do |fn|
      File.open(fn, 'r') do |input|
        input.each_with_index do |text, line|
          if text =~ /# (TODO|FIXME): /
            comment = text.split('#')[1].strip
            output.write("#{fn}:#{line + 1}: #{comment}\n")
          end
        end
      end
    end
  end
end




desc 'Update po/pot files'
task :updatepo => src_files do |t|
  require 'gettext/utils'
  GetText.update_pofiles(APP, t.prerequisites, 0)
end


desc 'Create mo files'
task :makemo => src_files do |t|
  require 'gettext/utils'
  GetText.create_mofiles(true, "po", "locale")
end


