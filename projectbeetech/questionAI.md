Bài này bản chất là **thiết kế integration SAP B1 → DMS**, nên không chỉ là viết store mà còn là **thiết kế flow đồng bộ + tối ưu query + tracking thay đổi**.

Mình đi thẳng vào thực tế triển khai nhé.

---

# 🧠 1. Tổng quan yêu cầu

Bạn cần:

- Lấy **Item Master Data + tồn kho**
- Điều kiện:
  - `OITM.U_DMS_Integration = 'Y'`
  - `OITM.validFor = 'Y'`

- Có:
  - Header (OITM + join nhiều bảng)
  - Details (OITW tồn kho theo kho)

- Đồng bộ:
  - **full**
  - **incremental (create/update)**

---

# 🧱 2. Nên chia mấy store?

👉 Chuẩn nhất: **3 store**

## ✅ (1) Store lấy danh sách item (Header)

```
sp_DMS_GetItems
```

## ✅ (2) Store lấy tồn kho (Details)

```
sp_DMS_GetItemStocks
```

## ✅ (3) Store master (gộp output JSON / paging / filter)

```
sp_DMS_SyncItems
```

---

# ⚙️ 3. Flow tổng thể

```
DMS call API
   ↓
API gọi sp_DMS_SyncItems
   ↓
sp_DMS_SyncItems gọi:
   - sp_DMS_GetItems
   - sp_DMS_GetItemStocks
   ↓
Merge data → trả JSON
```

---

# 🔁 4. Có cần tracking update không?

👉 CÓ (rất quan trọng)

Bạn nên dùng:

### Cách 1 (chuẩn SAP):

- `OITM.UpdateDate`
- `OITM.CreateDate`

### Cách 2 (xịn hơn):

- Trigger log vào bảng riêng

---

# 🧩 5. Store chi tiết

## 🟡 (1) Header – Item master

```sql
CREATE PROCEDURE sp_DMS_GetItems
    @FromDate DATE = NULL
AS
BEGIN
    SELECT
        T0.ItemCode,
        T0.ItemName,
        T0.ItmsGrpCod AS ItemGroupCode,
        T1.ItmsGrpNam AS ItemGroupName,

        T0.U_StandardList,
        SL.Name AS StandardListName,

        T0.U_DosageForm,
        DC.Name AS DosageFormName,

        T0.U_HSCode,
        T0.U_StorageCondition,
        SC.Name AS StorageConditionName,

        T0.U_HoatChat,
        T0.U_HamLuong,

        T0.U_DelCond,
        DC2.Name AS DelCondName,

        T0.U_ECK,
        T0.U_SGDK,
        T0.U_SoLuong,

        T0.FirmCode,
        M.FirmName,
        M.U_FullName,

        T0.ShipType,
        S.TrnspName,

        T0.ManBtchNum,
        T0.VatGroupSa,
        V.Rate,

        T0.DfltWH,
        W.WhsName,

        T0.LeadTime,
        T0.PrcrmntMtd,

        T0.UpdateDate,
        T0.CreateDate

    FROM OITM T0
    LEFT JOIN OITB T1 ON T0.ItmsGrpCod = T1.ItmsGrpCod
    LEFT JOIN [@DS_TIEUCHUAN] SL ON T0.U_StandardList = SL.Code
    LEFT JOIN [@BAOCHE] DC ON T0.U_DosageForm = DC.Code
    LEFT JOIN [@DKBQ] SC ON T0.U_StorageCondition = SC.Code
    LEFT JOIN [@DKVC] DC2 ON T0.U_DelCond = DC2.Code
    LEFT JOIN OMRC M ON T0.FirmCode = M.FirmCode
    LEFT JOIN OSHP S ON T0.ShipType = S.TrnspCode
    LEFT JOIN OVTG V ON T0.VatGroupSa = V.Code
    LEFT JOIN OWHS W ON T0.DfltWH = W.WhsCode

    WHERE
        T0.validFor = 'Y'
        AND T0.U_DMS_Integration = 'Y'
        AND (
            @FromDate IS NULL
            OR T0.UpdateDate >= @FromDate
            OR T0.CreateDate >= @FromDate
        )
END
```

