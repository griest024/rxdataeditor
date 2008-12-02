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

require 'zlib'

# This frame allows the user to edit Scripts.rxdata in a Scintilla editor,
# with the following features:
# 
# * Syntax highlighting similar to the used in RPG Maker XP
# * Code folding
# * 
class ScriptsEditor < EditorBase
  # Font size
  SIZE = 9
  
  # Syntax specs
  SPECS = {
    Wx::STC_STYLE_DEFAULT => "fore:#000000;back:#FFFFFF",
    Wx::STC_STYLE_LINENUMBER => "size:#{SIZE-3}",
    2 => "fore:#008000", # Line comment
    3 => "fore:#008000", # Block comment
    4 => "fore:#FF0000", # Numbers
    5 => "fore:#0000FF", # Keywords
    6 => "fore:#800080", # Double quotes string
    7 => "fore:#800080", # Single quotes string
  }
  
  # Language keywords
  KEYWORDS = 'begin break elsif module retry unless end case next return
    until class ensure nil self when def false not super while alias defined?
    for or then yield and do if redo true else in rescue undef'
  
  # Creates Scintilla editor
  def create_editor_ctrl parent
    # Create editor object
    editor = Wx::StyledTextCtrl.new(parent)
    # Set Ruby lexer
    editor.set_lexer Wx::STC_LEX_RUBY
    
    # Basic setup
    editor.set_edge_mode Wx::STC_EDGE_LINE
    editor.set_eol_mode Wx::STC_EOL_CRLF # RGSS player requires CRLF
    editor.set_wrap_mode Wx::STC_WRAP_NONE
    editor.set_use_tabs false
    editor.set_caret_line_visible true
    editor.set_caret_line_background Wx::Colour.new(240, 240, 240)
    editor.set_tab_indents true
    editor.set_indent 2
    editor.set_tab_width 4
    editor.set_indentation_guides false
    editor.set_back_space_un_indents true
    editor.set_edge_column 80
    
    # Setup font
    font = Wx::Font.new SIZE, Wx::TELETYPE, Wx::NORMAL, Wx::NORMAL
    editor.style_set_font Wx::STC_STYLE_DEFAULT, font
    
    # Setup syntax highlight
    editor.style_clear_all
    SPECS.each { |style, spec| editor.style_set_spec style, spec }
    editor.set_key_words 0, KEYWORDS
    
    # Folding setup
    editor.set_property 'fold', '1'
    editor.set_property 'fold.compact', '0'
    editor.set_property 'fold.comment', '1'
    editor.set_property 'fold.preprocessor', '1'
    
    # Setup line number margin
    editor.set_margin_width 0, editor.text_width(Wx::STC_STYLE_LINENUMBER,
      "_9999")
    
    # Setup folding margin
    editor.set_margin_width 1, 0
    editor.set_margin_type 1, Wx::STC_MARGIN_SYMBOL
    editor.set_margin_mask 1, Wx::STC_MASK_FOLDERS
    editor.set_margin_width 1, 12
    # Setup folding markers
    editor.marker_define Wx::STC_MARKNUM_FOLDER, Wx::STC_MARK_PLUS
    editor.marker_define Wx::STC_MARKNUM_FOLDEROPEN, Wx::STC_MARK_MINUS
    editor.marker_define Wx::STC_MARKNUM_FOLDEREND, Wx::STC_MARK_EMPTY
    editor.marker_define Wx::STC_MARKNUM_FOLDERMIDTAIL, Wx::STC_MARK_EMPTY
    editor.marker_define Wx::STC_MARKNUM_FOLDEROPENMID, Wx::STC_MARK_EMPTY
    editor.marker_define Wx::STC_MARKNUM_FOLDERSUB, Wx::STC_MARK_EMPTY
    editor.marker_define Wx::STC_MARKNUM_FOLDERTAIL, Wx::STC_MARK_EMPTY
    editor.set_fold_flags 16
    
    return editor
  end
  
  # Initialize events
  def init_events
    super
    evt_stc_charadded(@editor.get_id) do |evt|
      on_editor_char_added evt.get_key
    end
    evt_stc_marginclick(@editor.get_id) do |evt|
      on_editor_margin_click evt.get_position, evt.get_margin
    end
  end
  
  # Auto indent
  def on_editor_char_added chr
    curr_line = @editor.get_current_line
    if [10, 13].include? chr and curr_line > 0
      line_ind = @editor.get_line_indentation curr_line - 1
      if (curr_line == 1 and @editor.get_fold_level(curr_line - 1) > 1024) or 
        (curr_line > 1 and @editor.get_fold_level(curr_line - 1) >
        @editor.get_fold_level(curr_line - 2))
        line_ind += @editor.get_indent
      # FIXME: auto "unindent"
      #elsif get_line(curr_line - 1).strip == 'end'
      #  line_ind -= get_indent
      #  line_ind = 0 if line_ind < 0
      #  set_line_indentation curr_line - 1, line_ind
      #elsif get_line(curr_line - 1).strip == 'else'
      #  set_line_indentation curr_line - 1, line_ind - get_indent
      end
      if line_ind > 0
        @editor.set_line_indentation curr_line, line_ind
        @editor.goto_pos @editor.position_from_line(curr_line) + line_ind
      end
    end
  end
  
  # Toggle fold from position line
  def on_editor_margin_click position, margin
    @editor.toggle_fold @editor.line_from_position(position) if margin == 1
  end
  
  # Get item name
  def item_name(object)
    object[1]
  end
  
  # Set item name
  def set_item_name(object, name)
    object[1] = name
  end
  
  def set_item_id(object, id)
  end
  
  # Is the item different from when it was last opened?
  def item_modified?
    @editor.get_modify
  end
  
  def load_item(id)
    @editor.set_text(Zlib::Inflate.inflate(get_item(id)[2]))
    @editor.set_save_point
  end
  
  def store_item(id)
    get_item(id)[2] = Zlib::Deflate.deflate(@editor.get_text)
    @editor.set_save_point
  end
  
  def empty_item
    [0, '', Zlib::Deflate.deflate('')]
  end
end

