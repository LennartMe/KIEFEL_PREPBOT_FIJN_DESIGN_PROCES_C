BEGIN TRANSACTION;

-- Invoervariabelen
DECLARE @ProdHeaderDossierCode NVARCHAR(50) = N'{ProdHeaderDossierCode}';
DECLARE @LineNr INT = {LineNr};
DECLARE @MachGrpCode NVARCHAR(50) = N'{MachGrpCode}';
DECLARE @ProdBOOPartDescription NVARCHAR(50) = N'{ProdBOOPartDescription}'
DECLARE @Quantity NVARCHAR(50) = N'{Quantity}'
DECLARE @MachineUren NVARCHAR(50) = N'{MachineUren}'
DECLARE @ManUren NVARCHAR(50) = N'{ManUren}'
DECLARE @ProdBOOLineNr INT;

-- Variabelen
DECLARE @LastUpdatedTime NVARCHAR(50);
DECLARE @ResultCode INT = 0;
DECLARE @ResultMessage NVARCHAR(255);

-- Ophalen huidige LastUpdatedTime uit de database
SELECT	@LastUpdatedTime = LastUpdatedOn,
		@ProdBOOLineNr = ProdBOOLineNr
FROM dbo.T_ProdBillOfOper
WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
AND LineNr = @LineNr;

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
        @MachGrpCode = @MachGrpCode,
        @MachCode = '',
        @PlanGrpCode = NULL,
        @ProdBOOStatusCode = NULL,
        @LineNr = NULL,
        @ProdBOOPartDescription = @ProdBOOPartDescription,
        @UnitDescription = NULL,
        @Qty = @Quantity,
        @MachCycleTime = @MachineUren,
        @MachCycleTimeDefInd = NULL,
        @MachSetupTime = NULL,
        @MachSetoffTime = NULL,
        @OccupationSetupTime = NULL,
        @OccupationSetoffTime = NULL,
        @OccupationCycleTime = @ManUren, 
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
    SET @ResultMessage = 'Bewerking regel ' + CAST(@LineNr AS NVARCHAR) + ' voor PD '+ @ProdHeaderDossierCode + ' succesvol aangepast.' ;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ResultCode = 0;
    SET @ResultMessage = ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH

SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;
