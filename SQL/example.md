```sql
SELECT \*
FROM (
SELECT
T1."DocEntry",
T1."LineNum",
T1."ItemCode",
T1."Quantity",
ROW_NUMBER() OVER (
PARTITION BY T1."DocEntry"
ORDER BY T1."LineNum"
) AS "RN"
FROM "RDR1" T1
) X
WHERE X."RN" = 1;
-- ROW_NUMBER(): Hàm này dùng để đánh số thứ tự tăng dần (1, 2, 3...).
--PARTITION BY T1."DocEntry": Đây là phần "chia nhóm". Nó bảo máy tính rằng: "Hãy bắt đầu đánh số lại từ 1 mỗi khi gặp một DocEntry (Số nội bộ đơn hàng) mới".
--ORDER BY T1."LineNum": Đây là tiêu chí để đánh số. Dòng nào có LineNum nhỏ nhất sẽ được đánh số 1.
-- 3) Window function trong HANA
-- ROW_NUMBER, RANK, DENSE_RANK
SELECT
T1."DocEntry",
T1."LineNum",
T1."ItemCode",
T1."Price",
ROW_NUMBER() OVER (
PARTITION BY T1."DocEntry"
ORDER BY T1."Price" DESC
) AS "ROW_NUM",
RANK() OVER (
PARTITION BY T1."DocEntry"
ORDER BY T1."Price" DESC
) AS "RANK_NUM",
DENSE_RANK() OVER (
PARTITION BY T1."DocEntry"
ORDER BY T1."Price" DESC
) AS "DENSE_RANK_NUM"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1;

--running total
SELECT
T1."DocEntry",
T1."LineNum",
T1."Quantity",
T1."LineTotal",
SUM(T1."LineTotal") OVER (
PARTITION BY T1."DocEntry"
ORDER BY T1."LineNum"
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS "RunningTotal"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1;

--result
LineNum,LineTotal,RunningTotal,Giải thích
0,100,100,(Chỉ có dòng đầu)
1,50,150,(100 + 50)
2,200,350,(100 + 50 + 200)

SELECT
T1."DocEntry",
T1."LineNum",
T1."ItemCode",
T1."LineTotal",
SUM(T1."LineTotal") OVER (
PARTITION BY T1."DocEntry"
) AS "DocTotalByWindow"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1;
-- DocTotalByWindow đã là tổng của từng hàng

--cte
WITH "ORDER*SUMMARY" AS (
SELECT
T1."DocEntry",
SUM(T1."LineTotal") AS "TotalAmount",
SUM(T1."Quantity") AS "TotalQty",
COUNT(*) AS "LineCount"
FROM "RDR1" T1
GROUP BY T1."DocEntry"
)
SELECT \_
FROM "ORDER_SUMMARY"
WHERE "TotalAmount" > 1000;

--create store
CREATE PROCEDURE "SP_GET_SO"
(
IN P_DOCENTRY INT
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
SELECT \*
FROM "ORDR"
WHERE "DocEntry" = :P_DOCENTRY;

    SELECT *
    FROM "RDR1"
    WHERE "DocEntry" = :P_DOCENTRY
    ORDER BY "LineNum";

END;

--out PARAMETER
CREATE PROCEDURE "SP_GET_SO_TOTAL"
(
IN P_DOCENTRY INT,
OUT P_TOTAL DECIMAL(19,6)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
SELECT IFNULL(SUM(T1."LineTotal"), 0)
INTO P_TOTAL
FROM "RDR1" T1
WHERE T1."DocEntry" = :P_DOCENTRY;
END;
```

Được, đổi sang **SAP HANA SQL** luôn để bạn copy test nhanh.

Mình sẽ viết theo đúng mấy chủ đề bạn vừa nhắc:

- multi join
- function / procedure / view
- calculation
- window function
- performance
- dynamic SQL kiểu HANA

---

# 1) Multi JOIN nâng cao

## Sales Order + Customer + Item + Warehouse

```sql
SELECT
    T0."DocEntry",
    T0."CardCode",
    T2."CardName",
    T1."ItemCode",
    T3."ItemName",
    T1."Quantity",
    T1."Price",
    T4."WhsName"
FROM "ORDR" T0
INNER JOIN "RDR1" T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode"
LEFT JOIN "OITM" T3 ON T1."ItemCode" = T3."ItemCode"
LEFT JOIN "OWHS" T4 ON T1."WhsCode" = T4."WhsCode"
WHERE T0."DocEntry" = 1;
```

---

# 2) JOIN nâng cao: lấy dòng đầu tiên / cuối cùng của mỗi order

