BEGIN TRANSACTION;

-- Invoervariabelen
DECLARE @ProdHeaderDossierCode NVARCHAR(50) = N'0000216388';
DECLARE @LineNr INT = 25;
DECLARE @Current_ProdBOOLineNr INT;
DECLARE @Current_ProdBOOPartDescription NVARCHAR(50);
DECLARE @Current_Quantity NVARCHAR(50);
DECLARE @Previous_ProdBOOLineNr_To_Be INT;
DECLARE @Previous_ProdBOOPartDescription NVARCHAR(50);
DECLARE @Previous_Quantity NVARCHAR(50);
DECLARE @Next_ProdBOOLineNr_To_Be INT;
DECLARE @ProdRoutingLineNr INT;


DECLARE @tussenvoegenstring varchar(255) = 'True';
DECLARE @tussenvoegen int
IF @tussenvoegenstring = 'True'
BEGIN
    SET @tussenvoegen = 1;
END
IF @tussenvoegenstring = 'False'
BEGIN
    SET @tussenvoegen = 0;
END

-- Variabelen
DECLARE @LastUpdatedTime NVARCHAR(50);
DECLARE @ResultCode INT = 0;
DECLARE @ResultMessage NVARCHAR(255);


-- Try update uitvoeren
BEGIN TRY



SELECT 
@Previous_ProdBOOLineNr_To_Be = [Previous_ProdBOOLineNr_To_Be],

@Current_ProdBOOLineNr =  [Current_ProdBOOLineNr],
@Current_Quantity = [Current_Quantity],
@Current_ProdBOOPartDescription = [Current_ProdBOOPartDescription],

@Next_ProdBOOLineNr_To_Be = [Next_ProdBOOLineNr_To_Be]
FROM

(SELECT 
	CASE WHEN @tussenvoegen = 1 
			THEN 
			(SELECT top 1 pboo.ProdBOOLineNr
			FROM T_ProdBillOfOper pboo
			WHERE 1=1
			AND pboo.ProdHeaderDossierCode = @ProdHeaderDossierCode
			AND pboo.LineNr < @LineNr
			order by pboo.linenr desc)
			ELSE prprevious.ProdBOOLineNr END AS [Previous_ProdBOOLineNr_To_Be],

	pboo.prodboolinenr [Current_ProdBOOLineNr],
	pboo.ProdBOOPartDescription [Current_ProdBOOPartDescription], 
	pboo.Qty [Current_Quantity],

		(SELECT top 1 pboo.ProdBOOLineNr
		FROM T_ProdBillOfOper pboo
		WHERE 1=1
		AND pboo.ProdHeaderDossierCode = @ProdHeaderDossierCode
		AND pboo.LineNr > @LineNr
		order by pboo.linenr asc) as [Next_ProdBOOLineNr_To_Be] 


	FROM T_ProdBillOfOper pboo
	--LEFT JOIN T_ProductionRouting prnext on prnext.ProdHeaderDossierCode = pboo.ProdHeaderDossierCode and prnext.ProdBOOLineNr = pboo.ProdBOOLineNr
	--LEFT JOIN T_ProdBillOfOper prnextinfo on prnext.ProdHeaderDossierCode = prnextinfo.ProdHeaderDossierCode and prnext.ToBOOLineNr = prnextinfo.ProdBOOLineNr
	LEFT JOIN T_ProductionRouting prprevious on prprevious.ProdHeaderDossierCode = pboo.ProdHeaderDossierCode and prprevious.ToBOOLineNr = pboo.ProdBOOLineNr
	LEFT JOIN T_ProdBillOfOper prpreviousinfo on prprevious.ProdHeaderDossierCode = prpreviousinfo.ProdHeaderDossierCode and prprevious.ProdBOOLineNr = prpreviousinfo.ProdBOOLineNr
	--LEFT JOIN T_ProductionHeader ph on ph.ProdHeaderDossierCode = pboo.ProdHeaderDossierCode
	--LEFT JOIN T_BillOfOper DUMMY on DUMMY.PartCode = ph.partcode and DUMMY.BOOLineNr = pboo.ProdBOOLineNr
WHERE 1=1 
AND pboo.ProdHeaderDossierCode = @ProdHeaderDossierCode
AND pboo.LineNr = @LineNr
AND pboo.ProdHeaderDossierCode <> ''
) sub

