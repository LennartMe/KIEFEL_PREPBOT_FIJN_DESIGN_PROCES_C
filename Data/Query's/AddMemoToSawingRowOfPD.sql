BEGIN TRANSACTION;

DECLARE @ProdHeaderDossierCode NVARCHAR(4000) = N'{ProdHeaderDossierCode}' -- PD to update
DECLARE @ProdBOOLineNr INT -- ProdBOOLineNr to update memo
DECLARE @NewMemoText NVARCHAR(4000) = N'{NewMemoText}' -- Nieuwe Memo
DECLARE @MemoText NVARCHAR(4000); 

DECLARE @OldUpdatedOn NVARCHAR(30)
DECLARE @LastUpdatedOn NVARCHAR(30) = CONVERT(NVARCHAR(30), GETDATE(), 120)
DECLARE @ResultCode INT = 0
DECLARE @ResultMessage NVARCHAR(255)

BEGIN TRY
    -- Stap 1: Haal huidige LastUpdatedOn op
SELECT	top 1 @OldUpdatedOn = LastUpdatedOn,
		@ProdBOOLineNr = ProdBOOLineNr,
		@MemoText = Info
FROM dbo.T_ProdBillOfOper
WHERE ProdHeaderDossierCode = @ProdHeaderDossierCode
AND MachGrpCode = 'ZG'
order by ProdBOOLineNr;

--Replace existing Mat.% while keeping the memo.
SET @MemoText = ISNULL(@MemoText, '');
DECLARE @MemoLF nvarchar(max)   = REPLACE(@MemoText, CHAR(13), '');
IF RIGHT(@MemoLF,1) <> CHAR(10) SET @MemoLF += CHAR(10);


DECLARE @NewLine nvarchar(max) = REPLACE(@NewMemoText, CHAR(13), '');
IF CHARINDEX(CHAR(10), @NewLine) > 0
    SET @NewLine = LEFT(@NewLine, CHARINDEX(CHAR(10), @NewLine)-1);
SET @NewLine = LTRIM(RTRIM(@NewLine));


IF CHARINDEX(CHAR(10) + UPPER(@NewLine) + CHAR(10), CHAR(10) + UPPER(@MemoLF)) > 0
BEGIN
    SET @NewMemoText = @MemoText;
END
ELSE
BEGIN
   
    DECLARE @outLF nvarchar(max) = '';
    DECLARE @pos int = 1, @lf int, @line nvarchar(max);

    WHILE @pos <= LEN(@MemoLF)
    BEGIN
        SET @lf = CHARINDEX(CHAR(10), @MemoLF, @pos);
        IF @lf = 0 SET @lf = LEN(@MemoLF) + 1;  
        SET @line = SUBSTRING(@MemoLF, @pos, @lf - @pos);

        IF NOT (LEFT(UPPER(LTRIM(@line)), 4) = 'MAT.')
            SET @outLF = @outLF + @line + CHAR(10);

        SET @pos = @lf + 1;
    END


    IF @outLF = ''
        SET @MemoText = @NewLine;
    ELSE
        SET @MemoText = @NewLine + CHAR(13)+CHAR(10) +
                        REPLACE(LEFT(@outLF, LEN(@outLF)-1), CHAR(10), CHAR(13)+CHAR(10));
END


    IF @OldUpdatedOn IS NULL
        SET @OldUpdatedOn = '2000-01-01 00:00:00.000'

    -- Stap 2: Reserveer memo ID
    DECLARE @AuxMemoID INT
    EXEC dbo.IP_Get_AuxMemoID @AuxMemoID OUTPUT;

    -- Stap 3: Schrijf memo naar UV_AuxMemo
    EXEC sp_executesql 
        N'UPDATE UV_AuxMemo SET Info = @MemoText WHERE AuxMemoID = @MemoID',
        N'@MemoText NVARCHAR(4000), @MemoID INT',
        @MemoText = @MemoText, 
        @MemoID = @AuxMemoID;

    -- Stap 4: Update ProdBOO met memo
    EXEC dbo.IP_Upd_ProdBOO
        @old_ProdHeaderDossierCode = @ProdHeaderDossierCode,
        @old_ProdBOOLineNr = @ProdBOOLineNr,
        @old_LastUpdatedOn = @OldUpdatedOn,
        @Info = @AuxMemoID,
        @IsahUserCode = N'RPA',
        @LogProgramCode = 920000,
        @LastUpdatedOn = @LastUpdatedOn OUTPUT;

    SET @ResultCode = 1
    SET @ResultMessage = 'Memo succesvol toegevoegd aan Zaag regel van PD: ' + @ProdHeaderDossierCode
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    SET @ResultCode = 0
    SET @ResultMessage = ERROR_MESSAGE()
    ROLLBACK TRANSACTION
END CATCH

-- Output
SELECT @ResultCode AS ResultCode, @ResultMessage AS Message;