---

## 🟢 (2) Tồn kho

```sql
CREATE PROCEDURE sp_DMS_GetItemStocks
    @FromDate DATE = NULL
AS
BEGIN
    SELECT
        T0.ItemCode,
        T0.WhsCode,
        W.WhsName,
        T0.OnHand

    FROM OITW T0
    INNER JOIN OITM I ON T0.ItemCode = I.ItemCode
    LEFT JOIN OWHS W ON T0.WhsCode = W.WhsCode

    WHERE
        I.validFor = 'Y'
        AND I.U_DMS_Integration = 'Y'
END
```

---

## 🔵 (3) Master store (trả JSON)

```sql
CREATE PROCEDURE sp_DMS_SyncItems
    @FromDate DATE = NULL
AS
BEGIN

    SELECT
        I.*,
        (
            SELECT
                S.WhsCode,
                S.WhsName,
                S.OnHand
            FROM OITW S
            WHERE S.ItemCode = I.ItemCode
            FOR JSON PATH
        ) AS Stocks

    FROM OPENQUERY([LOCAL], 'EXEC sp_DMS_GetItems') I

END
```

👉 Hoặc dùng temp table:

```sql
INSERT INTO #Items EXEC sp_DMS_GetItems @FromDate
INSERT INTO #Stocks EXEC sp_DMS_GetItemStocks @FromDate
```

---

# 🚀 6. Flow đồng bộ thực tế (production)

## Lần đầu (FULL SYNC)

```
@FromDate = NULL
```

## Các lần sau (INCREMENTAL)

```
@FromDate = lastSyncTime
```

---

# 🧠 7. Tối ưu cực quan trọng

## ❗ Index cần có

```
OITM:
- ItemCode (PK)
- UpdateDate
- U_DMS_Integration
- validFor

OITW:
- ItemCode
- WhsCode
```

---

## ❗ Nếu data lớn

👉 BẮT BUỘC paging

```sql
OFFSET @Page * @Size ROWS
FETCH NEXT @Size ROWS ONLY
```

---

# 🔥 8. Nâng cao (nếu làm xịn)

## ✔ Tracking riêng

Tạo bảng:

```sql
DMS_Sync_Log
- ItemCode
- LastSyncDate
- Action (Insert/Update)
```

---

## ✔ Hoặc dùng Trigger

```sql
AFTER UPDATE ON OITM
INSERT INTO DMS_ChangeLog
```

---

# ✅ Kết luận

👉 Bạn nên làm:

- **3 store**
- **1 flow API**
- **1 cơ chế incremental sync**

---

# Nếu bạn muốn

Mình có thể giúp bạn:

- Viết **API Node.js (Next.js)** gọi store này
- Format JSON đúng chuẩn DMS
- Hoặc thiết kế luôn **batch job cron sync**

Chỉ cần nói bạn đang dùng stack gì 👍
Có thể dùng, nhưng phải dùng **đúng ý nghĩa** của field đó.

# Trường hợp dùng được

Nếu `U_DMS_SyncDate` nghĩa là:

> **thời điểm item này đã được đồng bộ thành công sang DMS lần gần nhất**

thì bạn có thể dùng để xác định item nào **chưa sync** hoặc **cần sync lại**.

Ví dụ logic:

- item mới tạo, chưa có `U_DMS_SyncDate` → cần sync
- item có `UpdateDate > U_DMS_SyncDate` → cần sync lại
- item có `UpdateDate <= U_DMS_SyncDate` → chưa cần sync

Logic kiểu này khá hợp lý.

```sql
WHERE
    OITM.U_DMS_Integration = 'Y'
    AND OITM.validFor = 'Y'
    AND (
        OITM.U_DMS_SyncDate IS NULL
        OR OITM.UpdateDate > OITM.U_DMS_SyncDate
        OR OITM.CreateDate > OITM.U_DMS_SyncDate
    )
```

