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
        C8."BPLId"         AS "BranchCode",
        B."BPLName"        AS "BranchName",
        T0."AliasName"     AS "AliasName",
        T0."LicTradNum"    AS "TaxID",
        T0."GroupNum"      AS "PaymentTermCode",
        OCT."PymntGroup"   AS "PaymentTermName",
        T0."GroupCode"     AS "GroupCode",
        OCG."GroupName"    AS "GroupName",
        T0."Currency"      AS "Currency",
        T0."DefaultCur"    AS "DefaultCurrency"
    FROM "OCRD" T0
    INNER JOIN :lt_customer f
        ON T0."CardCode" = f."CardCode"
    LEFT JOIN "CRD8" C8
        ON T0."CardCode" = C8."CardCode"
    LEFT JOIN "OBPL" B
        ON C8."BPLId" = B."BPLId"
    LEFT JOIN "OCTG" OCT
        ON T0."GroupNum" = OCT."GroupNum"
    LEFT JOIN "OCRG" OCG
        ON T0."GroupCode" = OCG."GroupCode";

    -- DETAIL
    ELSEIF :p_Type = '2' THEN
    SELECT
        T0."CardCode"      AS "CustomerCode",
        C."Name"           AS "ContactPerson",
        C."Position"       AS "Position",
        C."Address"        AS "Address",
        C."Tel1"           AS "Telephone",
        C."Cellolar"       AS "MobilePhone"
    FROM "OCRD" T0
    INNER JOIN :lt_customer f
        ON T0."CardCode" = f."CardCode"
    LEFT JOIN "OCPR" C
        ON T0."CardCode" = C."CardCode";

    END IF;
END;



