CREATE PROCEDURE "SP_GET_CUSTOMER_RECEIVABLE" (
    IN p_BPLId INT 
)
LANGUAGE SQLSCRIPT
AS
BEGIN
    SELECT 
        T0."CardCode"                       AS "CustomerCode",
        T0."CardName"                       AS "CustomerName",
        T1."BPLId"                          AS "BranchCode",
        T1."BPLName"                        AS "BranchName",
        SUM(T1."Debit" - T1."Credit")       AS "Amount",
        -- T1."Account"                        AS "AccountCode"
    FROM "OCRD" T0
    INNER JOIN "JDT1" T1 ON T1."ShortName" = T0."CardCode"
    INNER JOIN "OACT" T2 ON T1."Account" = T2."AcctCode"
    WHERE 
        T0."CardType" = 'C'                 
        AND T0."GroupCode" <> 126          
        AND T2."FormatCode" LIKE '131%'      
        AND T1."RefDate" <= CURRENT_DATE     
        AND (T1."BPLId" = :p_BPLId OR :p_BPLId IS NULL) 
    GROUP BY 
        T0."CardCode",
        T0."CardName",
        T1."BPLId",
        T1."BPLName",
        T1."Account"
    ORDER BY 
        T0."CardCode", 
        T1."BPLId";
END;

