dms lưu master data hay mình đẩy qua mỗi api
lưu delivery draft
wms dms
delivery draft 2 người cùng add vào ko trừ tồn đc
xung đột lô bắt notifi
item , kho , đơn hàng
markto so ko bi bị đụng chủ yếu là mark to order
markto stock conflict,
vẫn cho chọn ở dms, api truyền vào phải đủ parameter coi được nhiều item lấy dược nhiều item, đi từ so sẽ ko bị xung đột
kho lấy số lô

Chào bạn, dựa trên các tài liệu mapping giữa SAP Business One (SAP B1) và hệ thống DMS của dự án GLC (Glandcore) mà bạn đã cung cấp, tôi sẽ giải thích chi tiết về luồng nghiệp vụ, các khái niệm và cấu trúc dữ liệu để bạn có cái nhìn tổng quan và chính xác nhất.

### 1. Giải thích các khái niệm cơ bản

- **DMS (Distribution Management System):** Hệ thống quản lý kênh phân phối. Đối với dự án này, DMS là nơi nhân viên thị trường (Sales Rep) thực hiện các nghiệp vụ như: xem danh mục hàng hóa, tạo báo giá (SQ), đơn hàng (SO), quản lý khách hàng và yêu cầu trả hàng. DMS sẽ đóng vai trò "front-end" cho đội ngũ kinh doanh, sau đó đẩy dữ liệu về "back-end" là SAP B1.
- **ERP (SAP Business One):** Hệ thống quản trị nguồn lực doanh nghiệp, đóng vai trò là "Single Source of Truth" (nguồn dữ liệu gốc). SAP lưu trữ toàn bộ Master Data (Sản phẩm, Khách hàng, Giá, Kho) và ghi nhận kết quả tài chính, kho vận từ các giao dịch của DMS.
- **WMS (Warehouse Management System):** Hệ thống quản lý kho. Trong ngữ cảnh tài liệu này, nghiệp vụ kho liên quan đến việc chọn lô (Batch/Lot) và vị trí để chuẩn bị hàng cho các phiếu **Delivery**.
- **Delivery Draft (Phiếu giao hàng nháp):** Đây là một khái niệm quan trọng trong SAP B1. Khi DMS đẩy một yêu cầu giao hàng sang SAP, nó không tạo ra một phiếu Delivery chính thức (làm trừ kho ngay lập tức) mà tạo dưới dạng **Draft**. Điều này cho phép kế toán hoặc thủ kho tại SAP kiểm tra lại thông tin, phân bổ số Lô/Serial thực tế trước khi nhấn "Add" để trở thành phiếu Delivery chính thức (ODLN).

---

### 2. Luồng nghiệp vụ (Business Flow) giữa SAP và DMS

Dựa trên checklist mapping, luồng dữ liệu được chia làm 2 chiều:

#### Chiều 1: SAP B1 → DMS (Đồng bộ Master Data & Status)

Để DMS hoạt động, nó cần lấy dữ liệu nền tảng từ SAP:

1.  **Master Data:** Đồng bộ Mặt hàng (Item), Khách hàng (Customer), Chi nhánh (Branch), Thuế (Tax), Nhân viên (Sales Empl), Kho (Warehouse).
    - _Lưu ý:_ Chỉ lấy những bản ghi có trạng thái `Active` hoặc `validFor = 'Y'`.
2.  **Inventory:** DMS lấy tồn kho thực tế và tồn kho theo Lô (Batch) từ SAP để nhân viên biết hàng nào còn để bán.
3.  **Status Sync:** Sau khi DMS đẩy đơn hàng sang SAP, SAP sẽ phản hồi trạng thái (Ví dụ: Đơn hàng đã được đóng - Closed, hoặc đã bị hủy - Canceled).

#### Chiều 2: DMS → SAP B1 (Đẩy giao dịch)

Đây là luồng nghiệp vụ phát sinh từ thị trường:

