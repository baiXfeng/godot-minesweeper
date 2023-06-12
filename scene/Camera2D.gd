extends Camera2D

# 屏幕(视口)坐标转换全局坐标
func to_actual_position(screen_point:Vector2) -> Vector2:
	var inv_canv_tfm: Transform2D = self.get_canvas_transform().affine_inverse()
	var half_screen: Transform2D = Transform2D().translated(screen_point)
	var actual_screen_center_pos: Vector2 = inv_canv_tfm * half_screen * Vector2.ZERO
	return actual_screen_center_pos