## Dùng `ROW_NUMBER()`

```sql
SELECT *
FROM (
    SELECT
        T1."DocEntry",
        T1."LineNum",
        T1."ItemCode",
        T1."Quantity",
        ROW_NUMBER() OVER (
            PARTITION BY T1."DocEntry"
            ORDER BY T1."LineNum"
        ) AS "RN"
    FROM "RDR1" T1
) X
WHERE X."RN" = 1;
```

## Lấy dòng cuối

```sql
SELECT *
FROM (
    SELECT
        T1."DocEntry",
        T1."LineNum",
        T1."ItemCode",
        T1."Quantity",
        ROW_NUMBER() OVER (
            PARTITION BY T1."DocEntry"
            ORDER BY T1."LineNum" DESC
        ) AS "RN"
    FROM "RDR1" T1
) X
WHERE X."RN" = 1;
```

---

# 3) Window function trong HANA

## `ROW_NUMBER`, `RANK`, `DENSE_RANK`

```sql
SELECT
    T1."DocEntry",
    T1."LineNum",
    T1."ItemCode",
    T1."Price",
    ROW_NUMBER() OVER (
        PARTITION BY T1."DocEntry"
        ORDER BY T1."Price" DESC
    ) AS "ROW_NUM",
    RANK() OVER (
        PARTITION BY T1."DocEntry"
        ORDER BY T1."Price" DESC
    ) AS "RANK_NUM",
    DENSE_RANK() OVER (
        PARTITION BY T1."DocEntry"
        ORDER BY T1."Price" DESC
    ) AS "DENSE_RANK_NUM"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1;
```

## Running total

```sql
SELECT
    T1."DocEntry",
    T1."LineNum",
    T1."Quantity",
    T1."LineTotal",
    SUM(T1."LineTotal") OVER (
        PARTITION BY T1."DocEntry"
        ORDER BY T1."LineNum"
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS "RunningTotal"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1;
```

## Tổng line nhưng vẫn giữ từng dòng

```sql
SELECT
    T1."DocEntry",
    T1."LineNum",
    T1."ItemCode",
    T1."LineTotal",
    SUM(T1."LineTotal") OVER (
        PARTITION BY T1."DocEntry"
    ) AS "DocTotalByWindow"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1;
```

---

# 4) CTE trong HANA

```sql
WITH "ORDER_SUMMARY" AS (
    SELECT
        T1."DocEntry",
        SUM(T1."LineTotal") AS "TotalAmount",
        SUM(T1."Quantity") AS "TotalQty",
        COUNT(*) AS "LineCount"
    FROM "RDR1" T1
    GROUP BY T1."DocEntry"
)
SELECT *
FROM "ORDER_SUMMARY"
WHERE "TotalAmount" > 1000;
```

---

# 5) VIEW trong HANA

```sql
CREATE VIEW "VW_SO_FULL"
AS
SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."CardCode",
    T0."CardName",
    T0."DocDate",
    T1."LineNum",
    T1."ItemCode",
    T1."Dscription",
    T1."Quantity",
    T1."Price",
    T1."LineTotal"
FROM "ORDR" T0
INNER JOIN "RDR1" T1 ON T0."DocEntry" = T1."DocEntry";
```

Test:

```sql
SELECT *
FROM "VW_SO_FULL"
WHERE "DocEntry" = 1;
```

---

# 6) Function trong HANA

HANA support **SQLScript function**, nhưng thực tế trong SAP B1 bạn sẽ hay dùng **table function** hơn.

## Scalar function đơn giản

```sql
CREATE FUNCTION "FN_ADD_TAX"
(
    IN AMOUNT DECIMAL(19,6),
    IN TAX_RATE DECIMAL(19,6)
)
RETURNS RESULT DECIMAL(19,6)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
    RESULT := :AMOUNT + (:AMOUNT * :TAX_RATE / 100);
END;
```

Test:

```sql
SELECT "FN_ADD_TAX"(100, 10) AS "TOTAL_WITH_TAX" FROM DUMMY;
```

---

## Table function

```sql
CREATE FUNCTION "FN_SO_LINES"
(
    IN P_DOCENTRY INT
)
RETURNS TABLE
(
    "DocEntry" INT,
    "LineNum" INT,
    "ItemCode" NVARCHAR(50),
    "Quantity" DECIMAL(19,6),
    "Price" DECIMAL(19,6),
    "LineTotal" DECIMAL(19,6)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
    RETURN
    SELECT
        T1."DocEntry",
        T1."LineNum",
        T1."ItemCode",
        T1."Quantity",
        T1."Price",
        T1."LineTotal"
    FROM "RDR1" T1
    WHERE T1."DocEntry" = :P_DOCENTRY;
END;
```

