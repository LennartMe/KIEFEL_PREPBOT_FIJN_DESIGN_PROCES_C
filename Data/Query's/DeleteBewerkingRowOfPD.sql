BEGIN TRANSACTION;

DECLARE @ProdHeaderDossierCode NVARCHAR(4000) = N'{ProdHeaderDossierCode}' -- PD to update
DECLARE @LineNr INT = {LineNr} -- LineNr voor bewerking
DECLARE @ProdBOOLineNr INT -- ProdBOOLineNr to Delete

DECLARE @OldUpdatedOn NVARCHAR(30)
DECLARE @ResultCode INT = 0
DECLARE @ResultMessage NVARCHAR(255)

BEGIN TRY
    -- Stap 1: Haal huidige LastUpdatedOn op
    SELECT @OldUpdatedOn = CONVERT(NVARCHAR(30), LastUpdatedOn, 109),
			@ProdBOOLineNr = ProdBOOLineNr
    FROM T_ProdBillOfOper
    WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
      AND LineNr = @LineNr;

	      IF @OldUpdatedOn IS NULL
        SET @OldUpdatedOn = '2000-01-01 00:00:00.000'

    -- Stap 2: Reserveer memo ID
exec [dbo].[IP_Del_ProdBOO] @ProdHeaderDossierCode,@ProdBOOLineNr,@OldUpdatedOn,N'RPA',950000

    SET @ResultCode = 1
    SET @ResultMessage = 'Bewerkingsregel ' + CAST(@LineNr AS NVARCHAR) + ' succesvol verwijderd van PD: ' + @ProdHeaderDossierCode
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    SET @ResultCode = 0
    SET @ResultMessage = ERROR_MESSAGE()
    ROLLBACK TRANSACTION
END CATCH

-- Output
SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;