1.  **Sales Quotation (SQ):** Nhân viên tạo báo giá trên DMS -> Đẩy sang SAP (Bảng OQUT).
2.  **Sales Order (SO):** Khi khách chốt, DMS đẩy Đơn đặt hàng sang SAP (Bảng ORDR).
3.  **Delivery Draft:** Khi bắt đầu quy trình giao hàng, DMS đẩy dữ liệu sang SAP dưới dạng Draft (Bảng ODRF) để chờ xử lý kho.
4.  **Return Request:** Khi khách muốn trả hàng, DMS tạo phiếu yêu cầu trả hàng sang SAP (Bảng ORRR).

---

### 3. Cấu trúc các bảng SAP cần nắm vững (Data Architecture)

Trong SAP B1, dữ liệu thường chia làm 2 phần: **Header** (Thông tin chung của phiếu) và **Lines** (Thông tin chi tiết từng mặt hàng). Bạn cần nắm các cặp bảng sau:

| Nghiệp vụ            | Bảng Header | Bảng Lines (Details) | Ghi chú                                                                        |
| :------------------- | :---------- | :------------------- | :----------------------------------------------------------------------------- |
| **Mặt hàng (Item)**  | `OITM`      | -                    | Chứa mã hàng, tên hàng, nhóm hàng.                                             |
| **Khách hàng (BP)**  | `OCRD`      | `CRD1` (Địa chỉ)     | Chứa mã khách, tên, hạn mức công nợ.                                           |
| **Báo giá (SQ)**     | `OQUT`      | `QUT1`               | `ObjType = 23`                                                                 |
| **Đơn hàng (SO)**    | `ORDR`      | `RDR1`               | `ObjType = 17`                                                                 |
| **Giao hàng nháp**   | `ODRF`      | `DRF1`               | **Quan trọng:** Phải check `ObjType = 15` để phân biệt với các loại nháp khác. |
| **Yêu cầu trả hàng** | `ORRR`      | `RRR1`               | `ObjType = 234000031`                                                          |
| **Tồn kho theo Lô**  | `OBTN`      | `RBTN`               | Dùng để lấy `DistNumber` (Số lô) và hạn sử dụng.                               |

---

| `OITL`,`ITL1`| Mỗi khi bạn tạo một chứng từ có xuất/nhập hàng (như Delivery, Goods Receipt, Return), SAP sẽ ghi một dòng vào ITL để đánh dấu rằng "Dòng mặt hàng X trên chứng từ Y có sử dụng Lô/Serial".|

---

### 4. Các điểm quan trọng để lấy và đẩy dữ liệu chính xác

Để đảm bảo hệ thống vận hành chuyên nghiệp theo tiêu chuẩn "Clean Architecture" và đảm bảo hiệu năng, bạn cần lưu ý:

- **Sử dụng UDF (User Defined Fields):** Trong tài liệu có nhắc đến trường `U_DMSNumber`. Đây là trường tùy chỉnh trên SAP để lưu ID của đơn hàng từ DMS.
  - _Best Practice:_ Luôn kiểm tra `U_DMSNumber` trước khi insert để tránh trùng lặp dữ liệu (Idempotency).
- **Điều kiện lọc (Filtering):**
  - Mặt hàng: `OITM.validFor = 'Y'` và `OITM.U_DMS_Intergration = 'Y'`.
  - Khách hàng: `OCRD.validFor = 'Y'`.
  - Chi nhánh: `OBPL.Disabled = 'N'`.
- **Xử lý Batch (Số lô):** Khi lấy tồn kho (D118), bạn cần kết nối bảng `OBTN` (Lô) với `OIBT` hoặc `OSRQ` để biết số lượng tồn thực tế của từng lô tại từng kho (`WhsCode`).
- **Cơ chế cập nhật trạng thái:**
  - Khi SO được chuyển thành Delivery thành công trong SAP, trường `DocStatus` của `ORDR` sẽ chuyển từ `O` (Open) sang `C` (Closed). DMS cần dựa vào API lấy status này để cập nhật lại trạng thái đơn hàng cho người dùng.

