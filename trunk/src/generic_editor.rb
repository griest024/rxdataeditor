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


class GenericEditor < EditorBase
  def create_editor_ctrl parent
    Wx::Grid.new parent
  end
  
  def load_item(id)
    object = get_item(id)
    
    @editor.clear_grid
    @editor.set_table(ObjectGridTable.new(get_item(id)))
    @editor.auto_size
    @editor.force_refresh
  end
  
  def store_item(id)
    set_item(id, @editor.get_table.object)
  end
end


class ObjectGridTable < Wx::GridTableBase
  attr_reader :object
  
  def initialize(object)
    super()
    @object = object
    @variables = (object.instance_variables - ['@id', '@name']).sort
  end
  
  def get_attr(row, col, attr_kind)
    att = Wx::GridCellAttr.new()
    att.set_read_only(col == 0)
    return att
  end
  
  def get_number_cols
    2
  end
  
  def get_number_rows
    @variables.size
  end
  
  def get_col_label_value(col)
    col == 0 ? _('Property') : _('Value')
  end
  
  def get_value(row, col)
    if col == 0
      @variables[row]
    else
      value = @object.instance_variable_get(@variables[row])
      value.is_a?(Array) ? value.join(', ') : value.to_s
    end
  end
  
  def set_value(row, col, value)
    return if col == 0
    value = case @object.instance_variable_get(@variables[row])
      when String: value
      when Integer: value.to_i
      else nil
    end
    @object.instance_variable_set(@variables[row], value) unless value.nil?
  end
  
  def is_empty_cell(row, col)
    @object.instance_variable_get(@variables[row]).nil?
  end
end

