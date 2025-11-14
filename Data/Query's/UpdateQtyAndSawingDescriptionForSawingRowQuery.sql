BEGIN TRANSACTION;

-- Invoervariabelen
DECLARE @ProdHeaderDossierCode NVARCHAR(50) = N'{ProdHeaderDossierCode}';
DECLARE @NewProdBOOPartDescription NVARCHAR(50) = N'{NewProdBOOPartDescription}';
DECLARE @ProdBOOLineNr INT;
DECLARE @QuantityStaf INT = {QuantityStaf};

-- Variabelen
DECLARE @LastUpdatedTime NVARCHAR(50);
DECLARE @ResultCode INT = 0;
DECLARE @ResultMessage NVARCHAR(255);

-- Ophalen huidige LastUpdatedTime uit de database
SELECT	top 1 @LastUpdatedTime = LastUpdatedOn,
		@ProdBOOLineNr = ProdBOOLineNr
FROM dbo.T_ProdBillOfOper
WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
AND MachGrpCode = 'ZG'
order by ProdBOOLineNr;

-- Check of gevonden
IF @LastUpdatedTime IS NULL
BEGIN
    SET @ResultCode = 0;
    SET @ResultMessage = 'LastUpdatedOn niet gevonden.';
    ROLLBACK TRANSACTION;
    SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;
    RETURN;
END

-- Try update uitvoeren
BEGIN TRY
    EXEC [dbo].[IP_Upd_ProdBOO] 
        @old_ProdHeaderDossierCode = @ProdHeaderDossierCode,
        @old_ProdBOOLineNr = @ProdBOOLineNr,
        @old_LastUpdatedOn = @LastUpdatedTime,
        @ProdHeaderDossierCode = @ProdHeaderDossierCode,
        @ProdBOOLineNr = @ProdBOOLineNr,
        @ScriptListCode = NULL,
        @MachGrpCode = NULL,
        @MachCode = NULL,
        @PlanGrpCode = NULL,
        @ProdBOOStatusCode = NULL,
        @LineNr = NULL,
        @ProdBOOPartDescription = @NewProdBOOPartDescription,
        @UnitDescription = NULL,
        @Qty = @QuantityStaf,
        @MachCycleTime = NULL,
        @MachCycleTimeDefInd = NULL,
        @MachSetupTime = NULL,
        @MachSetoffTime = NULL,
        @OccupationSetupTime = NULL,
        @OccupationSetoffTime = NULL,
        @OccupationCycleTime = NULL, 
        @StartDate = NULL,
        @StartTime = NULL,
        @EndDate = NULL,
        @LeadTime = NULL,
        @PriorityId = NULL,
        @ProdStartedInd = NULL,
        @StandCapacity = NULL,
        @StandCapacityType = NULL,
        @ProdBOMPhantomLineNr = NULL,
        @FinishedInd = NULL,
        @FinishedDate = NULL,
        @ProducedQty = NULL,
        @InfoType = NULL,
        @Info = NULL,
        @IsahUserCode = N'RPA',
        @LogProgramCode = 950000,
        @SchedulingFactor = NULL,
        @PlanningBasedOnType = NULL,
        @PlanningType = NULL,
        @PlanningInOneTimeSlotInd = NULL,
        @PlanningConstraintType = NULL,
        @PlanningConstraintDate = NULL,
        @StandLeadTime = NULL,
        @MachPlanTime = NULL,
        @OccupationPlanTime = NULL,
        @ProgressPercentage = NULL,
        @StartDateActual = NULL,
        @EndDateActual = NULL,
        @PlanSetting = NULL,
        @EmpId = NULL,
        @UpdateRelatedDatesInd = 1,
        @MemoGrpId = NULL,
        @Tag = NULL,
        @New_MachCycleTime = NULL,
        @New_OccupationCycleTime = NULL,
        @LastUpdatedOn = NULL;

    SET @ResultCode = 1;
    SET @ResultMessage = 'Staf aantal en lengte succesvol aangepast/toegevoegd voor PD ' + @ProdHeaderDossierCode + ', regel ' + CAST(@ProdBOOLineNr AS NVARCHAR);
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ResultCode = 0;
    SET @ResultMessage = ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH

SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;