### 5. Gợi ý về mặt kỹ thuật (Dev Perspective)

1.  **Tính toàn vẹn dữ liệu:** Khi đẩy các phiếu (POST), bạn phải đảm bảo đẩy đủ cả Header và Details trong một Transaction.
2.  **Performance:** Khi lấy dữ liệu Master Data (GET), nên sử dụng tham số `$filter` theo thời gian (ví dụ: `UpdateDate`) để chỉ lấy những bản ghi mới thay đổi (Delta Sync), tránh lấy lại toàn bộ database gây chậm hệ thống.
3.  **Mapping Tax Code:** Lưu ý bảng `OVTG`. Thuế suất trong SAP có thể thay đổi theo thời điểm, cần mapping đúng mã thuế từ DMS vào trường `VatGroup` trong các dòng chi tiết của đơn hàng.

Nếu bạn đang bắt tay vào viết code, lời khuyên là hãy bắt đầu từ việc xây dựng các **Data Transfer Objects (DTOs)** chuẩn dựa trên các API Field trong file excel, sau đó viết các Service layer để handle việc mapping giữa các bảng SAP (như `OCRD`, `OITM`) sang các Model của DMS.
Dưới đây là cách hiểu ngắn gọn nhưng đúng bản chất về toàn bộ bộ mapping này.

## 1) Bức tranh tổng thể: đây là flow tích hợp gì?

Đây là **flow tích hợp giữa DMS và SAP Business One thông qua API** cho nghiệp vụ bán hàng.

- **SAP B1**: hệ thống ERP, là nơi giữ dữ liệu chuẩn và hạch toán chính
- **DMS**: hệ thống hỗ trợ bán hàng/phân phối ngoài thị trường
- **API**: lớp trung gian để đồng bộ dữ liệu giữa 2 hệ thống

Nhìn theo sơ đồ:

- **SAP B1 → DMS**: đẩy dữ liệu master và các danh mục tham chiếu để DMS dùng
- **DMS → SAP B1**: đẩy chứng từ nghiệp vụ bán hàng phát sinh từ đội sale/thị trường lên SAP
- Sau đó **SAP B1 → DMS** lại trả trạng thái chứng từ để DMS theo dõi

Nói dễ hiểu:

1. SAP giữ danh mục chuẩn: hàng hóa, khách hàng, kho, nhân viên, thuế, điều khoản thanh toán...
2. DMS lấy các danh mục đó về để người dùng chọn đúng dữ liệu
3. Người dùng trên DMS tạo báo giá / đơn hàng / giao hàng nháp / yêu cầu trả hàng
4. DMS đẩy sang SAP B1
5. SAP B1 xử lý và trả trạng thái lại cho DMS

---

## 2) Một số khái niệm cơ bản cần nắm

## DMS là gì?

**DMS = Distribution Management System**
Hệ thống quản lý phân phối/bán hàng.

Thường phục vụ:

- sale ngoài thị trường
- quản lý khách hàng, tuyến bán hàng
- ghi nhận đơn hàng
- theo dõi giao hàng, trả hàng
- xem công nợ, tồn kho, danh mục

Trong flow này, DMS là nơi người dùng thao tác nghiệp vụ bán hàng hằng ngày.

## WMS là gì?

**WMS = Warehouse Management System**
Hệ thống quản lý kho chuyên sâu.

Thường quản lý:

- nhập/xuất/chuyển kho
- vị trí/bin
- lot/batch/serial
- picking/packing
- tồn kho chi tiết theo vị trí

Trong tài liệu bạn gửi **không thấy WMS là hệ trung tâm**. Ở đây chủ yếu là:

- **DMS** cho bán hàng
- **SAP B1** cho ERP
- có xử lý tồn kho, batch/lot nhưng đang bám vào SAP B1

