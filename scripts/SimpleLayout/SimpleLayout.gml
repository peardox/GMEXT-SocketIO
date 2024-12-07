function Rect(_left, _top, _width, _height) constructor {
	self.top = 0;
	self.left = 0;
	self.bottom = 0;
	self.right = 0;
	self.width = 0;
	self.height = 0;
	
//	if( (typeof(_left) == "int64") && (typeof(_top) == "int64") && (typeof(_width) == "int64") && (typeof(_height) == "int64")) {
		top = _top;
		left = _left;
		width = _width;
		height = _height;
		bottom = top + height;
		right = left + width;
//	}
}

function Layout(_rect, _border = 0) constructor {
	self.rect = _rect;
	self.border = _border;
}

function ButtonLayout(_owner, _columns, _rows, _border) constructor {
	self.owner = _owner;
	self.columns = _columns;
	self.rows = _rows;
	self.border = _border;
	self.width = 0;
	self.height = 0;
	
	// feather ignore once GM2017
	static CalculateSize = function() {
		if((is_instanceof(owner, Layout)) && (owner.rect.width > 0) && (owner.rect.height > 0)) {
			width = ((owner.rect.width - owner.border) ) / columns;
			height = ((owner.rect.height - owner.border) ) / rows;
		} else {
			throw("CalculateSize requires a valid Layout");
		}
	}
	
	// feather ignore once GM2017
	static GetPosition = function(_x, _y) {
		if((width > 0) && (height > 0)) {
			var _bpx = int64(( (width * _x) + (border / 2) ) + (_x * (border / (columns - 1))) );// + owner.border );
			var _bpy = int64(( (height * _y) + (border / 2) ) + (_y * (border / (rows - 1))) );// + owner.border );
			var _bpw = int64( width - ( border / 2) );
			var _bph = int64( height - ( border / 2) );
			return new Rect( _bpx, _bpy, _bpw, _bph );
		} else {
			throw("GetPosition Error");
		}
	}
	
}

