BEGIN TRANSACTION;

DECLARE @ProdHeaderDossierCode NVARCHAR(50) = '{ProdHeaderDossierCode}';
DECLARE @ProdBOOLineNr INT;
DECLARE @ProdRoutingLineNr INT;
DECLARE @LastUpdatedTime NVARCHAR(50);
DECLARE @ResultCode INT = 0;
DECLARE @ResultMessage NVARCHAR(255) = '';

-- Eerst cursor voor alle ProdBOOLineNr
BEGIN TRY

DECLARE ProdBOOLineNrCursor CURSOR FOR
SELECT DISTINCT ProdBOOLineNr
FROM T_ProductionRouting 
WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode;

OPEN ProdBOOLineNrCursor;
FETCH NEXT FROM ProdBOOLineNrCursor INTO @ProdBOOLineNr;

WHILE @@FETCH_STATUS = 0
BEGIN
    --PRINT 'Start verwerking voor ProdBOOLineNr: ' + CAST(@ProdBOOLineNr AS NVARCHAR);

    -- Binnenste cursor per ProdBOOLineNr: alle ProdRoutingLineNr ophalen
    DECLARE ProdRoutingLineNrCursor CURSOR FOR
    SELECT ProdRoutingLineNr
    FROM T_ProductionRouting
    WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
      AND ProdBOOLineNr = @ProdBOOLineNr;

    OPEN ProdRoutingLineNrCursor;
    FETCH NEXT FROM ProdRoutingLineNrCursor INTO @ProdRoutingLineNr;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Hier kun je je logica doen per ProdRoutingLineNr
        
		SELECT @LastUpdatedTime = LastUpdatedOn 
		FROM T_ProductionRouting WHERE 1=1
		AND	ProdHeaderDossierCode = @ProdHeaderDossierCode
		AND ProdBOOLineNr = @ProdBOOLineNr 
		AND ProdRoutingLineNr = @ProdRoutingLineNr
        -- Bijvoorbeeld:
        exec [dbo].[IP_Del_ProdRouting]
		@old_ProdHeaderDossierCode = @ProdHeaderDossierCode,
		@old_ProdBOOLineNr = @ProdBOOLineNr,
		@old_ProdRoutingLineNr = @ProdRoutingLineNr, 
		@LogProgramCode = 980000,
		@old_LastUpdatedOn = @lastUpdatedTime,
		@IsahUserCode = N'RPA' 

		SET @ResultMessage = @ResultMessage + '  Deleted ProdRoutingLineNr: ' + CAST(@ProdRoutingLineNr AS NVARCHAR) + ' van ProdBOOLineNr: ' + CAST(@ProdBOOLineNr AS NVARCHAR);

        FETCH NEXT FROM ProdRoutingLineNrCursor INTO @ProdRoutingLineNr;
    END;

    CLOSE ProdRoutingLineNrCursor;
    DEALLOCATE ProdRoutingLineNrCursor;

    FETCH NEXT FROM ProdBOOLineNrCursor INTO @ProdBOOLineNr;
END;

CLOSE ProdBOOLineNrCursor;
DEALLOCATE ProdBOOLineNrCursor;
SET @ResultCode = 1
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ResultCode = 0;
    SET @ResultMessage = ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH

SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;