Test:

```sql
SELECT *
FROM "FN_SO_LINES"(1);
```

---

# 7) Stored Procedure trong HANA

## Procedure trả result set

```sql
CREATE PROCEDURE "SP_GET_SO"
(
    IN P_DOCENTRY INT
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
    SELECT *
    FROM "ORDR"
    WHERE "DocEntry" = :P_DOCENTRY;

    SELECT *
    FROM "RDR1"
    WHERE "DocEntry" = :P_DOCENTRY
    ORDER BY "LineNum";
END;
```

Call:

```sql
CALL "SP_GET_SO"(1);
```

---

## Procedure có OUT parameter

```sql
CREATE PROCEDURE "SP_GET_SO_TOTAL"
(
    IN P_DOCENTRY INT,
    OUT P_TOTAL DECIMAL(19,6)
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS
BEGIN
    SELECT IFNULL(SUM(T1."LineTotal"), 0)
    INTO P_TOTAL
    FROM "RDR1" T1
    WHERE T1."DocEntry" = :P_DOCENTRY;
END;
```

Call:

```sql
CALL "SP_GET_SO_TOTAL"(1, ?);
```

---

# 8) Calculation trong HANA

## Tính line total, discount, tax

```sql
SELECT
    T1."DocEntry",
    T1."LineNum",
    T1."ItemCode",
    T1."Quantity",
    T1."Price",
    (T1."Quantity" * T1."Price") AS "GrossAmount",
    ((T1."Quantity" * T1."Price") * 0.05) AS "DiscountAmount",
    ((T1."Quantity" * T1."Price") * 0.95) AS "NetAmount"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1;
```

## CASE WHEN

```sql
SELECT
    T1."DocEntry",
    T1."LineNum",
    T1."ItemCode",
    T1."LineTotal",
    CASE
        WHEN T1."LineTotal" >= 1000 THEN 'HIGH'
        WHEN T1."LineTotal" >= 500 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS "AmountLevel"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1;
```

---

# 9) Dynamic SQL trong HANA

Trong HANA SQLScript, dynamic SQL dùng `EXEC` hoặc `EXECUTE IMMEDIATE`.

## Basic dynamic SQL

```sql
DO
BEGIN
    DECLARE LV_SQL NVARCHAR(5000);
    DECLARE LV_DOCENTRY INT := 1;

    LV_SQL := '
        SELECT *
        FROM "ORDR"
        WHERE "DocEntry" = ' || TO_NVARCHAR(:LV_DOCENTRY);

    EXECUTE IMMEDIATE :LV_SQL;
END;
```

---

## Dynamic SQL an toàn hơn theo kiểu build có kiểm soát

Ví dụ dynamic filter theo tên bảng:

```sql
DO
BEGIN
    DECLARE LV_TABLE NVARCHAR(50) := 'ORDR';
    DECLARE LV_SQL NVARCHAR(5000);

    LV_SQL := 'SELECT TOP 10 * FROM "' || :LV_TABLE || '"';

    EXECUTE IMMEDIATE :LV_SQL;
END;
```

Lưu ý:

- dynamic SQL trong HANA rất mạnh
- nhưng cũng rất dễ lỗi nếu ghép chuỗi bừa
- tên bảng/cột động thì gần như bắt buộc phải validate trước ở app layer

---

# 10) Tương đương `OUTER APPLY` trong HANA

HANA không có `OUTER APPLY` kiểu SQL Server. Thường thay bằng:

- subquery
- CTE
- window function

Ví dụ lấy dòng giá cao nhất mỗi order:

```sql
SELECT *
FROM (
    SELECT
        T1."DocEntry",
        T1."LineNum",
        T1."ItemCode",
        T1."Price",
        ROW_NUMBER() OVER (
            PARTITION BY T1."DocEntry"
            ORDER BY T1."Price" DESC
        ) AS "RN"
    FROM "RDR1" T1
) X
WHERE X."RN" = 1;
```

---

# 11) Performance tuning trong HANA

HANA khác SQL Server ở chỗ nó là **in-memory column store**, nên tuning cũng khác.

## Rule quan trọng

### a) Tránh `SELECT *`

```sql
SELECT "DocEntry", "CardCode", "DocDate"
FROM "ORDR";
```

### b) Filter sớm

