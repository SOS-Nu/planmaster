1. OPRC
   Dùng để lấy danh sách phòng ban / cost center.

Điều kiện theo mẫu:

DimCode = 3
U_Depttype = 1

Field cần:

PrcCode → mã Department
PrcName → tên Department

2. OJDT + JDT1
   Dùng để lấy số Actual.

Theo note trong file:

lấy từ JE
SUM(Credit - Debit)
chỉ lấy các tài khoản đầu 6 và 8
group theo OcrCode3
group theo tháng

Thực tế:

OJDT là header bút toán
JDT1 là detail bút toán

Field hay dùng:

OJDT.RefDate hoặc TaxDate / DueDate → thường report kiểu này nên dùng RefDate
JDT1.Account
JDT1.Credit
JDT1.Debit
JDT1.OcrCode3

SELECT _ FROM OJDT o ;
SELECT _ FROM JDT1 j ;
SELECT _ FROM OACT o ;
SELECT FROM OPCH; -- AP Invoice
SELECT FROM OINV; -- AR Invoice
SELECT _ FROM ORCT; -- Incoming Payment
SELECT _ FROM OVPM; -- Outgoing Payment
SELECT _ FROM OJDT; -- Journal Entry Header
SELECT _ FROM JDT1; -- Journal Entry Detail
SELECT _ FROM OACT; -- Account