If @tussenvoegen = 1
BEGIN

SELECT	@LastUpdatedTime = LastUpdatedOn
FROM dbo.T_ProductionRouting
WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
AND ProdBOOLineNr = @Previous_ProdBOOLineNr_To_Be

SELECT @ProdRoutingLineNr = MAX(ProdRoutingLineNr)+1 FROM T_ProductionRouting
  WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode

IF @ProdRoutingLineNr IS NULL
BEGIN
    SET @ProdRoutingLineNr = 1;
END

SELECT

	@Previous_ProdBOOPartDescription = pboo.ProdBOOPartDescription, 
	@Previous_Quantity = pboo.Qty 

	FROM T_ProdBillOfOper pboo

WHERE 1=1 
AND pboo.ProdHeaderDossierCode = @ProdHeaderDossierCode
AND pboo.ProdBOOLineNr = @Previous_ProdBOOLineNr_To_Be
AND pboo.ProdHeaderDossierCode <> ''

IF @Previous_ProdBOOPartDescription IS NULL
BEGIN
    SET @Previous_ProdBOOPartDescription = N'';
END

    EXEC [dbo].[IP_Ins_ProdRouting] 
   @ProdBOOLineNr = @Previous_ProdBOOLineNr_To_Be,  
   @ProdHeaderDossierCode = @ProdHeaderDossierCode,  
   @ProdRoutingLineNr = @ProdRoutingLineNr,  
   @ToBOOLineNr = @current_ProdBOOLineNr,  
   @Qty = @Previous_Quantity,  
   @BOOPartDescription = @Previous_ProdBOOPartDescription,  
   @ProdBOMPhantomLineNr = 0,  
   @OverlapPerc  = 0,  
   @TransportTime = 0,  
   @WaitTimeBefore = 0,  
   @WaitTimeAfter  = 0, 
   @LastUpdatedOn  = @LastUpdatedTime  OUTPUT,  
   @IsahUserCode = N'RPA',  
   @LogProgramCode = 980000 
END

-- Ophalen huidige LastUpdatedTime uit de database
SELECT
		@Current_ProdBOOLineNr = ProdBOOLineNr
FROM dbo.T_ProdBillOfOper
WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
AND LineNr = @LineNr

SELECT	@LastUpdatedTime = LastUpdatedOn
FROM dbo.T_ProductionRouting
WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
AND ProdBOOLineNr = @Current_ProdBOOLineNr

SELECT @ProdRoutingLineNr = MAX(ProdRoutingLineNr)+1 FROM T_ProductionRouting
  WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode

IF @ProdRoutingLineNr IS NULL
BEGIN
    SET @ProdRoutingLineNr = 1;
END

-- Check of gevonden
IF @LastUpdatedTime IS NULL
BEGIN
    SET @LastUpdatedTime = '2001';
END

IF @Current_ProdBOOPartDescription IS NULL
BEGIN
    SET @Current_ProdBOOPartDescription = N'';
END

    EXEC [dbo].[IP_Ins_ProdRouting] 
   @ProdBOOLineNr = @Current_ProdBOOLineNr,  
   @ProdHeaderDossierCode = @ProdHeaderDossierCode,  
   @ProdRoutingLineNr = @ProdRoutingLineNr,  
   @ToBOOLineNr = @Next_ProdBOOLineNr_To_Be,  
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
    SET @ResultMessage = 'Bewerking regel ' + CAST(@LineNr AS NVARCHAR) + ' voor PD '+ @ProdHeaderDossierCode + ' succesvol Tussengevoegd.' ;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ResultCode = 0;
    SET @ResultMessage = ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH

SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;



SELECT * FROM T_ProductionRouting
  WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode


--exec [dbo].[IP_Del_ProdRouting]
--@ProdHeaderDossierCode = N'0000216388',
--@Current_ProdBOOLineNr = 5, 
--@LogProgramCode = 980000,
--@LastUpdatedTime = N'May 21 2025  6:07:57:600AM',
--@IsahUserCode = N'RPA',