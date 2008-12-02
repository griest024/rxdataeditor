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

IGNORED = %w{AudioFile MoveRoute MoveCommand EventCommand Event}

# This class is the base for all data editors.
class EditorBase < Wx::MDIChildFrame
  # Object initialization
  def initialize(parent, filename = '', klass = nil)
    @filename = filename
    @modified = false
    @klass = klass
    @nil_items = 0
    @working = false
    title = File.exists?(filename) ? File.basename(filename) : _('Untitled')
    super(parent, Wx::ID_ANY, title)
    
    init_controls
    init_events
    
    if File.exists?(filename)
      load_data(filename)
    else
      insert_item(0, _('Empty'))
    end
    open_item(0)
    
    self.show(true)
    self.activate
  end
  
  # Initialize listbox, editor and splitter
  def init_controls
    @splitter = Wx::SplitterWindow.new(self, Wx::ID_ANY)
    @splitter.set_minimum_pane_size(160)
    
    @listbox = Wx::ListBox.new(@splitter)
    @editor = create_editor_ctrl(@splitter)
    
    @splitter.split_vertically(@listbox, @editor, 176)
    @splitter.update_size
  end
  
  # Initialize event bindings
  def init_events
    evt_listbox(@listbox.get_id) do |evt|
      open_item(@listbox.get_selection) unless @working
    end
    evt_listbox_dclick(@listbox.get_id) { |evt| on_rename_item }
  end
  
  # Abstract method for editor creation
  def create_editor_ctrl
    nil
  end
  
  # Load Marshal data from filename
  def load_data(filename)
    Wx::begin_busy_cursor
    @klass = nil
    @nil_items = 0
    data = File.open(filename, "rb") { |f| Marshal.load(f) }
    data.each do |item|
      if item.nil?
        @nil_items += 1
        next
      end
      @listbox.append(item_name(item), item)
      @klass = item.class if @klass.nil?
    end
    Wx::end_busy_cursor
    @modified = false
  end
  
  # Save Marshal data to filename
  def save_data(filename)
    save_item unless @id.nil?
    data = []
    for i in 1..@nil_items
      data << nil
    end
    @listbox.each do |id|
      obj = get_item(id)
      data << obj
      set_item_name(obj, @listbox.get_string(id))
      set_item_id(obj, id)
    end
    File.open(filename, "wb") { |f| Marshal.dump(data, f) }
    set_title(File.basename(filename))
    @modified = false
  end
  
  # Get item by id
  def get_item(id)
    @listbox.get_item_data(id)
  end
  
  # Set item by id
  def set_item(id, value)
    @listbox.set_item_data(id, value)
  end
  
  # Empty item
  def empty_item
    @klass.new
  end
  
  # Get item name
  def item_name(object)
    object.name
  end
  
  # Set item name
  def set_item_name(object, name)
    object.name = name
  end
  
  # Set item id
  def set_item_id(object, id)
    object.id = id if object.respond_to?('id='.to_sym)
  end
  
  # Rename a item
  def rename_item(id, name)
    @listbox.set_string(id, name)
    set_item_name(get_item(id), name)
  end
  
  # Open item
  def open_item(id, save = true)
    save_item if save and not @id.nil?
    @id = id
    @listbox.set_selection(id)
    load_item(id)
  end
  
  # Abstract method for saving current item
  def save_item
    return if @id.nil?
    @modified = true if item_modified?
    store_item @id
  end
  
  # Abstract method for loading current item
  def load_item(id)
    
  end
  
  # Abstract method for saving current item
  def store_item(id)
    
  end
  
  # Abstract method
  def item_modified?
    false
  end
  
  # Insert a new item
  def insert_item(id, name)
    @listbox.insert(name, id, empty_item)
    open_item(id, false)
  end
  
  # Clear current item
  def clear_item(id)
    @listbox.set_client_data(id, empty_item)
    open_item(id, false)
  end
  
  # Delete item
  def delete_item(id)
    if @listbox.get_count == 1
      clear_item(id)
      return
    end
    @working = true
    @listbox.delete(id)
    @working = false
    id -= 1 if id >= @listbox.get_count
    open_item(id, false)
  end
  
  # Move item
  def move_item(from, to)
    @working = true
    return if to == from or to < 0 or to >= @listbox.get_count
    name = @listbox.get_string(from)
    data = get_item(from)
    @listbox.insert(name, (from > to) ? to : (to + 1), data)
    @listbox.delete((from > to) ? (from + 1) : from)
    @working = false
    open_item(to, false)
  end
  
  # Saves the current data in a file
  def on_save_file
    unless File.exists?(@filename)
      return on_save_file_as
    end
    save_data(@filename)
  end
  
  # Opens a dialog to save the current data
  def on_save_file_as
    filename = Wx::file_selector(_('Save file'), '', @filename, 'rxdata',
        WILDCARDS, Wx::FD_SAVE | Wx::FD_OVERWRITE_PROMPT | FD_CHANGE_DIR)
    unless filename == ''
      @filename = filename
      on_save_file
    end
  end
  
  # Insert item event
  def on_insert_item
    name = Wx::get_text_from_user(_('Enter item name'), _('New item'))
    unless name == ''
      insert_item(@listbox.get_selection, name)
    end
  end
  
  # Rename item event
  def on_rename_item
    script_name = @listbox.get_string(@listbox.get_selection)
    name = Wx::get_text_from_user(_('Enter item name'), _('Rename item'),
      script_name)
    unless name == ''
      rename_item(@listbox.get_selection, name)
    end
  end
  
  # Delete item event
  def on_delete_item
    script_name = @listbox.get_string(@listbox.get_selection)
    if Wx::message_box(_("Delete script \"%s\"?") % script_name, 
      _('Delete script'), Wx::ICON_WARNING|Wx::YES_NO) == Wx::YES
      delete_item(@listbox.get_selection)
    end
  end
  
  # Move item up event
  def on_move_item_up
    id = @listbox.get_selection
    move_item(id, id - 1)
  end
  
  # Move item down event
  def on_move_item_down
    id = @listbox.get_selection
    move_item(id, id + 1)
  end
end


