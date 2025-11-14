DECLARE @ProdHeaderDossierCode varchar(255)
SET @ProdHeaderDossierCode = '{Prodheaderdossiercode}';

SELECT
	d.OrdNr,
	bm.ProdHeaderDossierCode [HeadPD],
	phmain.PartCode [HeadPD_Partcode],
	P.ClassNr,
	bm.ProdBOMLineNr,
	PHPBL.ProdHeaderDossierCode,
	bm.Description,
	--phmain.DesignCode,
	--phsub.DesignCode,
	'https://www.orimi.com/pdf-test.pdf' [DocPathName]
  FROM [T_prodbillofmat] bm
	--Head PD info:
	LEFT JOIN  [T_ProductionHeader] PHmain on PHmain.prodheaderdossiercode = bm.prodheaderdossiercode
	LEFT JOIN [T_DossierMain] d on PHmain.DossierCode = d.DossierCode
	--PD Info:
	LEFT JOIN [T_ProdHeadProdBOMLink] PHPBL on (bm.prodBomLineNr = PHPBL.ProdBomLineNr AND bm.prodheaderdossiercode = PHPBL.ProdBOMprodheaderdossiercode)
	LEFT JOIN [T_ProductionHeader] PHsub on PHsub.prodheaderdossiercode = PHPBL.prodheaderdossiercode
	LEFT JOIN [T_Part] p on p.PartCode = PHmain.PartCode
  WHERE 1=1
  AND PHPBL.ProdHeaderDossierCode = @ProdHeaderDossierCode