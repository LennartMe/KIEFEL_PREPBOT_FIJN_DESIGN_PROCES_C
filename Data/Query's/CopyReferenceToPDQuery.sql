-- Declare variables
declare @p29 datetime2(7) = SYSDATETIME();  -- current timestamp
declare @p30 nvarchar(3999);

-- Format current datetime as 'MMM dd yyyy hh:mm:ss:ffftt'
set @p30 = FORMAT(@p29, 'MMM dd yyyy hh:mm:ss:ffftt', 'en-US');

-- Start transaction
BEGIN TRAN;

BEGIN TRY
    -- Execute stored procedure
    exec [dbo].[ip_cpy_ProdList] 
        N'{ReferencePD}', -- ReferencePD
        N'{ProdHeaderDossierCode}', -- TargetPD
        '1',
        0, 1, 0, 0, 0, 1,
        NULL, NULL, NULL, 0,
        N'', 0, 0, N'', 0, 0, N'', 0, 0, N'',
        0, N'RPA', 2860000, 0, 0,
        @p29 output,
        @p30 output;

    COMMIT;  -- If no errors, commit transaction
	select '1' as Succes, 'Successfully copied {ReferencePD} to {ProdHeaderDossierCode}' as Message;
END TRY
BEGIN CATCH
    ROLLBACK;  -- If error occurs, rollback
	select '0' as Succes, ERROR_MESSAGE() as Message;
    THROW;     -- Re-throw the error
END CATCH;
