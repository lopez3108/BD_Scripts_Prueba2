SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-08-05 DJ/6652: Proceso automatico revision Tickets

CREATE PROCEDURE [dbo].[sp_CreateTicketAIReminder] (
@TicketNumber VARCHAR(30),
@Telephone VARCHAR(10),
@Usd DECIMAL(18,2),
@DateSent DATETIME,
@TicketTypeCode VARCHAR(4),
@SendStatus BIT,
@ExceptionThrown VARCHAR(500) NULL
)
AS
BEGIN

DECLARE @TicketTypeId INT
SET @TicketTypeId = (SELECT TOP 1 t.TicketTypeId FROM dbo.TicketType t WHERE t.Code = @TicketTypeCode)


INSERT INTO [dbo].[TicketAIReminder]
           ([TicketNumber]
           ,[Telephone]
           ,[Usd]
           ,[DateSent]
           ,[TicketTypeId]
           ,[SendStatus]
           ,[ExceptionThrown])
     VALUES
           (@TicketNumber
           ,@Telephone
           ,@Usd
           ,@DateSent
           ,@TicketTypeId
           ,@SendStatus
           ,@ExceptionThrown)

		   SELECT @@IDENTITY



END
GO