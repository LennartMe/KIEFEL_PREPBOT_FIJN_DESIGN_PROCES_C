BEGIN TRANSACTION

DECLARE @ProdHeaderDossierCode NVARCHAR(50) = '0000216388';
DECLARE @LineNr INT = 25;
DECLARE @PreviousLineNr INT;
DECLARE @ProdBOOLineNr INT;
DECLARE @ProdRoutingLineNr INT;
DECLARE @LastUpdatedTime NVARCHAR(50);
DECLARE @ResultCode INT = 0;
DECLARE @ResultMessage NVARCHAR(255);

BEGIN TRY

SELECT top 1 @ProdBOOLineNr = pboo.ProdBOOLineNr,
			@PreviousLineNr = pboo.LineNr
			FROM T_ProdBillOfOper pboo
			WHERE 1=1
			AND pboo.ProdHeaderDossierCode = @ProdHeaderDossierCode
			AND pboo.LineNr < @LineNr
			order by pboo.linenr desc

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
        -- logica per ProdRoutingLineNr
        PRINT '  Delete ProdRoutingLineNr: ' + CAST(@ProdRoutingLineNr AS NVARCHAR);
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

        FETCH NEXT FROM ProdRoutingLineNrCursor INTO @ProdRoutingLineNr;
    END;

    CLOSE ProdRoutingLineNrCursor;
    DEALLOCATE ProdRoutingLineNrCursor;

SET @ResultCode = 1;
    SET @ResultMessage = 'volgende Bewerking regel ontkoppeld van vorige Bewerking regel: ' + CAST(@PreviousLineNr AS NVARCHAR) + ' in PD: '+ @ProdHeaderDossierCode
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ResultCode = 0;
    SET @ResultMessage = ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH

SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;