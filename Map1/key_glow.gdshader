shader_type spatial;
render_mode cull_front, unshaded; // Lật mặt ra ngoài và không bị ảnh hưởng bởi bóng tối

uniform float outline_thickness : hint_range(0, 0.1) = 0.0007; // Độ dày của viền
uniform vec4 outline_color : source_color = vec4(1, 0.8, 0, 1); // Màu vàng
uniform float emission_energy = 5.0; // Độ rực sáng

void vertex() {
    // Đẩy các đỉnh ra ngoài theo hướng vector pháp tuyến để tạo độ dày
    VERTEX += NORMAL * outline_thickness;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    // Tạo hiệu ứng phát sáng rực (Bloom) nếu game của bạn có bật WorldEnvironment - Glow
    EMISSION = outline_color.rgb * emission_energy;
}