```sql
SELECT
    T0."DocEntry",
    T1."ItemCode"
FROM "ORDR" T0
INNER JOIN "RDR1" T1 ON T0."DocEntry" = T1."DocEntry"
WHERE T0."DocEntry" = 1;
```

### c) Tránh function trên cột trong WHERE

Không tốt:

```sql
SELECT *
FROM "ORDR"
WHERE YEAR("DocDate") = 2024;
```

Tốt hơn:

```sql
SELECT *
FROM "ORDR"
WHERE "DocDate" >= '2024-01-01'
  AND "DocDate" < '2025-01-01';
```

### d) Chỉ lấy cột cần dùng trong JOIN/report

Vì HANA là columnar, lấy ít cột thường lợi hơn rõ.

### e) Dùng window function thay vì subquery lồng quá sâu khi phù hợp

Nhiều case HANA xử lý window function rất tốt.

---

# 12) Explain Plan trong HANA

## Cách xem plan

```sql
EXPLAIN PLAN SET STATEMENT_NAME = 'SO_TEST'
FOR
SELECT
    T0."DocEntry",
    T1."ItemCode"
FROM "ORDR" T0
JOIN "RDR1" T1 ON T0."DocEntry" = T1."DocEntry"
WHERE T0."DocEntry" = 1;
```

Xem plan:

```sql
SELECT *
FROM EXPLAIN_PLAN_TABLE
WHERE STATEMENT_NAME = 'SO_TEST'
ORDER BY ID;
```

---

# 13) Query tổng hợp nâng cao cho bạn test

## Lấy Sales Order:

- tổng số line
- tổng số lượng
- tổng tiền
- dòng đầu tiên
- dòng giá cao nhất
- rank line theo giá

```sql
WITH "LINES" AS (
    SELECT
        T1."DocEntry",
        T1."LineNum",
        T1."ItemCode",
        T1."Quantity",
        T1."Price",
        T1."LineTotal",
        ROW_NUMBER() OVER (
            PARTITION BY T1."DocEntry"
            ORDER BY T1."LineNum"
        ) AS "RN_FIRST",
        ROW_NUMBER() OVER (
            PARTITION BY T1."DocEntry"
            ORDER BY T1."Price" DESC
        ) AS "RN_MAX_PRICE",
        RANK() OVER (
            PARTITION BY T1."DocEntry"
            ORDER BY T1."Price" DESC
        ) AS "PRICE_RANK"
    FROM "RDR1" T1
),
"SUMMARY" AS (
    SELECT
        T1."DocEntry",
        COUNT(*) AS "LINE_COUNT",
        SUM(T1."Quantity") AS "TOTAL_QTY",
        SUM(T1."LineTotal") AS "TOTAL_AMOUNT"
    FROM "RDR1" T1
    GROUP BY T1."DocEntry"
)
SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."CardCode",
    T0."CardName",
    S."LINE_COUNT",
    S."TOTAL_QTY",
    S."TOTAL_AMOUNT",
    F."ItemCode" AS "FIRST_ITEM",
    F."LineNum" AS "FIRST_LINE",
    M."ItemCode" AS "MAX_PRICE_ITEM",
    M."Price" AS "MAX_PRICE"
FROM "ORDR" T0
LEFT JOIN "SUMMARY" S ON T0."DocEntry" = S."DocEntry"
LEFT JOIN "LINES" F ON T0."DocEntry" = F."DocEntry" AND F."RN_FIRST" = 1
LEFT JOIN "LINES" M ON T0."DocEntry" = M."DocEntry" AND M."RN_MAX_PRICE" = 1
WHERE T0."DocEntry" = 1;
```

---

# 14) Query rank tất cả line để test nhanh

```sql
SELECT
    T1."DocEntry",
    T1."LineNum",
    T1."ItemCode",
    T1."Price",
    RANK() OVER (
        PARTITION BY T1."DocEntry"
        ORDER BY T1."Price" DESC
    ) AS "PRICE_RANK"
FROM "RDR1" T1
WHERE T1."DocEntry" = 1
ORDER BY T1."LineNum";
```

---

# 15) Lưu ý rất quan trọng khi test trên HANA

Trong SAP HANA:

- tên bảng/cột SAP B1 thường phải đặt trong `"`
- ví dụ `"ORDR"`, `"DocEntry"`
- string dùng `'...'`
- nối chuỗi bằng `||`

---

Nếu muốn, lượt tiếp theo mình sẽ làm cho bạn một bộ **cheat sheet SAP HANA SQL nâng cao 1 trang**, gồm đúng các mẫu query hay dùng nhất để bạn dán vào dự án luôn.
