SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateConciliationELS] @AgencyId             INT,
                                                 @BankAccountId        INT,
                                                 @CreatedBy            INT,
                                                 @FromDate             DATETIME,
                                                 @ToDate               DATETIME,
                                                 @IsCredit             BIT,
                                                 @IsDebit              BIT,
                                                 @IsCommissionPayments BIT,
                                                 @CreationDate         DATETIME
AS
     BEGIN
         INSERT INTO [dbo].[ConciliationELS]
         ([AgencyId],
          [BankAccountId],
          [FromDate],
          [ToDate],
          [IsCredit],
          IsDebit,
          IsCommissionPayments,
          [CreatedBy],
          [CreationDate]
         )
         VALUES
         (@AgencyId,
          @BankAccountId,
          @FromDate,
          @ToDate,
          @IsCredit,
          @IsDebit,
          @IsCommissionPayments,
          @CreatedBy,
          @CreationDate
         );
         SELECT @@IDENTITY;
     END;
GO