# Nhưng có một điểm rất quan trọng

Bạn phải phân biệt 2 loại thời gian:

## 1. `LastSyncTime` của job / API

Đây là:

- thời điểm lần chạy đồng bộ gần nhất của hệ thống
- thường lưu ở bảng log / config sync

Ví dụ:

- job chạy lúc 10:00
- lần sau lấy dữ liệu từ sau 10:00

## 2. `U_DMS_SyncDate` trên từng item

Đây là:

- thời điểm riêng của từng item đã sync thành công

Hai cái này **không hoàn toàn giống nhau**.

# Khi nào nên dùng `U_DMS_SyncDate`

Nên dùng khi bạn muốn biết:

- item nào đã sync rồi
- item nào chưa sync
- item nào update sau lần sync gần nhất của chính nó

Đây là cách khá tốt nếu bạn sync theo từng item.

# Khi nào không nên chỉ dựa hoàn toàn vào `U_DMS_SyncDate`

Nếu quy trình của bạn là:

- SAP chỉ có nhiệm vụ trả data
- DMS là bên gọi và quản lý lịch sync
- SAP không chắc đã update `U_DMS_SyncDate` ngay sau khi DMS nhận thành công

thì dùng riêng field này có thể rủi ro.

Ví dụ:

- SAP trả item A cho DMS
- DMS bị lỗi, chưa ghi nhận thành công
- nhưng SAP đã update `U_DMS_SyncDate`
- lần sau item A bị bỏ sót

Nên chỉ an toàn khi:

> `U_DMS_SyncDate` chỉ được update sau khi xác nhận sync thành công thật sự.

# Khuyến nghị cho case của bạn

## Nếu `U_DMS_SyncDate` đang được vận hành chuẩn

Thì dùng được, và nên dùng.

Logic:

- lấy item có `U_DMS_SyncDate` null
- hoặc `UpdateDate > U_DMS_SyncDate`

## Nếu chưa chắc quy trình update field này chặt chẽ

Thì đừng lấy nó làm nguồn duy nhất.
Nên có thêm bảng log sync hoặc `last successful run time`.

# Mẫu logic khá ổn

```sql
SELECT
    *
FROM OITM T0
WHERE
    T0.U_DMS_Integration = 'Y'
    AND T0.validFor = 'Y'
    AND (
        T0.U_DMS_SyncDate IS NULL
        OR T0.UpdateDate > T0.U_DMS_SyncDate
        OR T0.CreateDate > T0.U_DMS_SyncDate
    )
```

Sau khi DMS xử lý thành công xong thì cập nhật lại:

```sql
UPDATE OITM
SET U_DMS_SyncDate = GETDATE()
WHERE ItemCode IN (...)
```

# Kết luận

Có, bạn **có thể dùng `U_DMS_SyncDate`**, với điều kiện:

- nó thực sự là ngày sync thành công sang DMS
- sau mỗi lần sync thành công phải update lại field này
- logic lấy dữ liệu là: `U_DMS_SyncDate is null` hoặc `UpdateDate > U_DMS_SyncDate`

Điểm cần cẩn thận nhất là: **đừng update `U_DMS_SyncDate` trước khi chắc chắn DMS đã nhận thành công**.

Nếu muốn, mình sẽ viết luôn cho bạn đoạn SQL/store đúng theo hướng dùng `U_DMS_SyncDate`.

--------------------------------------------------------------------------------------------------------new
Ok, mình tổng hợp lại **đúng theo BA spec của bạn + thực tế triển khai .NET gọi thẳng store** để bạn có 1 flow rõ ràng, không lan man.

---

# 🧠 1. Hiểu đúng bài toán (từ BA)

BA đang yêu cầu:

> - Có **job chạy theo lịch**
> - Chỉ sync:
>   - item có `U_DMS_Integration = Y`
>   - item `validFor = Y`
>   - item **tạo mới / update**
> - Sync sang DMS

👉 Tức là: **Incremental Sync + Filter business**

---

# 🏗️ 2. Kiến trúc phù hợp với case của bạn

Bạn nói:

