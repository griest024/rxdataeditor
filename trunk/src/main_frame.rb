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

# This class is the main application frame
class MainFrame < Wx::MDIParentFrame
  # Initialization
  def initialize(pos, size)
    super(nil, Wx::ID_ANY, _('RXData Editor'), pos, size)
    init_menu
    init_toolbar
    #create_status_bar
    init_events
  end
  
  def init_menu
    menu_bar = Wx::MenuBar.new

    file_menu = Wx::Menu.new
    file_menu.append(Wx::ID_NEW, "%s\tCtrl+N" % _('&New file'))
    file_menu.append(Wx::ID_OPEN, "%s\tCtrl+O" % _('&Open file...'))
    file_menu.append_separator
    file_menu.append(Wx::ID_SAVE, "%s\tCtrl+S" % _('&Save file'))
    file_menu.append(Wx::ID_SAVEAS, _("S&ave file as..."))
    file_menu.append(Wx::ID_CLOSE, "%s\tCtrl+W" % _('&Close file'))
    file_menu.append_separator
    file_menu.append(Wx::ID_ADD, "%s\tCtrl+I"  % _('&Insert item'))
    file_menu.append(Wx::ID_REMOVE, _("&Delete item"))
    file_menu.append_separator
    file_menu.append(Wx::ID_UP, _("Move item &up"))
    file_menu.append(Wx::ID_DOWN, _("Move item &down"))
    file_menu.append_separator
    file_menu.append(Wx::ID_EXIT, "%s\tCtrl+Q" % _('Qui&t'))
    # TODO: file_menu.append(Wx::ID_ABOUT, "\tF1" % _('About...'))
    menu_bar.append file_menu, _("&File")
    
    edit_menu = Wx::Menu.new
    edit_menu.append(Wx::ID_UNDO, "%s\tCtrl+Z" % _('&Undo'))
    edit_menu.append(Wx::ID_REDO, "%s\tCtrl+Y" % _('&Redo'))
    edit_menu.append_separator
    edit_menu.append(Wx::ID_CUT, "%s\tCtrl+X" % _('Cu&t'))
    edit_menu.append(Wx::ID_COPY, "%s\tCtrl+C" % _('&Copy'))
    edit_menu.append(Wx::ID_PASTE, "%s\tCtrl+V" % _('&Paste'))
    # edit_menu.append_separator
    # TODO: edit_menu.append(Wx::ID_INDENT, "%s\tCtrl+T" % _('&Indent'))
    # TODO: edit_menu.append(Wx::ID_UNINDENT, "%s\tShift+Ctrl+T" % _('U&nindent'))
    # edit_menu.append_separator
    # TODO: edit_menu.append(Wx::ID_FIND, "%s\tCtrl+F" % _('&Find and replace...'))
    menu_bar.append(edit_menu, _("&Edit"))
    
    set_menu_bar(menu_bar)
  end
  
  def init_toolbar
    @toolbar = create_tool_bar(Wx::TB_FLAT|Wx::TB_HORIZONTAL) # |Wx::TB_TEXT
    
    @toolbar.add_tool(Wx::ID_NEW, _("New"),
      Wx::ArtProvider::get_bitmap(Wx::ART_NEW))
    @toolbar.add_tool(Wx::ID_OPEN, _("Open"),
      Wx::ArtProvider::get_bitmap(Wx::ART_FILE_OPEN))
    @toolbar.add_tool(Wx::ID_SAVE, _("Save"),
      Wx::ArtProvider::get_bitmap(Wx::ART_FILE_SAVE))
    @toolbar.add_separator
    
    @toolbar.add_tool(Wx::ID_ADD, _("Insert"),
      Wx::ArtProvider::get_bitmap(Wx::ART_ADD_BOOKMARK))
    @toolbar.add_tool(Wx::ID_REMOVE, _("Delete"),
      Wx::ArtProvider::get_bitmap(Wx::ART_DEL_BOOKMARK))
    @toolbar.add_separator
    
    @toolbar.add_tool(Wx::ID_UP, _("Up"),
      Wx::ArtProvider::get_bitmap(Wx::ART_GO_UP))
    @toolbar.add_tool(Wx::ID_DOWN, _("Down"),
      Wx::ArtProvider::get_bitmap(Wx::ART_GO_DOWN))
    @toolbar.add_separator
    
    @toolbar.add_tool(Wx::ID_UNDO, _("Undo"),
      Wx::ArtProvider::get_bitmap(Wx::ART_UNDO))
    @toolbar.add_tool(Wx::ID_REDO, _("Redo"),
      Wx::ArtProvider::get_bitmap(Wx::ART_REDO))
    @toolbar.add_separator
    
    @toolbar.add_tool(Wx::ID_CUT, _("Cut"),
      Wx::ArtProvider::get_bitmap(Wx::ART_CUT))
    @toolbar.add_tool(Wx::ID_COPY, _("Copy"),
      Wx::ArtProvider::get_bitmap(Wx::ART_COPY))
    @toolbar.add_tool(Wx::ID_PASTE, _("Paste"),
      Wx::ArtProvider::get_bitmap(Wx::ART_PASTE))
    @toolbar.add_separator
    
    @toolbar.add_tool(Wx::ID_FIND, _("Find"),
      Wx::ArtProvider::get_bitmap(Wx::ART_FIND))
    
    @toolbar.realize
  end
  
  def init_events
    evt_menu(Wx::ID_NEW) { |evt| on_new_file }
    evt_menu(Wx::ID_OPEN) { |evt| on_open_file }
    evt_menu(Wx::ID_EXIT) { |evt| on_quit }
    
    evt_menu(Wx::ID_SAVE) do |evt| 
      get_active_child.on_save_file  unless get_active_child.nil?
    end
    evt_menu(Wx::ID_SAVEAS) do |evt|
      get_active_child.on_save_file_as unless get_active_child.nil?
    end
    evt_menu(Wx::ID_CLOSE) do |evt| 
      get_active_child.close  unless get_active_child.nil?
    end
    evt_menu(Wx::ID_ADD) do |evt|
      get_active_child.on_insert_item unless get_active_child.nil?
    end
    evt_menu(Wx::ID_REMOVE) do |evt|
      get_active_child.on_delete_item unless get_active_child.nil?
    end
    evt_menu(Wx::ID_UP) do |evt|
      get_active_child.on_move_item_up unless get_active_child.nil?
    end
    evt_menu(Wx::ID_DOWN) do |evt|
      get_active_child.on_move_item_down unless get_active_child.nil?
    end
    
    evt_menu(Wx::ID_UNDO) do |evt|
      get_active_child.on_undo unless get_active_child.nil?
    end
    evt_menu(Wx::ID_REDO) do |evt|
      get_active_child.on_redo unless get_active_child.nil?
    end
    evt_menu(Wx::ID_CUT) do |evt|
      get_active_child.on_cut unless get_active_child.nil?
    end
    evt_menu(Wx::ID_COPY) do |evt|
      get_active_child.on_copy unless get_active_child.nil?
    end
    evt_menu(Wx::ID_PASTE) do |evt|
      get_active_child.on_paste unless get_active_child.nil?
    end
  end
  
  def new_file(object_class='Script')
    if object_class == _('Open existing file...')
      return on_open_file
    elsif object_class == 'RSC'
      frame_class = 'RSCEditor'
    else
      frame_class = object_class + 'sEditor'
    end
    if Object.constants.include?(frame_class)
      Object.const_get(frame_class).new(self)
    elsif RPG.constants.include?(object_class)
      frame = GenericEditor.new(self, '', RPG.const_get(object_class))
    else
      frame = GenericEditor.new(self, '', nil)
    end
  end
  
  def open_file(filename)
    if filename =~ /.rsc$/
      frame_class = 'RSCEditor'
    else
      frame_class = File.basename(filename).split('.')[0] + 'Editor'
    end
    Dir.chdir(File.dirname(filename))
    if Object.constants.include?(frame_class)
      frame = Object.const_get(frame_class).new(self, filename)
    else
      frame = GenericEditor.new(self, filename)
    end
  end
  
  def on_new_file
    choices = [_('Open existing file...')] + (RPG.constants - IGNORED +
      ['Script', 'RSC']).sort
    dialog = Wx::SingleChoiceDialog.new(self,
      _('Select an item class to create'), _('New file'), choices)
    if dialog.show_modal == Wx::ID_OK
      new_file(dialog.get_string_selection)
    end
    dialog.destroy
  end
  
  def on_open_file
    dialog = Wx::FileDialog.new(self, _('Open file'), '', '', WILDCARDS,
      Wx::FD_OPEN|Wx::FD_FILE_MUST_EXIST|Wx::FD_CHANGE_DIR|Wx::FD_MULTIPLE)
    if dialog.show_modal == Wx::ID_OK
      dialog.get_filenames.each { |fn| open_file(fn) }
    end
    dialog.destroy
  end
  
  def on_quit
    close
  end
end
