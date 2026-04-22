
CALL "SP_GET_CUSTOMER_HEADER_DETAIL"('1',50);

CREATE OR REPLACE PROCEDURE "SP_GET_CUSTOMER_HEADER_DETAIL"
(
    IN p_Type NVARCHAR(1),
    IN p_Top  INT DEFAULT 50
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
READS SQL DATA
AS
BEGIN

    lt_customer =
        SELECT TOP :p_Top
            T0."CardCode"
        FROM "OCRD" T0
        WHERE T0."validFor" = 'Y';

    -- HEADER
    IF :p_Type = '1' THEN
        SELECT
            T0."CardCode"      AS "CustomerCode",
            T0."CardName"      AS "CustomerName",
            b."BPLId"          AS "BranchCode",
            ob."BPLName"       AS "BranchName",
            T0."AliasName"     AS "AliasName",
            T0."LicTradNum"    AS "TaxID",
            T0."GroupNum"      AS "PaymentTermCode",
            oct."PymntGroup"   AS "PaymentTermName",
            T0."GroupCode"     AS "GroupCode",
            ocg."GroupName"    AS "GroupName",
            T0."Currency"      AS "Currency",
            T0."DefaultCur"    AS "DefaultCurrency"
        FROM "OCRD" T0
        INNER JOIN :lt_customer f
            ON T0."CardCode" = f."CardCode"
        LEFT JOIN "CRD8" c        
            ON T0."CardCode" = b."CardCode"
        LEFT JOIN "OBPL" ob
            ON b."BPLId" = ob."BPLId"
        LEFT JOIN "OCTG" oct
            ON T0."GroupNum" = oct."GroupNum"
        LEFT JOIN "OCRG" ocg
            ON T0."GroupCode" = ocg."GroupCode";

    -- DETAIL
    ELSEIF :p_Type = '2' THEN
        SELECT
            T0."CardCode"      AS "CustomerCode",
            c."Name"           AS "ContactPerson",
            c."Position"       AS "Position",
            c."Address"        AS "Address",
            c."Tel1"           AS "Telephone",
            c."Cellolar"       AS "MobilePhone"
        FROM "OCRD" T0
        INNER JOIN :lt_customer f
            ON T0."CardCode" = f."CardCode"
        LEFT JOIN "OCPR" c
            ON T0."CardCode" = c."CardCode";

    END IF;

END;