Tức là hiện tại nghiệp vụ kho trong mapping này chủ yếu đang lấy từ **SAP B1 tables**, chưa phải mô hình WMS riêng.

## Master Data là gì?

Là **danh mục nền tảng** ít thay đổi, dùng chung cho giao dịch:

- Item
- Customer
- Sales Employee
- Owner
- Warehouse
- Branch
- Tax
- Contact Person
- Currency
- Shipping Type
- Payment Terms
- Batch

Nếu master data sai thì tất cả chứng từ bên dưới sẽ sai theo.

## Transaction Data là gì?

Là **dữ liệu phát sinh theo nghiệp vụ**:

- Sales Quotation
- Sales Order
- Delivery Draft
- Return Request
- các status của chúng

## Delivery Draft là gì?

Trong SAP B1:

- **Delivery** = phiếu giao hàng thực tế
- **Delivery Draft** = **phiếu giao hàng nháp**, chưa phải chứng từ giao hàng chính thức

Trong bộ mapping này, Delivery Draft là:

- chứng từ DMS gửi sang SAP
- lưu vào **ODRF / DRF1**
- với điều kiện **ObjType = 15** để biểu diễn chứng từ liên quan nghiệp vụ giao hàng

Hiểu nghiệp vụ:

- Sale/DMS muốn chuẩn bị giao hàng
- chưa chắc đã xuất kho chính thức ngay
- nên tạo **draft** trước
- sau khi kiểm tra tồn, batch, số lượng, thông tin giao nhận... thì mới có thể chuyển thành Delivery chính thức

Draft rất hữu ích khi:

- cần kiểm tra batch/lot
- cần duyệt trước
- cần tránh tạo chứng từ thật quá sớm

---

## 3) Flow nghiệp vụ end-to-end của bộ này

## A. SAP B1 → DMS: đồng bộ dữ liệu nền

DMS sẽ GET từ SAP các nhóm dữ liệu sau:

### 1. Danh mục hàng hóa

API:

- D101 Item Master Data

Để DMS biết:

- mã hàng
- tên hàng
- nhóm hàng
- NSX
- dạng bào chế
- điều kiện bảo quản
- thuế
- kho mặc định
- đơn vị tính
- tồn kho theo kho
- có quản lý batch hay không

### 2. Danh mục khách hàng

API:

- D102 Customer Data
- D124 Ship To
- D125 Bill To

Để DMS biết:

- mã khách hàng
- tên KH
- MST
- tên khác
- chi nhánh khách hàng liên quan
- điều khoản thanh toán
- người liên hệ
- địa chỉ giao hàng
- địa chỉ hóa đơn

### 3. Công nợ khách hàng

API:

- D103 Customer Receivable

Để sale/DMS xem:

- công nợ hiện tại của khách hàng
- theo chi nhánh
- đến ngày hiện tại

### 4. Các danh mục phục vụ bán hàng

API:

- D107 Sales Employee
- D108 Owner
- D109 Warehouse
- D110 Branch
- D111 Tax
- D112 Contact Person
- D113 Currency
- D114 Shipping Type
- D115 Payment Terms
- D118 Tồn kho có/không quản lý Batch/Lot
- D122 Delivery Open
- D123 AR Invoice Open

Mục đích:
khi tạo đơn, DMS có đủ dữ liệu tham chiếu để chọn đúng.

---

## B. DMS → SAP B1: đẩy chứng từ bán hàng

### 1. Báo giá

API:

- D104 Sales Quotation

DMS tạo báo giá rồi POST sang SAP vào:

- header: **OQUT**
- line: **QUT1**

Sau đó DMS có thể lấy trạng thái báo giá:

- D105 Sales Quotation - Status

### 2. Đơn bán hàng

API:

- D106 Sales Order

DMS tạo đơn bán hàng rồi POST sang SAP vào:

