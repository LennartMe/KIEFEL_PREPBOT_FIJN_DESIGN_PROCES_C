BEGIN TRANSACTION;

DECLARE @ProductionDossiercode NVARCHAR(4000) = N'{ProdHeaderDossierCode}' -- PD to update
DECLARE @LineNr INT = {LineNr} -- LineNr voor bewerking
DECLARE @ProdBOOLineNr INT -- ProdBOOLineNr to update memo
DECLARE @MemoText NVARCHAR(4000) = N'{MemoText}' -- Nieuwe Memo

DECLARE @OldUpdatedOn NVARCHAR(30)
DECLARE @LastUpdatedOn NVARCHAR(30) = CONVERT(NVARCHAR(30), GETDATE(), 120)
DECLARE @ResultCode INT = 0
DECLARE @ResultMessage NVARCHAR(255)

BEGIN TRY
    -- Stap 1: Haal huidige LastUpdatedOn op
    SELECT @OldUpdatedOn = CONVERT(NVARCHAR(30), LastUpdatedOn, 109),
			@ProdBOOLineNr = ProdBOOLineNr
    FROM T_ProdBillOfOper
    WHERE ProdHeaderDossierCode = @ProductionDossiercode
      AND LineNr = @LineNr;

    IF @OldUpdatedOn IS NULL
        SET @OldUpdatedOn = '2000-01-01 00:00:00.000'

    -- Stap 2: Reserveer memo ID
    DECLARE @AuxMemoID INT
    EXEC dbo.IP_Get_AuxMemoID @AuxMemoID OUTPUT;

    -- Stap 3: Schrijf memo naar UV_AuxMemo
    EXEC sp_executesql 
        N'UPDATE UV_AuxMemo SET Info = @MemoText WHERE AuxMemoID = @MemoID',
        N'@MemoText NVARCHAR(4000), @MemoID INT',
        @MemoText = @MemoText, 
        @MemoID = @AuxMemoID;

    -- Stap 4: Update ProdBOO met memo
    EXEC dbo.IP_Upd_ProdBOO
        @old_ProdHeaderDossierCode = @ProductionDossiercode,
        @old_ProdBOOLineNr = @ProdBOOLineNr,
        @old_LastUpdatedOn = @OldUpdatedOn,
        @Info = @AuxMemoID,
        @IsahUserCode = N'RPA',
        @LogProgramCode = 920000,
        @LastUpdatedOn = @LastUpdatedOn OUTPUT;

    SET @ResultCode = 1
    SET @ResultMessage = 'Memo succesvol toegevoegd aan bewerking regel ' + CAST(@LineNr AS NVARCHAR) + ' van PD: ' + @ProductionDossiercode
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    SET @ResultCode = 0
    SET @ResultMessage = ERROR_MESSAGE()
    ROLLBACK TRANSACTION
END CATCH

-- Output
SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;
