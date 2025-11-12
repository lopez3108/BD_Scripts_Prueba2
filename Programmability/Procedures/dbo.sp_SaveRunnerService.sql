SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveRunnerService]
(@RunnerServiceId    INT            = NULL,
 @Usd                DECIMAL(18, 2),
 --@FeeEls             DECIMAL(18, 2)  = NULL,
 @NumberTransactions INT,
 @CreationDate       DATETIME,
 @AgencyId           INT,
 @CreatedBy          INT
)
AS
     BEGIN
         --DECLARE @FeeElsRunner DECIMAL(18, 2);
         --IF(@FeeEls IS NULL)
         --    BEGIN
         --        SET @FeeElsRunner =
         --        (
         --            SELECT ISNULL(FeeEls, 0)
         --            FROM PROVIDERSEls
         --            WHERE Code = 'C07'
         --        );
         --END;
         IF(@RunnerServiceId IS NULL)
             BEGIN
                 INSERT INTO [dbo].RunnerServices
                 (USD,
                  NumberTransactions,
                  CreationDate,
                  AgencyId,
                  CreatedBy
			   --,
      --            FeeEls
                 )
                 VALUES
                 (@Usd,
                  @NumberTransactions,
                  @CreationDate,
                  @AgencyId,
                  @CreatedBy
			   --,
      --            @FeeElsRunner
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].RunnerServices
                   SET
                       USD = @Usd,
                       NumberTransactions = @NumberTransactions,
                       CreatedBy = @CreatedBy,
                       CreationDate = @CreationDate
				   --,
       --                FeeEls = @FeeEls
                 WHERE RunnerServiceId = @RunnerServiceId;
         END;
     END;
GO