#!/usr/bin/env ruby
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


# Platform
WINDOWS = RUBY_PLATFORM =~ /(mswin|mingw|bccwin|wince)/i
UNIX = RUBY_PLATFORM =~ /(linux|freebsd|netbsd|cygwin)/i
LINUX = RUBY_PLATFORM =~ /linux/i
MAC = RUBY_PLATFORM =~ /darwin/i


begin 
  require 'rubygems'  
rescue LoadError 
end

gem 'wxruby', '<=1.9.8'
require 'wx'

begin
  require 'gettext'
rescue LoadError
end


require 'rmxp_db.rb'

require 'main_frame.rb'
require 'editor_base.rb'
require 'generic_editor.rb'
require 'scripts_editor.rb'
require 'rsc_editor.rb'

begin
  require 'rubyscript2exe'
  if WINDOWS
    RUBYSCRIPT2EXE.bin = [File.join("src", "rubyw.exe.manifest")]
    RUBYSCRIPT2EXE.rubyw = true
  end
  APP_DIR = File.dirname(RUBYSCRIPT2EXE.executable)
  exit 0 if RUBYSCRIPT2EXE.is_compiling?
rescue LoadError
  APP_DIR = File.dirname(__FILE__)
end


# Setup GetText
if defined? GetText
  GetText::TextDomain.add_default_locale_path(File.join(APP_DIR, 'locale',
    '%{locale}', 'LC_MESSAGES', '%{name}.mo'))
  GetText.bindtextdomain("rxdataed")
  def _(s) # :nodoc:
    GetText._(s)
  end
else
  def _(s) # :nodoc:
    s
  end
end


# Wildcards
WILDCARDS = '%s|*.rxdata;*.rsc|%s (*.rxdata)|*.rxdata|%s (*.rsc)|*.rsc|%s|*.*'%
  [_('All supported files'),
   _('RPG Maker XP data'),
   _('Ruby script collection'),
   _('All files')]


# This class represents the whole application
class RXDataEd < Wx::App
  def on_init
    @frame = MainFrame.new([0, 0], [800, 600])
    set_top_window(@frame)
    
    ARGV.each { |filename| @frame.open_file(filename) }
    @frame.show(true)
    @frame.on_new_file if ARGV.size == 0
  end
end


# Load plugins
Dir.glob(File.join(APP_DIR, 'plugins', '**', '*.rb')).each { |fn| require fn }

begin
  RXDataEd.new.main_loop if __FILE__ == $0
rescue
  File.open(File.join(APP_DIR, 'errorlog.yml'), 'a+') do |f|
    f.puts '---'
    f.puts 'time:     ' + Time.now.strftime("%a %d %b %Y, %X") 
    f.puts 'platform: ' + RUBY_PLATFORM
    f.puts 'type:     ' + $!.class.to_s
    f.puts 'message:  ' + $!.message
    f.puts 'backtrace:'
    $!.backtrace.each { |l| f.puts '    - ' + l }
  end
end