> .NET gọi trực tiếp store, không service layer

👉 Vậy kiến trúc sẽ là:

```text
[Scheduler / DMS]
        ↓
   .NET API (thin)
        ↓
   SQL Stored Procedure
        ↓
   SAP DB
```

👉 Toàn bộ logic nằm ở **SQL Store**

---

# 🔄 3. FLOW CUỐI CÙNG (chuẩn production)

## 🟢 Lần đầu (FULL)

```text
1. Job chạy lần đầu
2. Không có LastSyncTime
3. Call store
4. Store trả toàn bộ item hợp lệ
5. DMS nhận
6. Update LastSyncTime
```

---

## 🔵 Các lần sau (INCREMENTAL)

```text
1. Job chạy (ví dụ mỗi 5 phút)
2. Lấy LastSyncTime (VD: 10:00)
3. Call store với @LastSyncTime = 10:00
4. Store trả item:
   - CreateDate >= 10:00
   OR
   - UpdateDate >= 10:00
5. DMS xử lý
6. Update LastSyncTime = 10:05
```

---

# 🧩 4. INPUT / OUTPUT API

## ✅ API Input (tối giản)

```json
{
  "lastSyncTime": "2026-04-21T10:00:00"
}
```

👉 Nếu null → hiểu là FULL

---

## ✅ API Output (chuẩn nhất)

```json
{
  "syncTime": "2026-04-21T10:05:00",
  "total": 1,
  "data": [
    {
      "itemCode": "SP001",
      "itemName": "Paracetamol",
      "itemGroupCode": "GR01",
      "itemGroupName": "Thuốc",
      "vatRate": 5,
      "details": [
        {
          "whCode": "KHO01",
          "whName": "Kho tổng",
          "inStock": 100
        }
      ]
    }
  ]
}
```

---

# 🧱 5. STORE THIẾT KẾ (QUAN TRỌNG)

👉 Vì bạn không có service layer → store phải **trả data dễ map**

## 🔥 Best practice: 2 result sets

---

## 🟡 Store chính

```sql
CREATE PROCEDURE sp_DMS_GetItemSync
    @LastSyncTime DATETIME = NULL
AS
BEGIN

    -- HEADER
    SELECT
        T0.ItemCode,
        T0.ItemName,
        T0.ItmsGrpCod AS ItemGroupCode,
        T1.ItmsGrpNam AS ItemGroupName,
        T0.VatGroupSa,
        V.Rate AS VatRate,
        T0.CreateDate,
        T0.UpdateDate

    FROM OITM T0
    LEFT JOIN OITB T1 ON T0.ItmsGrpCod = T1.ItmsGrpCod
    LEFT JOIN OVTG V ON T0.VatGroupSa = V.Code

    WHERE
        T0.U_DMS_Integration = 'Y'
        AND T0.validFor = 'Y'
        AND (
            @LastSyncTime IS NULL
            OR T0.CreateDate >= @LastSyncTime
            OR T0.UpdateDate >= @LastSyncTime
        )

    -- DETAILS (tồn kho)
    SELECT
        T0.ItemCode,
        T0.WhsCode,
        W.WhsName,
        T0.OnHand

    FROM OITW T0
    INNER JOIN OITM I ON T0.ItemCode = I.ItemCode
    LEFT JOIN OWHS W ON T0.WhsCode = W.WhsCode

    WHERE
        I.U_DMS_Integration = 'Y'
        AND I.validFor = 'Y'
END
```

---

# ⚠️ 6. LƯU Ý QUAN TRỌNG (rất hay bị sai)

---

## ❗ 1. DETAILS KHÔNG FILTER THEO TIME

👉 Tại sao?

Vì:

- item thay đổi → phải trả toàn bộ tồn kho của nó
- không phải chỉ trả kho bị thay đổi

---

## ❗ 2. PHẢI FILTER HEADER TRƯỚC

👉 Backend sẽ:

- lấy list ItemCode từ result 1
- map với result 2

---

## ❗ 3. KHÔNG UPDATE DB TRONG STORE

