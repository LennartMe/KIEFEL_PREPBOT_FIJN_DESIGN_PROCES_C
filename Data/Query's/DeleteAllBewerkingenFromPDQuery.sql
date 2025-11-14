BEGIN TRANSACTION;

DECLARE @p22 DATETIME2(7) = NULL,
        @p23 INT = 0,
        @p24 INT = 0,
        @p25 INT = 0,
        @p26 INT = 0,
        @p27 INT = 0,
        @p28 INT = 0,
        @p29 INT = 0,
        @p30 INT = 0,
        @p31 INT = 5,
        @p32 INT = 0,
        @p33 INT = 0,
        @p34 INT = 0,
        @p35 INT = 1,
        @p36 INT = 5,
        @p37 INT = 0,
        @p38 INT = 0;

EXEC [dbo].[IP_prc_PartsListProd] 
    N'{ProdHeaderDossierCode}', 0, 1, 0, 0, 0, 0, 0, 
    N'', 0, 0, N'', 0, 0, N'', 0, 0, N'', 
    0, N'RPA', 1290000, 
    @p22 OUTPUT, @p23 OUTPUT, @p24 OUTPUT, @p25 OUTPUT, @p26 OUTPUT, @p27 OUTPUT, 
    @p28 OUTPUT, @p29 OUTPUT, @p30 OUTPUT, @p31 OUTPUT, @p32 OUTPUT, @p33 OUTPUT, 
    @p34 OUTPUT, @p35 OUTPUT, @p36 OUTPUT, @p37 OUTPUT, @p38 OUTPUT;

--SELECT 
--    @p22 AS p22, @p23 AS p23, @p24 AS p24, @p25 AS p25, 
--    @p26 AS p26, @p27 AS p27, @p28 AS p28_DeletedQty, @p29 AS p29, 
--    @p30 AS p30, @p31 AS p31_RemainingQty, @p32 AS p32, @p33 AS p33, 
--    @p34 AS p34, @p35 AS p35, @p36 AS p36_OldQty, @p37 AS p37, 
--    @p38 AS p38;

IF EXISTS (
    SELECT 1 
    FROM T_ProdBillOfOper 
    WHERE ProdHeaderDossierCode = '{ProdHeaderDossierCode}'
)
BEGIN
    ROLLBACK TRANSACTION;
    SELECT '0' AS Result, 'Bewerking rows could not be deleted.' AS Message;
END
ELSE IF @p28 = 0
BEGIN
    COMMIT TRANSACTION;
    SELECT '1' AS Result, 'No bewerking rows to be deleted.' AS Message;
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    SELECT '1' AS Result, 'Bewerking rows Successfully deleted.' AS Message;
END
