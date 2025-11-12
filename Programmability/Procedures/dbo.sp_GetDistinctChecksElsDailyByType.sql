SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_GetDistinctChecksElsDailyByType				    															         
-- Descripcion: Procedimiento Almacenado que consulta todos los tickets.				    					         
-- Creado por: 																			 
-- Fecha:																									 	
-- Modificado por: Romario Jimenez																										 
-- Fecha: 06-03-2024																											 
-- Observación:  se modifica la consulta para obtener el providertype y se agrega la columna del account  
-- Test:                                      
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_GetDistinctChecksElsDailyByType]
(@Creationdate     DATE,
 @AgencyId         INT,
 @ProviderTypeCode VARCHAR(10),
 @UserId           INT
)
AS
     BEGIN
         DECLARE @ProviderTypeId INT;
         SET @ProviderTypeId =
         (
             SELECT pt.ProviderTypeId
             FROM dbo.ProviderTypes pt
             WHERE Code = @ProviderTypeCode
         );
         SELECT DISTINCT
                CAST(CAST(Amount AS MONEY) AS VARCHAR(20)) Amount,
				CheckNumber
        ,Account
         FROM [dbo].[ChecksEls]
         WHERE(CAST(CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND AgencyId = @AgencyId
              AND ProviderTypeId = @ProviderTypeId
              AND ( CreatedBy = @UserId);
     END;
GO