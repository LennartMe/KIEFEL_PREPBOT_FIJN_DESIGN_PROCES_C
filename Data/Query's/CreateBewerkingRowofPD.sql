BEGIN TRANSACTION;

-- Invoervariabelen
DECLARE @ProdHeaderDossierCode NVARCHAR(4000) = N'{ProdHeaderDossierCode}' -- PD to update
DECLARE @LineNr INT = {LineNr} -- LineNr voor bewerking
DECLARE @MachGrpCode NVARCHAR(50) = N'{MachGrpCode}';
DECLARE @ProdBOOLineNr INT;

-- Variabelen
DECLARE @new_ProdBOOLineNr INT;
DECLARE @ResultCode INT = 0;
DECLARE @ResultMessage NVARCHAR(255);


-- Try update uitvoeren
BEGIN TRY

EXEC [dbo].[IP_Ins_ProdBOO]
    @ProdHeaderDossierCode         = @ProdHeaderDossierCode,
    @new_ProdBOOLineNr             = @new_ProdBOOLineNr OUTPUT,
    @ScriptListCode                = N'',
    @MachGrpCode                   = @MachGrpCode,
    @MachCode                      = N'',
    @PlanGrpCode                   = N'',
    @ProdBOOStatusCode             = N'30',
    @LineNr                        = @LineNr,
    @ProdBOOPartDescription        = N'',
    @UnitDescription               = N'',
    @Qty                           = 0,
    @machCycleTime                 = 0,
    @MachSetupTime                 = 0,
    @MachSetoffTime                = 0,
    @OccupationSetupTime           = 0,
    @OccupationSetoffTime          = 0,
    @OccupationCycleTime           = 0,
    @LeadTime                      = 0,
    @PriorityId                    = 0,
    @StandCapacity                 = 0,
    @StandCapacityType             = 2,
    @ProducedQty                   = 0,
    @ProdBOMPhantomLineNr          = 0,
    @SchedulingFactor              = 50400,
    @PlanningBasedOnType           = 1,
    @PlanningType                  = 1,
    @PlanningInOneTimeSlotInd      = 0,
    @PlanningConstraintType        = 0,
    @StandLeadTime                 = 1,
    @MachPlanTime                  = 0,
    @OccupationPlanTime            = 0,
    @ProgressPercentage            = 0,
    @PlanSetting                   = N'950000',
    @MemoGrpId                     = 0,
    @LogProgramCode                = 0,
    @IsahUserCode                  = N'RPA'


    SET @ResultCode = 1;
    SET @ResultMessage = 'ProdBOOLineNr ' + CAST(@new_ProdBOOLineNr AS NVARCHAR) + ' met LineNr ' +  CAST(@LineNr AS NVARCHAR) + ' voor PD '+ @ProdHeaderDossierCode + ' succesvol aangemaakt.' ;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SET @ResultCode = 0;
    SET @ResultMessage = ERROR_MESSAGE();
    ROLLBACK TRANSACTION;
END CATCH

SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;
