CALL "SP_GET_ITEM_HEADER_DETAIL"('1',50);


CREATE OR REPLACE PROCEDURE "SP_GET_ITEM_HEADER_DETAIL"
(

    IN p_Type		  NVARCHAR(1),
    IN p_Top  INT DEFAULT 50
  
    
)
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
READS SQL DATA
AS
BEGIN

    lt_item =
        SELECT TOP :p_Top
            T0."ItemCode"
        FROM "OITM" T0
        WHERE T0."validFor" = 'Y';

    -- HEADER
    IF :p_Type = '1' THEN
    SELECT
        T0."ItemCode"          AS "ItemCode",
        T0."ItemName"          AS "ItemName",
        T0."ItmsGrpCod"        AS "ItemGroupCode",
        T1."ItmsGrpNam"        AS "ItemGroupName",
        T0."U_StandardList"    AS "StandardListCode",
        ds."Name"              AS "StandardListName",
        T0."U_DosageForm"      AS "DosageFormCode",
        b."Name"               AS "DosageFormName",
        T0."U_HSCode"          AS "HSCode",
        T0."U_StorageCondition" AS "StorageConditionCode",
        bq."Name"              AS "StorageConditionName",
        T0."U_HoatChat"        AS "HoatChat",
        T0."U_HamLuong"        AS "HamLuong",
        T0."U_DelCond"         AS "DelCondCode",
        vc."Name"              AS "DelCondName",
        CASE WHEN T0."U_ECK" = 'Y' THEN '1'
             WHEN T0."U_ECK" = 'N' THEN '0'
        END                    AS "ItemCK",
        T0."U_SGDK"            AS "SGDK",
        T0."U_SoLuong"         AS "SLFA",
        T0."FirmCode"          AS "ManufacturerCode",
        om."FirmName"          AS "ManufacturerName",
        om."U_FullName"        AS "ManufacturerFullName",
        T0."ShipType"          AS "ShippingTypeCode",
        os."TrnspName"         AS "ShippingTypeName",
        CASE WHEN T0."ManBtchNum" = 'Y' THEN '1'
                 WHEN T0."ManBtchNum" = 'N' THEN '0'
            END                      AS "ManBtchNum",
        T0."VatGourpSa"        AS "VatGroup",
        ov."Rate"              AS "VatRate",
        i."ISOriCntry"         AS "OriginCode",
        oc."Name"              AS "OriginName",
        T0."DfltWH"            AS "DefaultWHCode",
        ow."WhsName"           AS "DefaultWHName",
        T0."LeadTime"          AS "LeadTime",
        CASE WHEN T0."PrcrmntMtd" = 'M' THEN 'Make'
             WHEN T0."PrcrmntMtd" = 'B' THEN 'Buy'
        END                    AS "ProcurementMethod",
        P."ItmsGrpNam"         AS "Properties"
    FROM "OITM" T0
    INNER JOIN :lt_item f
        ON T0."ItemCode" = f."ItemCode"
    LEFT JOIN "OITB" T1
        ON T0."ItmsGrpCod" = T1."ItmsGrpCod"
    LEFT JOIN "@DS_TIEUCHUAN" ds
        ON T0."U_StandardList" = ds."Code"
    LEFT JOIN "@BAOCHE" b
        ON T0."U_DosageForm" = b."Code"
    LEFT JOIN "@DKBQ" bq
        ON T0."U_StorageCondition" = bq."Code"
    LEFT JOIN "@DKVC" vc
        ON T0."U_DelCond" = vc."Code"
    LEFT JOIN "OMRC" om
        ON T0."FirmCode" = om."FirmCode"
    LEFT JOIN "OSHP" os
        ON T0."ShipType" = os."TrnspCode"
    LEFT JOIN "OVTG" ov
        ON T0."VatGourpSa" = ov."Code"
    LEFT JOIN "ITM10" i
        ON T0."ItemCode" = i."ItemCode"
    LEFT JOIN "OCRY" oc
        ON i."ISOriCntry" = oc."Code"
    LEFT JOIN "OWHS" ow
        ON T0."DfltWH" = ow."WhsCode"
    LEFT JOIN "VW_ITEM_PROPERTIES" P
        ON T0."ItemCode" = P."ItemCode";
    -- DETAIL
    ELSEIF  :p_Type = '2' THEN
    SELECT
        o."ItemCode"       AS "ItemCode",
        o."SalUnitMsr"     AS "SaleUom",
        o."NumInSale"      AS "Conversion_Rate",
        o."InvntryUom"     AS "InventoryUom",
        o."SalPackMsr"     AS "PackingUom",
        o."SalPackUn"      AS "QtyPackage",
        o2."WhsCode"       AS "WHCode",
        o3."WhsName"       AS "WHName",
        o2."OnHand"        AS "InStock"
    FROM "OITM" o
    INNER JOIN :lt_item f
        ON o."ItemCode" = f."ItemCode"
    LEFT JOIN "OITW" o2
        ON o."ItemCode" = o2."ItemCode"
    LEFT JOIN "OWHS" o3
        ON o2."WhsCode" = o3."WhsCode";
    
    END IF;
END;
        			