BEGIN TRANSACTION;

-- Invoervariabelen
DECLARE @ProdHeaderDossierCode NVARCHAR(50) = N'{ProdHeaderDossierCode}';
DECLARE @ProdBOOLineNr INT = {ProdBOOLineNr};
DECLARE @ProdRoutingLineNr INT = {ProdRoutingLineNr};

DECLARE @ResultCode INT = 0;
DECLARE @ResultMessage NVARCHAR(255);


-- Try update uitvoeren
BEGIN TRY

Exec RS072_Set_PlanOper  @IsahUserCode  = 'RPA' , @ScriptCode  = 'RS072'  ,@ProdHeaderDossierCode = @ProdHeaderDossierCode  ,@ProdBoolineNr         = @ProdBOOLineNr  ,@DaysBuff	         = 2  ,@ProdRoutingLineNr	 = @ProdRoutingLineNr

    SET @ResultCode = 1;
    SET @ResultMessage = 'ProdbooLinenr ' + CAST(@ProdBoolineNr AS NVARCHAR) + ' voor PD '+ @ProdHeaderDossierCode + ' succesvol geupdate met 2 bufferuren.' ;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ResultCode = 0;
    SET @ResultMessage = ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH

SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;