- header: **ORDR**
- line: **RDR1**

DMS còn lấy thêm:

- status SO
- sales employee
- owner
- warehouse
- tax
- shipping type
- payment terms
- currency...

### 3. Phiếu giao hàng nháp

API:

- D117 Delivery Draft

DMS đẩy sang SAP vào:

- header: **ODRF**
- line: **DRF1**
- dùng **ObjType = 15**

Về nghiệp vụ:

- đây là bản nháp giao hàng tương ứng theo đơn bán hàng đã đồng bộ
- thường dùng để chuẩn bị giao hàng
- đặc biệt khi cần gắn batch/lot, kiểm tra tồn, thông tin giao nhận

Sau đó DMS lấy trạng thái giao hàng:

- D119 Delivery - Status

### 4. Đơn trả hàng bán

API:

- D120 Return Request

DMS gửi yêu cầu trả hàng sang SAP

Và lấy trạng thái trả hàng:

- D121 Return - Status

---

## C. Status trả về từ SAP B1 → DMS

Các trạng thái chính:

### Sales Quotation

- Open
- Closed
- Canceled
- có câu hỏi thêm về **Edited**

### Sales Order

Theo tài liệu:

- Open / Canceled / Closed
- DMS tự quản lý một phần logic trạng thái

### Delivery

- DMS lấy trạng thái giao hàng từ SAP

### Return

- DMS lấy trạng thái phiếu trả hàng từ SAP

---

## 4) Hiểu nghiệp vụ từng nhóm cho đúng

## Nhóm 1: Master Data

Đây là dữ liệu chuẩn, phải đồng bộ trước giao dịch.

### Item

Là danh mục hàng.
Có nhiều field nghiệp vụ đặc thù:

- U_DMS_Integration = Y mới lấy
- validFor = Y mới lấy
- batch management
- tax group
- shipping type
- manufacturer
- origin
- warehouse default
- procurement method

Ý nghĩa:
DMS chỉ được bán những item đủ điều kiện tích hợp.

### Customer

Là khách hàng bán hàng.
Điều kiện:

- OCRD.validFor = Y

Có thông tin:

- payment term
- branch
- group khách hàng
- currency
- contact person
- ship-to / bill-to

### Customer Receivable

Là số dư công nợ.
Dùng để:

- kiểm tra khách có còn công nợ lớn không
- hỗ trợ quyết định bán hàng / giao hàng

## Nhóm 2: Sales Transaction

### Sales Quotation

Báo giá.
Chưa ràng buộc xuất hàng.
Thường là bước đầu tiên với khách.

### Sales Order

Đơn bán hàng.
Đây là cam kết bán, dùng để:

- giữ nhu cầu
- làm cơ sở giao hàng
- làm cơ sở xuất hóa đơn

### Delivery Draft

Chuẩn bị giao hàng nhưng chưa chính thức.
Thường sinh từ Sales Order đã có.

### Return Request

Yêu cầu trả hàng.
Là nghiệp vụ ngược chiều bán ra.

---

## 5) Các điểm nghiệp vụ quan trọng trong file này

## a) Branch là bắt buộc

Cả báo giá và sales order đều ghi rõ:

- bắt buộc chọn **Branch**

Điều này quan trọng vì branch ảnh hưởng:

- dữ liệu báo cáo
- công nợ
- kho
- thuế
- hạch toán
- quyền người dùng

## b) DMSNumber phải không trùng

Nhiều chỗ ghi:

- **U_DMSNumber không được trùng**

Đây là khóa đối chiếu rất quan trọng giữa DMS và SAP.

Nên coi nó như:

- external document number
- idempotency key
- khóa mapping liên hệ chứng từ 2 hệ thống

## c) Có liên kết line number

Các chứng từ đều nhắc:

- liên kết **Line Number**
- chứng từ liên quan

Điều này cực quan trọng nếu:

- 1 đơn có nhiều dòng
- giao hàng một phần
- trả hàng theo dòng
- trace batch/lot theo dòng

