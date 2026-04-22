CREATE OR REPLACE VIEW "VW_ITEM_PROPERTIES" AS
 (
    SELECT
        X."ItemCode",
        STRING_AGG(X."ItmsGrpNam", ', ') AS "Properties"
    FROM (
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 1
        WHERE T0."QryGroup1" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 2
        WHERE T0."QryGroup2" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 3
        WHERE T0."QryGroup3" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 4
        WHERE T0."QryGroup4" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 5
        WHERE T0."QryGroup5" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 6
        WHERE T0."QryGroup6" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 7
        WHERE T0."QryGroup7" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 8
        WHERE T0."QryGroup8" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 9
        WHERE T0."QryGroup9" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 10
        WHERE T0."QryGroup10" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 11
        WHERE T0."QryGroup11" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 12
        WHERE T0."QryGroup12" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 13
        WHERE T0."QryGroup13" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 14
        WHERE T0."QryGroup14" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 15
        WHERE T0."QryGroup15" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 16
        WHERE T0."QryGroup16" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 17
        WHERE T0."QryGroup17" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 18
        WHERE T0."QryGroup18" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 19
        WHERE T0."QryGroup19" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 20
        WHERE T0."QryGroup20" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 21
        WHERE T0."QryGroup21" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 22
        WHERE T0."QryGroup22" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 23
        WHERE T0."QryGroup23" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 24
        WHERE T0."QryGroup24" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 25
        WHERE T0."QryGroup25" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 26
        WHERE T0."QryGroup26" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 27
        WHERE T0."QryGroup27" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 28
        WHERE T0."QryGroup28" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 29
        WHERE T0."QryGroup29" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 30
        WHERE T0."QryGroup30" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 31
        WHERE T0."QryGroup31" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 32
        WHERE T0."QryGroup32" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 33
        WHERE T0."QryGroup33" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 34
        WHERE T0."QryGroup34" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 35
        WHERE T0."QryGroup35" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 36
        WHERE T0."QryGroup36" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 37
        WHERE T0."QryGroup37" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 38
        WHERE T0."QryGroup38" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 39
        WHERE T0."QryGroup39" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 40
        WHERE T0."QryGroup40" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 41
        WHERE T0."QryGroup41" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 42
        WHERE T0."QryGroup42" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 43
        WHERE T0."QryGroup43" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 44
        WHERE T0."QryGroup44" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 45
        WHERE T0."QryGroup45" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 46
        WHERE T0."QryGroup46" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 47
        WHERE T0."QryGroup47" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 48
        WHERE T0."QryGroup48" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 49
        WHERE T0."QryGroup49" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 50
        WHERE T0."QryGroup50" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 51
        WHERE T0."QryGroup51" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 52
        WHERE T0."QryGroup52" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 53
        WHERE T0."QryGroup53" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 54
        WHERE T0."QryGroup54" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 55
        WHERE T0."QryGroup55" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 56
        WHERE T0."QryGroup56" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 57
        WHERE T0."QryGroup57" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 58
        WHERE T0."QryGroup58" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 59
        WHERE T0."QryGroup59" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 60
        WHERE T0."QryGroup60" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 61
        WHERE T0."QryGroup61" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 62
        WHERE T0."QryGroup62" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 63
        WHERE T0."QryGroup63" = 'Y'

        UNION ALL
        SELECT T0."ItemCode", G."ItmsGrpNam"
        FROM "OITM" T0
        INNER JOIN "OITG" G ON G."ItmsTypCod" = 64
        WHERE T0."QryGroup64" = 'Y'
    ) X
    GROUP BY X."ItemCode"
)

