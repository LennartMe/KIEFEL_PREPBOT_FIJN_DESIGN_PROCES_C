DECLARE @ProdHeaderDossierCode varchar(255)
SET @ProdHeaderDossierCode = '{ProdHeaderDossierCode}';

SELECT *,
	CAST(MachineUrenNewRaw * 3600 AS int) AS MachineUrenNewInSec,
	CAST(ManUrenNewRaw * 3600 AS int) AS ManUrenNewInSec
FROM (
	SELECT
		m.ProdHeaderDossierCode,
		m.ProdBOOLineNr,
		m.MachGrpCode,
		CASE 
			WHEN m.MachCode = '     ' THEN ''
			ELSE m.Machcode 
		END AS MachcodeOld,
		'' AS MachcodeNew,

		FORMAT(CAST((m.MachCycleTime / 3600) AS decimal(10,3)), 'N2', 'nl-NL') AS MachineUrenOld,

		-- MachineUrenNew RAW
		CAST(
			CASE 
				WHEN (((mr.MachCycleTime/mr.Qty)*m.Qty) / 3600) = 0 THEN 0
				WHEN (((mr.MachCycleTime/mr.Qty)*m.Qty) / 3600) <= 0.15 THEN 0.1
				WHEN (((mr.MachCycleTime/mr.Qty)*m.Qty) / 3600) < 0.25 THEN 0.2
				ELSE ROUND((((mr.MachCycleTime/mr.Qty)*m.Qty) / 3600) * 4.0, 0) / 4.0
			END AS decimal(10,3)
		) AS MachineUrenNewRaw,

		-- MachineUrenNew FORMAT
		FORMAT(
			CAST(
				CASE 
					WHEN (((mr.MachCycleTime/mr.Qty)*m.Qty) / 3600) = 0 THEN 0
					WHEN (((mr.MachCycleTime/mr.Qty)*m.Qty) / 3600) <= 0.15 THEN 0.1
					WHEN (((mr.MachCycleTime/mr.Qty)*m.Qty) / 3600) < 0.25 THEN 0.2
					ELSE ROUND((((mr.MachCycleTime/mr.Qty)*m.Qty) / 3600) * 4.0, 0) / 4.0
				END AS decimal(10,3)
			), 'N2', 'nl-NL'
		) AS MachineUrenNew,

		-- Gemiddelde machine uren
		(SELECT FORMAT(CAST((AVG(s1.MachCycleTime) / 3600) AS decimal(10,3)), 'N2', 'nl-NL') 
		 FROM [T_ProdBillOfOper] s1
		 WHERE s1.MachGrpCode = m.MachGrpCode 
		   AND s1.ProdBOOLineNr = m.ProdBOOLineNr 
		   AND s1.Qty = m.Qty 
		   AND s1.PlanningBasedOnType = m.PlanningBasedOnType 
		   AND s1.StartDate > GETDATE() - 365
		 GROUP BY s1.MachGrpCode, s1.ProdBOOLineNr, s1.Qty, s1.PlanningBasedOnType) AS AVG_MachineUren,

		-- Oude manuren
		FORMAT(CAST((m.OccupationCycleTime / 3600) AS decimal(10,3)), 'N2', 'nl-NL') AS ManUrenOld,

		-- ManUrenNew RAW
		CAST(
			CASE 
				WHEN (((mr.OccupationCycleTime/mr.Qty)*m.Qty) / 3600) = 0 THEN 0
				WHEN (((mr.OccupationCycleTime/mr.Qty)*m.Qty) / 3600) <= 0.15 THEN 0.1
				WHEN (((mr.OccupationCycleTime/mr.Qty)*m.Qty) / 3600) < 0.25 THEN 0.2
				ELSE ROUND((((mr.OccupationCycleTime/mr.Qty)*m.Qty) / 3600) * 4.0, 0) / 4.0
			END AS decimal(10,3)
		) AS ManUrenNewRaw,

		-- ManUrenNew FORMAT
		FORMAT(
			CAST(
				CASE 
					WHEN (((mr.OccupationCycleTime/mr.Qty)*m.Qty) / 3600) = 0 THEN 0
					WHEN (((mr.OccupationCycleTime/mr.Qty)*m.Qty) / 3600) <= 0.15 THEN 0.1
					WHEN (((mr.OccupationCycleTime/mr.Qty)*m.Qty) / 3600) < 0.25 THEN 0.2
					ELSE ROUND((((mr.OccupationCycleTime/mr.Qty)*m.Qty) / 3600) * 4.0, 0) / 4.0
				END AS decimal(10,3)
			), 'N2', 'nl-NL'
		) AS ManUrenNew,

		-- Gemiddelde manuren
		(SELECT FORMAT(CAST((AVG(s2.OccupationCycleTime) / 3600) AS decimal(10,3)), 'N2', 'nl-NL') 
		 FROM [T_ProdBillOfOper] s2
		 WHERE s2.MachGrpCode = m.MachGrpCode 
		   AND s2.ProdBOOLineNr = m.ProdBOOLineNr 
		   AND s2.Qty = m.Qty 
		   AND s2.PlanningBasedOnType = m.PlanningBasedOnType 
		   AND s2.StartDate > GETDATE() - 365
		 GROUP BY s2.MachGrpCode, s2.ProdBOOLineNr, s2.Qty, s2.PlanningBasedOnType) AS AVG_ManUren,

		m.PlanningBasedOnType,
		CASE 
			WHEN m.PlanningBasedOnType = 2 THEN 'ManUren' 
			WHEN m.PlanningBasedOnType = 1 THEN 'MachineUren' 
			ELSE '' 
		END AS SoortUren

	FROM [T_ProdBillOfOper] m
	INNER JOIN [T_ProdBillOfOper] mr 
		ON mr.ProdBOOLineNr = m.ProdBOOLineNr
		AND mr.ProdHeaderDossierCode = @ProdHeaderDossierCode
	WHERE m.ProdHeaderDossierCode = @ProdHeaderDossierCode
) q2
ORDER BY ProdBOOLineNr;