## d) Có xử lý item đặc thù

Sales Order / Delivery Draft có các field:

- HangTang
- TaxOnly
- LoaiHang (MTO/MTS)
- Batch
- serial
- DeliveryDate / DueDate theo dòng

Nghĩa là không chỉ bán hàng đơn giản, mà còn có:

- hàng biếu tặng
- dòng chỉ thuế
- quản lý lô
- ngày giao riêng cho từng dòng

---

## 6) Nắm khái niệm các bảng SAP B1 nào để hiểu và lấy data cho đúng

Tôi chia theo mức độ ưu tiên.

## A. Nhóm bảng phải nắm đầu tiên

### 1. Danh mục hàng

- **OITM**: item master header
- **OITB**: item group
- **OITW**: item theo kho
- **OMRC**: manufacturer
- **OSHP**: shipping type
- **OVTG**: tax code
- **OWHS**: warehouse
- **ITM10**: origin / country liên quan item
- **OCRY**: country

Ngoài ra có UDT/custom tables:

- **@DS_TIEUCHUAN**
- **@BAOCHE**
- **@DKBQ**
- **@DKVC**

Nếu bạn muốn lấy đúng item cho DMS thì gần như chắc chắn phải join nhóm này.

### 2. Danh mục khách hàng

- **OCRD**: business partner
- **CRD8**: branch linked with BP / địa chỉ/nhánh liên quan
- **OCRG**: customer group
- **OCTG**: payment terms
- **OCPR**: contact person
- **OBPL**: branch

### 3. Công nợ

- **JDT1**: journal entry lines
- **OCRD**: để xác định BP khách hàng

### 4. Bán hàng

- **OQUT / QUT1**: sales quotation header/line
- **ORDR / RDR1**: sales order header/line
- **ODRF / DRF1**: draft header/line
- nếu sau này cần delivery chính thức thì thường là **ODLN / DLN1**
- nếu cần return request / return / invoice thì sẽ phát sinh thêm bảng tương ứng

### 5. Danh mục tham chiếu bán hàng

- **OSLP**: sales employee
- **OHEM**: employee / owner
- **OWHS**: warehouse
- **OBPL**: branch
- **OVTG**: tax
- **OCRN**: currency
- **OSHP**: shipping type
- **OCTG**: payment terms

### 6. Batch/Lot

- **OBTN**: batch master
- **RBTN**: batch quantities / relation theo item-kho như tài liệu đang dùng

---

## B. Nhóm bảng bạn phải hiểu theo vai trò

## Header table và line table

Trong SAP B1, đa số chứng từ có 2 lớp:

- **Header table**: thông tin chung của chứng từ
- **Line table**: thông tin từng dòng hàng

Ví dụ:

- OQUT = header báo giá

- QUT1 = dòng báo giá

- ORDR = header đơn hàng

- RDR1 = dòng đơn hàng

- ODRF = header draft

- DRF1 = dòng draft

Khi lấy data đúng, luôn phải xác định:

- đang lấy ở mức header hay line
- field nào thuộc header, field nào thuộc line
- join qua DocEntry/DocNum/U_LineNum như thế nào

## Master table và reference table

Ví dụ item:

- OITM là bảng chính
- OITB, OMRC, OSHP, OVTG là bảng tham chiếu

Tức là:

- OITM chứa mã
- bảng tham chiếu chứa tên/mô tả

Ví dụ customer:

- OCRD là bảng chính
- OCRG, OCTG, OCPR, OBPL là bảng tham chiếu

---

## 7) Cách đọc mapping của bộ này

Mỗi dòng mapping có các cột chính:

- **API Field**: field trả ra / nhận vào của API
- **SAP Field Name**: tên business field tương ứng
- **SAP Field**: field thật trong bảng SAP
- **SAP Table**: bảng SAP chứa field
- **Data Type**: kiểu dữ liệu
- **Picklist Value**: danh sách giá trị hợp lệ
- **Required**: bắt buộc hay không
- **Notes**: logic join, điều kiện lọc, giải thích

