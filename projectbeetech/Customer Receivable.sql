    
SELECT 
    T0."CardCode"        AS "CustomerCode",
    T0."CardName"        AS "CustomerName",
    T1."BPLId"           AS "BranchCode",
    T1."BPLName"         AS "BranchName",
    SUM(T1."Debit") - SUM(T1."Credit") AS "Amount",
    T1."Account" 
FROM "OCRD" T0
INNER JOIN "JDT1" T1 
    ON T1."ShortName" = T0."CardCode"
WHERE 
    T0."CardType" = 'C'
    AND T0."GroupCode" <> 126
    AND T1."Account" LIKE '131%'
    AND T1."RefDate" <= CURRENT_DATE
    AND T1."BPLId" = 3
GROUP BY 
    T0."CardCode",
    T0."CardName",
    T1."BPLId",
    T1."BPLName",
	T1."Account" 
;


CALL "SP_GET_CUSTOMER_RECEIVABLE"(3)
