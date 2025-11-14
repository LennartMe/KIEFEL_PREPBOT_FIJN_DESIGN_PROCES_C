DECLARE @ProdHeaderDossierCode varchar(255)
SET @ProdHeaderDossierCode = '{Prodheaderdossiercode}';

SELECT DISTINCT
--Case when Previous_LineNr IS NOT NULL and Next_LineNr IS NOT NULL Then 'True' ELSE 'False' end as [Tussenvoegen],
LineNr, Next_LineNr,Next_LineNr2,MachGrpCode,ProdBOOPartDescription,Qty,MachineUren,Manuren,[Memo]
FROM (


SELECT 
	prpreviousinfo.LineNr [Previous_LineNr],
	pboo.linenr, 
	MIN(prnextinfo.LineNr) OVER (PARTITION BY pboo.LineNr) AS Next_LineNr, 
	Case WHEN MIN(prnextinfo.LineNr) OVER (PARTITION BY pboo.LineNr) <> MAX(prnextinfo.LineNr) OVER (PARTITION BY pboo.LineNr) THEN MAX(prnextinfo.LineNr) OVER (PARTITION BY pboo.LineNr) END AS Next_LineNr2,
	prprevious.ProdBOOLineNr [Previous_prodBOOLineNr],
	pboo.prodboolinenr,
	prnext.ToBOOLineNr [Next_ProdBOOLineNr],
	pboo.MachGrpCode, 
	pboo.ProdBOOPartDescription, 
	pboo.Qty, 
	FORMAT(CAST((pboo.MachCycleTime/3600) as decimal(10,3)), 'N2', 'nl-NL') [MachineUren], 
	FORMAT(CAST((pboo.OccupationCycleTime/3600) as decimal(10,3)), 'N2', 'nl-NL') [Manuren],
	pboo.info [Memo]

	FROM T_ProdBillOfOper pboo
	LEFT JOIN T_ProductionRouting prnext on prnext.ProdHeaderDossierCode = pboo.ProdHeaderDossierCode and prnext.ProdBOOLineNr = pboo.ProdBOOLineNr
	LEFT JOIN T_ProdBillOfOper prnextinfo on prnext.ProdHeaderDossierCode = prnextinfo.ProdHeaderDossierCode and prnext.ToBOOLineNr = prnextinfo.ProdBOOLineNr
	LEFT JOIN T_ProductionRouting prprevious on prprevious.ProdHeaderDossierCode = pboo.ProdHeaderDossierCode and prprevious.ToBOOLineNr = pboo.ProdBOOLineNr
	LEFT JOIN T_ProdBillOfOper prpreviousinfo on prprevious.ProdHeaderDossierCode = prpreviousinfo.ProdHeaderDossierCode and prprevious.ProdBOOLineNr = prpreviousinfo.ProdBOOLineNr
WHERE pboo.ProdHeaderDossierCode = @ProdHeaderDossierCode
AND pboo.ProdHeaderDossierCode <> '') sub