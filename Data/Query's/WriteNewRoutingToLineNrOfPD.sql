BEGIN TRANSACTION;

-- Invoervariabelen
DECLARE @ProdHeaderDossierCode NVARCHAR(50) = N'{ProdHeaderDossierCode}';
DECLARE @Current_LineNr INT = {LineNr};
DECLARE @Next_LineNr INT = {Next_LineNr};

-- Variabelen
DECLARE @LastUpdatedTime NVARCHAR(50);
DECLARE @ResultCode INT = 0;
DECLARE @ResultMessage NVARCHAR(255);

DECLARE @Current_ProdBOOLineNr INT;
DECLARE @Current_ProdBOOPartDescription NVARCHAR(50);
DECLARE @Current_Quantity NVARCHAR(50);

DECLARE @Next_ProdBOOLineNr INT;

DECLARE @ProdRoutingLineNr INT;

--vul variabel data
SELECT	@LastUpdatedTime = LastUpdatedOn
FROM dbo.T_ProductionRouting
WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
AND ProdBOOLineNr = @Current_ProdBOOLineNr

IF @LastUpdatedTime IS NULL
BEGIN
    SET @LastUpdatedTime = '2001';
END

SELECT  @Current_ProdBOOLineNr = pboo.ProdBOOLineNr,
		@Current_ProdBOOPartDescription = pboo.ProdBOOPartDescription,
		@Current_Quantity = pboo.Qty
		FROM T_ProdBillOfOper pboo
		WHERE 1=1
		AND pboo.ProdHeaderDossierCode = @ProdHeaderDossierCode
		AND pboo.LineNr = @Current_LineNr 

SELECT  @Next_ProdBOOLineNr = pboo.ProdBOOLineNr
		FROM T_ProdBillOfOper pboo
		WHERE 1=1
		AND pboo.ProdHeaderDossierCode = @ProdHeaderDossierCode
		AND pboo.LineNr = @Next_LineNr 

SELECT @ProdRoutingLineNr = MAX(ProdRoutingLineNr)+1 FROM T_ProductionRouting
		WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode

IF @ProdRoutingLineNr IS NULL
BEGIN
    SET @ProdRoutingLineNr = 1;
END


IF @Current_ProdBOOPartDescription IS NULL
BEGIN
    SET @Current_ProdBOOPartDescription = N'';
END

-- Try update uitvoeren

BEGIN TRY

    EXEC [dbo].[IP_Ins_ProdRouting] 
   @ProdBOOLineNr = @Current_ProdBOOLineNr,  
   @ProdHeaderDossierCode = @ProdHeaderDossierCode,  
   @ProdRoutingLineNr = @ProdRoutingLineNr,  
   @ToBOOLineNr = @Next_ProdBOOLineNr,  
   @Qty = @Current_Quantity,  
   @BOOPartDescription = @Current_ProdBOOPartDescription,  
   @ProdBOMPhantomLineNr = 0,  
   @OverlapPerc  = 0,  
   @TransportTime = 0,  
   @WaitTimeBefore = 0,  
   @WaitTimeAfter  = 0, 
   @LastUpdatedOn  = @LastUpdatedTime  OUTPUT,  
   @IsahUserCode = N'RPA',  
   @LogProgramCode = 980000 

    SET @ResultCode = 1;
    SET @ResultMessage = 'Bewerking regel ' + CAST(@Current_LineNr AS NVARCHAR) + ' voor PD '+ @ProdHeaderDossierCode + ' succesvol gekoppeld aan bewerking regel ' + CAST(@Next_LineNr AS NVARCHAR) ;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ResultCode = 0;
    SET @ResultMessage = ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH

SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;