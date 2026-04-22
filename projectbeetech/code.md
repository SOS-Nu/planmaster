giải thích code
Đoạn mã bạn cung cấp bao gồm hai phần: một câu lệnh **SQL (HANA/SQL Server)** để tạo View và một đoạn mã **C# (LINQ)** để xử lý dữ liệu trong ứng dụng. Đây là cấu trúc thường thấy khi làm việc với hệ thống **SAP Business One**.

Dưới đây là giải thích chi tiết cho từng phần:

---

## 1. Giải thích SQL: `CREATE OR REPLACE VIEW "VW_ITEM_PROPERTIES"`

Mục đích của View này là chuyển đổi dữ liệu "Item Properties" (Thuộc tính mặt hàng) từ dạng cột (64 cột `QryGroup`) sang dạng danh sách văn bản được phân tách bằng dấu phẩy.

### Cơ chế hoạt động:

- **Bảng OITM:** Chứa thông tin mặt hàng. Trong SAP B1, các thuộc tính (Properties) được lưu trữ trong 64 cột kiểu 'Y/N' từ `QryGroup1` đến `QryGroup64`.
- **Bảng OITG:** Chứa tên hiển thị của các thuộc tính này (`ItmsGrpNam`). Cột `ItmsTypCod` tương ứng với số thứ tự của thuộc tính (1 đến 64).
- **Cú pháp `UNION ALL`:**
  - Truy vấn lấy từng thuộc tính một. Ví dụ: Nếu thuộc tính số 1 (`QryGroup1`) của một mặt hàng là 'Y', nó sẽ kết nối với bảng `OITG` tại dòng có mã là 1 để lấy tên thuộc tính đó.
  - Việc lặp lại 64 lần giúp "phẳng hóa" (unpivot) dữ liệu từ cột thành các dòng riêng biệt.
- **Hàm `STRING_AGG`:**
  - Sau khi đã gom được tất cả các tên thuộc tính vào các dòng riêng lẻ nhờ khối `UNION ALL`, hàm này sẽ gộp chúng lại thành một chuỗi duy nhất cho mỗi `ItemCode`.
  - Ví dụ: Thay vì có 3 dòng cho mặt hàng A là "Hàng dễ vỡ", "Hàng cao cấp", "Hàng nhập khẩu", nó sẽ gộp thành: `"Hàng dễ vỡ, Hàng cao cấp, Hàng nhập khẩu"`.

---

## 2. Giải thích C#: `ToLookup` và Gán Details

Đoạn mã này dùng để ánh xạ (map) dữ liệu từ danh sách "Chi tiết" (`detail`) vào danh sách "Đầu mục" (`header`) dựa trên mã mặt hàng.

### Cú pháp chi tiết:

#### `var detailLookup = detail.ToLookup(x => x.ItemCode);`

- **`ToLookup`**: Tạo ra một cấu trúc dữ liệu giống như một cuốn từ điển (`Dictionary`), nhưng một "Key" (khóa) có thể chứa một **danh sách** các giá trị.
- **`x => x.ItemCode`**: Dùng `ItemCode` làm khóa để tra cứu.
- **Tại sao dùng Lookup?** Hiệu suất cao hơn nhiều so với việc dùng `.Where()` bên trong vòng lặp. Nó phân loại sẵn toàn bộ `detail` vào các nhóm theo mã hàng chỉ trong một lần duyệt.

#### `foreach (var h in header) { ... }`

- Vòng lặp duyệt qua từng đối tượng trong danh sách `header`.

#### `h.Details = detailLookup[h.ItemCode].ToList();`

- **`detailLookup[h.ItemCode]`**: Truy xuất nhanh tất cả các dòng chi tiết có mã `ItemCode` tương ứng với header hiện tại.
- **`.ToList()`**: Chuyển đổi tập hợp kết quả tìm được thành một `List` và gán vào thuộc tính `Details` của đối tượng header.

---

## Tóm tắt quy trình

1.  **SQL** xử lý logic nghiệp vụ phức tạp của SAP B1 (gom 64 cột thuộc tính thành 1 chuỗi văn bản dễ đọc).
2.  **C#** lấy dữ liệu từ View đó (hoặc các bảng liên quan) và tổ chức lại theo cấu trúc Cha-Con (Header-Detail) để hiển thị lên giao diện hoặc xử lý tiếp.

**Lưu ý nhỏ:** Nếu bạn đang dùng SQL Server đời cũ (trước 2017) không có `STRING_AGG`, đoạn SQL trên sẽ báo lỗi. Tuy nhiên, với SAP HANA hoặc SQL 2017 trở lên thì đây là cách làm chuẩn và gọn nhất.

```csharp
[DataContract(Namespace = "")]
public class CustomerDetail
        {

        public string CustomerCode { get; set; }

            [DataMember(Name = "ContactPerson")]
        public string ContactPerson { get; set; }

            [DataMember(Name = "Position")]
        public string Position { get; set; }

            [DataMember(Name = "Address")]
        public string Address { get; set; }

            [DataMember(Name = "Telephone")]
        public string Telephone { get; set; }

            [DataMember(Name = "MobilePhone")]
        public string MobilePhone { get; set; }
        }
```

chỉ cần bỏ datamember là ở ngoài api sẽ ko còn nữa