Khi lấy data đúng, bạn phải đọc theo thứ tự:

1. API Field là gì
2. Nó nằm ở bảng nào
3. Có cần join bảng khác không
4. Có điều kiện lọc riêng không
5. Là field bắt buộc hay không
6. Có là custom field U\_... không

Ví dụ:

- `ItemGroupName` không nằm ở OITM mà phải join sang **OITB**
- `ManufacturerName` phải join sang **OMRC**
- `BranchName` của customer phải qua **CRD8 -> OBPL**
- `PaymentTermName` phải join **OCRD.GroupNum -> OCTG**
- `OwnerName` phải join **OHEM**
- `ShippingTypeName` phải join **OSHP**

---

## 8) Những điều kiện lọc rất dễ sai nếu không để ý

Bạn nên chốt các rule này trước khi query.

## Item

Chỉ lấy item:

- `U_DMS_Integration = 'Y'`
- `OITM.validFor = 'Y'`

## Customer

Chỉ lấy customer:

- `OCRD.validFor = 'Y'`
- thường thêm `OCRD.CardType = 'C'` nếu muốn chỉ lấy khách hàng

## Sales Employee

Chỉ lấy:

- `OSLP.Active = 'Y'`

## Owner / Employee

Chỉ lấy:

- `OHEM.Active = 'Y'`

## Warehouse

Chỉ lấy:

- `OWHS.Active = 'Y'`

## Branch

Chỉ lấy:

- `OBPL.Disabled = 'N'`

## Tax

Chỉ lấy:

- `OVTG.Inactive = 'N'`

## Contact Person

Chỉ lấy:

- `OCPR.Active = 'Y'`

## Shipping Type

Chỉ lấy:

- `OSHP.Active = 'Y'`

## Delivery Draft

Chỉ lấy / ghi nhận draft:

- ở **ODRF / DRF1**
- với **ObjType = 15**

## Customer Receivable

Theo mapping:

- lấy theo chi nhánh
- đến ngày hiện tại
- không lấy khách nội bộ
- chỉ lấy tài khoản 131

---

## 9) Delivery Draft trong flow đứng ở đâu?

Flow nghiệp vụ thường sẽ là:

### Trường hợp đầy đủ

1. SAP đồng bộ master data sang DMS
2. DMS tạo **Sales Quotation**
3. DMS/SAP chuyển thành **Sales Order**
4. Từ Sales Order, DMS tạo **Delivery Draft**
5. SAP kiểm tra tồn, batch, thông tin giao nhận
6. Sau khi duyệt/chốt thì mới thành **Delivery chính thức**
7. Sau đó mới có thể xuất hóa đơn / thu tiền / theo dõi công nợ

### Trường hợp đơn giản hơn

1. DMS lấy master từ SAP
2. DMS tạo trực tiếp **Sales Order**
3. DMS tạo **Delivery Draft**
4. SAP hoàn tất giao hàng

Nên hiểu:

- **Sales Order** là cam kết bán
- **Delivery Draft** là chuẩn bị giao
- **Delivery** là giao chính thức

---

## 10) Cần nắm bảng nào trước để “đọc được hệ thống”

Nếu bạn mới vào, tôi khuyên học theo thứ tự này.

## Mức 1: đủ để hiểu 70%

- OITM
- OCRD
- OSLP
- OHEM
- OWHS
- OBPL
- OVTG
- OCTG
- OSHP
- OCPR
- OCRN
- OQUT / QUT1
- ORDR / RDR1
- ODRF / DRF1
- JDT1
- OBTN

## Mức 2: đủ để query chuẩn hơn

- OITB
- OITW
- OMRC
- OCRG
- CRD8
- ITM10
- OCRY
- RBTN
- các bảng custom: `@DS_TIEUCHUAN`, `@BAOCHE`, `@DKBQ`, `@DKVC`

