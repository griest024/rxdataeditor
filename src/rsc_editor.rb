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

class RSCEditor < ScriptsEditor
  # Get item name
  def item_name(object)
    object[0]
  end
  
  # Set item name
  def set_item_name(object, name)
    object[0] = name
  end
  
  def load_item(id)
    @editor.set_text(Zlib::Inflate.inflate(get_item(id)[1]))
    @editor.set_save_point
  end
  
  def store_item(id)
    get_item(id)[1] = Zlib::Deflate.deflate(@editor.get_text)
    @editor.set_save_point
  end
  
  def empty_item
    ['', Zlib::Deflate.deflate('')]
  end
end
