install sap SAP Fiori Tools - Service Modeler trong extentions vs code
the menu bar, choose View Command Palette..., and enter Open Template Wizard.
B. Nếu dùng lazy route / React.lazy

Phải test click vào page lazy-loaded sau khi build.
Vì khi base sai, entry có thể lên nhưng chunk động lại fail. Vite docs nói preload và asset URLs phụ thuộc vào base; với relative base, runtime mới tránh phụ thuộc absolute path.

C. Nếu dùng file tĩnh trong public

Nhớ rằng public sẽ được copy nguyên vào root của outDir. Vite docs ghi rõ thư mục public được serve ở / khi dev và copy sang root của outDir khi build.
⚙️ 7) Support dynamic content?

👉 Bạn đang chọn:

No

👉 ✔️ giữ nguyên

Khi nào chọn Yes?
app thay đổi nội dung theo SAP context (form, object, etc.)

👉 hiện tại bạn chưa cần
npm install -g mbt

Mở PowerShell Run as Administrator:

choco install make
rồi chạy mbt build
https://172.20.146.57:40020/auth/realms/sapb1/login-actions/authenticate?execution=b47a322b-2728-42cd-ad6e-599a4c87d2ed&client_id=b1-extmng-0000-main-adm&tab_id=3Ymk-ITTRt4&client_data=eyJydSI6Imh0dHBzOi8vMTcyLjIwLjE0Ni41Nzo0MDAwMC9FeHRlbnNpb25NYW5hZ2VyLyIsInJ0IjoiY29kZSIsInJtIjoiZnJhZ21lbnQiLCJzdCI6IjBiNjllZDYyMThkYTQ4NTg5NTdiZDY2NTgxZDY4NjMxIn0
Chào bạn, với tư cách là một lập trình viên đang làm việc với SAP Business One (SBO), việc triển khai ứng dụng React (dưới dạng file `.mtar`) lên Web Client là một quy trình chuẩn để mở rộng hệ sinh thái Web của SAP.

Để "preview" ứng dụng này trên giao diện máy của bạn (giống như cách chạy Add-on trên SBO Client truyền thống), bạn cần thực hiện qua 3 giai đoạn chính trên **Extension Manager**. Dưới đây là hướng dẫn chi tiết và chuyên sâu:

### 1. Truy cập vào Extension Manager

Mọi Extension của Web Client đều phải được quản lý tập trung thông qua công cụ này.

- **Địa chỉ truy cập:** `https://<Tên_Server_Hoặc_IP>:40000/ExtensionManager/`
- **Đăng nhập:** Sử dụng tài khoản **B1SiteUser** (đây là tài khoản quản trị hệ thống Server Tools).

### 2. Giai đoạn 1: Import Extension (Tải file .mtar lên hệ thống)

Bước này tương đương với việc bạn đăng ký file chạy với hệ thống SAP.

1.  Tại giao diện Extension Manager, chọn tab **Extensions**.
2.  Nhấn nút **Import**.
3.  Chọn file `.mtar` mà bạn đã đóng gói từ dự án React của mình.
4.  Hệ thống sẽ phân tích file và hiển thị thông tin như: Extension Name, Version, Vendor, và Type (thường là _Web Client UI_).
5.  Nhấn **Finish** để hoàn tất việc đưa file vào kho lưu trữ của Server.

### 3. Giai đoạn 2: Company Assignment (Gán Extension vào Database)

Khác với Add-on truyền thống có thể chạy độc lập, Web Extension phải được "gán" (Assign) vào một Database cụ thể để xuất hiện trên Web Client của Database đó.

1.  Chuyển sang tab **Company Assignment**.
2.  Ở cột bên trái, chọn đúng **Company Database** mà bạn đang dùng để test.
3.  Nhấn nút **Assign**.
4.  Một danh sách các Extension đã Import sẽ hiện ra. Chọn Extension bạn vừa tải lên ở Bước 2.
5.  Nhấn **Next** và **Finish**. Lúc này, trạng thái của Extension trong Database đó phải là **Active**.

### 4. Giai đoạn 3: Kiểm tra và Preview trên Web Client

Bây giờ, ứng dụng React của bạn đã sẵn sàng để hiển thị.

1.  Đăng nhập vào **SBO Web Client** bằng Database bạn vừa gán Extension.
2.  Thông thường, ứng dụng mới sẽ xuất hiện ở mục **Extensions** hoặc trong nhóm chức năng mà bạn đã định nghĩa trong file `app-config.json` (nếu có) khi đóng gói.
3.  Nếu không thấy tile (ô chức năng) trên màn hình chính, hãy nhấn vào biểu tượng **Me Area** (hình người) -> **App Finder**. Tìm tên ứng dụng của bạn và nhấn biểu tượng "ghim" để đưa nó ra màn hình chính.

### 5. Giải pháp "Preview" nhanh cho Developer (Best Practice)

Nếu bạn đang trong quá trình phát triển (coding) và không muốn mỗi lần sửa code lại phải đóng gói `.mtar` rồi Upload/Assign lại (rất mất thời gian), bạn nên sử dụng **SAP Business One Web Client VS Code Extension**:

- **Hot Reload:** Công cụ này cho phép bạn kết nối trực tiếp từ VS Code đến môi trường Web Client của SAP.
- **Preview Mode:** Bạn có thể chạy lệnh `npm start` hoặc sử dụng tính năng **Preview** của extension trong VS Code để xem thay đổi ngay lập tức trên trình duyệt mà không cần đóng gói.
- **Debug:** Bạn có thể đặt breakpoint trực tiếp trên code React để kiểm tra logic giống như làm ứng dụng web thông thường.

**Lưu ý quan trọng về hiệu năng và bảo mật:**

- Đảm bảo rằng các Service Layer API mà ứng dụng React của bạn gọi tới đã được cấu hình CORS nếu bạn chạy preview từ localhost.
- File `.mtar` sau khi gán sẽ được Web Client host. Nếu bạn muốn thay đổi giao diện (CSS/Layout), hãy đảm bảo đã clear cache trình duyệt sau mỗi lần cập nhật bản Extension mới.

Hy vọng hướng dẫn này giúp bạn nhanh chóng thấy được thành quả dự án React của mình trên giao diện SAP Business One!
