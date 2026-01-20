SELECT ph.ProdStatusCode,
CASE 
	WHEN ph.ProdStatusCode > 41 
		THEN 1 
		ELSE 0 
	END AS [AlreadyProcessed]

FROM [T_ProductionHeader] ph
WHERE ph.ProdHeaderDossierCode = '{ProdHeaderDossierCode}'