👉 Vì bạn chỉ GET
→ không nên update `U_DMS_SyncDate` ở đây

---

## ❗ 4. XỬ LÝ Ở .NET

Pseudo code:

```csharp
var result = ExecuteStore();

var items = result.Table1;
var stocks = result.Table2;

foreach (var item in items)
{
    item.details = stocks
        .Where(x => x.ItemCode == item.ItemCode)
        .ToList();
}
```

---

# 🧠 7. LASTSYNC LƯU Ở ĐÂU?

👉 KHÔNG nằm trong SAP

👉 Có 2 option:

---

## 🟢 Option 1 (chuẩn nhất)

👉 DMS lưu

---

## 🔵 Option 2

👉 .NET lưu (table riêng)

```sql
DMS_Sync_Config
```

---

# 🔥 8. BEST PRACTICE (tóm gọn)

👉 Nên làm:

- ✔ 1 store → 2 result set
- ✔ filter bằng `LastSyncTime`
- ✔ filter business (`U_DMS_Integration`, `validFor`)
- ✔ details không filter time
- ✔ backend map lại

---

👉 Không nên:

- ❌ trả full mỗi lần (dù chỉ 200 item)
- ❌ update DB trong GET API
- ❌ dùng mỗi `U_DMS_SyncDate` làm nguồn duy nhất

---

# 🎯 Kết luận

👉 Flow chuẩn của bạn:

```text
Scheduler → .NET → Store → SAP → trả item thay đổi + tồn kho → DMS
```

👉 API:

- input: `lastSyncTime`
- output: item + details

👉 Store:

- filter theo time + business
- trả 2 bảng

---

# Nếu bạn muốn đi thêm 1 bước nữa

Mình có thể viết cho bạn:

- full SQL mapping đúng 100% theo file BA (rất dài)
- code .NET (Dapper / ADO.NET) map 2 result set
- hoặc design retry / error handling

Chỉ cần nói 👍
header