## Mức 3: để lần ngược chứng từ đầy đủ

- các bảng delivery/invoice/return thật trong SAP B1
- bảng liên kết base document / target document
- bảng journal / AR invoice liên quan công nợ

---

## 11) Những lỗi rất hay gặp khi lấy data

## a) Lấy nhầm tên field “business” với field thật

Ví dụ mapping ghi:

- SAP Field Name
- SAP Field
- SAP Table

Phải bám **SAP Field + SAP Table**, không chỉ nhìn tên hiển thị.

## b) Lấy thiếu điều kiện active/valid

Ví dụ:

- item không lọc `validFor = Y`
- customer không lọc `CardType = C`
- branch không lọc `Disabled = 'N'`

Kết quả là DMS nhận cả dữ liệu rác/ngưng dùng.

## c) Join sai bảng tên thay vì mã

Phải ưu tiên join theo:

- code/id/key
- không join bằng name

## d) Quên phân biệt header và line

Nếu bạn join header với nhiều line mà không để ý, dữ liệu sẽ bị nhân bản.

## e) Không phân biệt draft và chứng từ thật

- `ODRF / DRF1` là draft
- không phải delivery chính thức

## f) Không quản lý uniqueness của U_DMSNumber

Điều này sẽ gây duplicate chứng từ giữa DMS và SAP.

---

## 12) Tóm tắt cực ngắn để bạn nhớ

### DMS là gì?

Hệ thống bán hàng/phân phối cho đội sale.

### WMS là gì?

Hệ thống quản lý kho chuyên sâu. Trong tài liệu này chưa phải hệ trung tâm.

### Flow chính là gì?

- SAP → DMS: đồng bộ danh mục và dữ liệu tham chiếu
- DMS → SAP: gửi báo giá, đơn hàng, giao hàng nháp, trả hàng
- SAP → DMS: trả trạng thái và dữ liệu theo dõi

### Delivery Draft là gì?

Phiếu giao hàng nháp trong SAP B1, lưu ở:

- ODRF
- DRF1
- ObjType = 15

### Cần nắm bảng nào?

Ưu tiên:

- OITM, OCRD, OSLP, OHEM, OWHS, OBPL, OVTG, OCTG, OSHP, OCPR, OCRN
- OQUT/QUT1, ORDR/RDR1, ODRF/DRF1
- JDT1
- OBTN

### Cần lọc gì?

- active / valid / disabled
- CardType = C cho customer
- U_DMS_Integration = Y cho item
- ObjType = 15 cho Delivery Draft

---

Nếu bạn muốn, ở tin nhắn tiếp theo tôi có thể làm tiếp cho bạn một bản **“data dictionary thực chiến”**: mỗi API sẽ có **bảng nguồn, điều kiện lọc, khóa join, lưu ý dễ sai, và ví dụ SQL skeleton** để bạn lấy dữ liệu đúng ngay.
Các đặc điểm chính của OACT:
Cấu trúc phân cấp (Hierarchy): SAP quản lý tài khoản theo dạng cây (Tree structure).

Level 1: Các nhóm tài khoản lớn (Assets, Liabilities, Equity, Revenue, Expenditure...).

Level 2-4: Các tài khoản tổng hợp (Title Accounts).

Level 5 (thường là cuối): Các tài khoản chi tiết có thể hạch toán (Active/Postable Accounts).

Trường dữ liệu quan trọng:

AcctCode: Mã tài khoản (Internal Key).

AcctName: Tên tài khoản.

Postable: Xác định tài khoản có cho phép hạch toán trực tiếp hay không (Y/N).

LocCode: Mã tài khoản theo hệ thống kế toán địa phương (thường dùng để mapping với thông tư 200 hoặc 133 tại Việt Nam).

CurrTotal: Số dư hiện tại của tài khoản.
