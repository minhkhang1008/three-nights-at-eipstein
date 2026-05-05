# HƯỚNG DẪN CÀI ĐẶT VÀ TRIỂN KHAI

Tài liệu này hướng dẫn cách trải nghiệm game cũng như cách mở mã nguồn dự án dành cho các nhà phát triển.

## 1. Dành Cho Người Chơi (Game Player)
1. Tải bản build mới nhất của game tại [https://khangm.itch.io/three-nights-at-eipstein](https://khangm.itch.io/three-nights-at-eipstein)
2. Giải nén file zip
3. Nhấp đúp chuột vào file thực thi (`WindowBuild.exe` trên Windows hoặc mở game trong file MacBuild.dmg trên macOS) để bắt đầu trải nghiệm.
4. Điều khiển:
   - `W, A, S, D`: Di chuyển
   - `Chuột`: Xoay góc nhìn
   - `E`: Tương tác (Mở cửa, nhặt vật phẩm)
   - `A, B, C, D`: Chọn đáp án khi giải đố
- Mong muốn của nhóm là để người chơi tự mày mò và tính toán đường đi vậy nên sẽ không có hướng dẫn cụ thể ingame!

## 2. Dành Cho Nhà Phát Triển (Developer)
Nếu bạn muốn mở mã nguồn để tiếp tục phát triển dự án:

### Yêu cầu hệ thống:
* Đã cài đặt **Godot Engine phiên bản 4.x** (khuyên dùng Godot 4.3 trở lên).

### Các bước cài đặt:
1. Clone repository này về máy:
   ```bash
   git clone https://github.com/minhkhang1008/three-nights-at-eipstein.git
   ```
2. Mở Godot Engine, tại Project Manager, bấm nút Import.
3. Điều hướng tới thư mục vừa clone, chọn file project.godot và bấm Import & Edit.
4. Khi muốn chơi thử, chạy file main_menu.scn hoặc nhấn F5 để Play game trong môi trường Debug.

### Thông tin các dạng file:
- File tscn (text scene) hoặc scn (binary scene) là các file chứa các scene lớn hoặc nhỏ phục vụ cho các mục đích khác nhau. Ví dụ: map1_scary.scn là file chứa đầy đủ map 1. Các file scene có thể lồng vào nhau
- File gd (godot script) là các file code logic sử dụng ngôn ngữ godot script
- File .tres (text resource) hoặc .res (binary resource) là các file chứa tài nguyên game (ví dụ như TileMap)
- File .glb là các file model 3D
- FIle .ogv là các file video