```sql

	SELECT
            T0."ItemCode",
            T0."ItemName",
            T0."ItmsGrpCod",
            T1."ItmsGrpNam",
            T0."U_StandardList",
            ds."Name" ,
           	T0."U_DosageForm",
           	T0."U_HSCode",
			T0."U_StorageCondition",
			T0."U_HoatChat",
			T0."U_HamLuong",
			T0."U_DelCond",
			T0."U_ECK",
            T0."U_SGDK",
            T0."U_SoLuong",
            T0."FirmCode",
            om."FirmName" ,
            om."U_FullName" ,
            T0."ShipType",
            T0."ManBtchNum" ,
            T0."VatGourpSa",
            ov."Rate" ,
            i."ISOriCntry" ,
            oc."Name" ,
            T0."DfltWH",
            ow."WhsName",
            T0."LeadTime",
            T0."PrcrmntMtd",
            T0."ItmsGrpCod"
        FROM "OITM" T0
        LEFT JOIN "OITB" T1
            ON T0."ItmsGrpCod"  = T1."ItmsGrpCod"
        LEFT JOIN "@DS_TIEUCHUAN" ds ON T0."U_StandardList" = ds."Code"
        LEFT JOIN "@BAOCHE" b ON T0."U_DosageForm" = b."Code"
        LEFT JOIN "@DKBQ" bq  ON T0."U_StorageCondition"  =  bq."Code"
        LEFT JOIN "@DKVC" vc ON  T0."U_DelCond" = vc."Code"
        LEFT JOIN OMRC om ON T0."FirmCode" = om."FirmCode"
        LEFT JOIN OSHP os ON T0."ShipType" = os."TrnspCode"
        LEFT JOIN OVTG ov ON T0."VatGourpSa" = ov."Code"
        LEFT JOIN ITM10 i ON t0."ItemCode"  = i."ItemCode"
        LEFT JOIN OCRY oc ON i."ISOriCntry" =  oc."Code"
        LEFT JOIN OWHS ow ON T0."DfltWH" = ow."WhsCode"
        WHERE  T0."validFor"  = 'Y' AND T0.U_ECK = 'N'---y truyen 1 n truyen 0-
        AND T0."ManBtchNum" = 'Y' ---y truyen 1 n truyen 0--
        AND  T0."VatGourpSa" IN ('OA00', 'OA05', 'OA08', 'OA10', 'OAEX')
        AND ov."Rate" IN  (0, 5, 10, 8)
        AND T0."PrcrmntMtd" =  'B' --Make , Buy
        ;





    CASE og."ItmsTypCod"
                WHEN 1 THEN T0."QryGroup1"
                WHEN 2 THEN T0."QryGroup2"
                WHEN 3 THEN T0."QryGroup3"
                WHEN 4 THEN T0."QryGroup4"
                WHEN 5 THEN T0."QryGroup5"
                WHEN 6 THEN T0."QryGroup6"
                WHEN 7 THEN T0."QryGroup7"
                WHEN 8 THEN T0."QryGroup8"
                WHEN 9 THEN T0."QryGroup9"
                WHEN 10 THEN T0."QryGroup10"
                WHEN 11 THEN T0."QryGroup11"
                WHEN 12 THEN T0."QryGroup12"
                WHEN 13 THEN T0."QryGroup13"
                WHEN 14 THEN T0."QryGroup14"
                WHEN 15 THEN T0."QryGroup15"
                WHEN 16 THEN T0."QryGroup16"
                WHEN 17 THEN T0."QryGroup17"
                WHEN 18 THEN T0."QryGroup18"
                WHEN 19 THEN T0."QryGroup19"
                WHEN 20 THEN T0."QryGroup20"
                WHEN 21 THEN T0."QryGroup21"
                WHEN 22 THEN T0."QryGroup22"
                WHEN 23 THEN T0."QryGroup23"
                WHEN 24 THEN T0."QryGroup24"
                WHEN 25 THEN T0."QryGroup25"
                WHEN 26 THEN T0."QryGroup26"
                WHEN 27 THEN T0."QryGroup27"
                WHEN 28 THEN T0."QryGroup28"
                WHEN 29 THEN T0."QryGroup29"
                WHEN 30 THEN T0."QryGroup30"
                WHEN 31 THEN T0."QryGroup31"
                WHEN 32 THEN T0."QryGroup32"
                WHEN 33 THEN T0."QryGroup33"
                WHEN 34 THEN T0."QryGroup34"
                WHEN 35 THEN T0."QryGroup35"
                WHEN 36 THEN T0."QryGroup36"
                WHEN 37 THEN T0."QryGroup37"
                WHEN 38 THEN T0."QryGroup38"
                WHEN 39 THEN T0."QryGroup39"
                WHEN 40 THEN T0."QryGroup40"
                WHEN 41 THEN T0."QryGroup41"
                WHEN 42 THEN T0."QryGroup42"
                WHEN 43 THEN T0."QryGroup43"
                WHEN 44 THEN T0."QryGroup44"
                WHEN 45 THEN T0."QryGroup45"
                WHEN 46 THEN T0."QryGroup46"
                WHEN 47 THEN T0."QryGroup47"
                WHEN 48 THEN T0."QryGroup48"
                WHEN 49 THEN T0."QryGroup49"
                WHEN 50 THEN T0."QryGroup50"
                WHEN 51 THEN T0."QryGroup51"
                WHEN 52 THEN T0."QryGroup52"
                WHEN 53 THEN T0."QryGroup53"
                WHEN 54 THEN T0."QryGroup54"
                WHEN 55 THEN T0."QryGroup55"
                WHEN 56 THEN T0."QryGroup56"
                WHEN 57 THEN T0."QryGroup57"
                WHEN 58 THEN T0."QryGroup58"
                WHEN 59 THEN T0."QryGroup59"
                WHEN 60 THEN T0."QryGroup60"
                WHEN 61 THEN T0."QryGroup61"
                WHEN 62 THEN T0."QryGroup62"
                WHEN 63 THEN T0."QryGroup63"
                WHEN 64 THEN T0."QryGroup64"

```
