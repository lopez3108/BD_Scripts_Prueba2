SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetProvisionalReceiptsDaily] @CurrentDate DATE = NULL,
@AgencyId INT = NULL,
@CashierId INT = NULL
AS
  SET NOCOUNT ON;
  BEGIN
    SELECT
      Pending
     ,CompletedNoSum Completed
     ,(Pending + CompletedSum) Total
    FROM (SELECT
        (SELECT
            ISNULL(SUM(Total), 0) + ISNULL(SUM(OtherFees), 0)
          FROM [dbo].ProvisionalReceipts pr
          INNER JOIN Agencies A
            ON A.AgencyId = pr.AgencyId
          INNER JOIN Cashiers c
            ON c.CashierId = pr.CreatedBy
          INNER JOIN Users u
            ON u.UserId = c.UserId
          LEFT JOIN dbo.Companies cp
            ON pr.CompanyId = cp.CompanyId
          WHERE CAST(pr.CreationDate AS DATE) = CAST(@CurrentDate AS DATE)
          AND c.CashierId = @CashierId
          AND Completed = 0
          AND pr.AgencyId = @AgencyId)
        Pending
       ,(SELECT
            ISNULL(SUM(Total), 0) + ISNULL(SUM(OtherFees), 0)
          FROM [dbo].ProvisionalReceipts pr
          INNER JOIN Agencies A
            ON A.AgencyId = pr.AgencyId
          INNER JOIN Cashiers c
            ON c.CashierId = pr.CreatedBy
          INNER JOIN Users u
            ON u.UserId = c.UserId
          LEFT JOIN dbo.Companies cp
            ON pr.CompanyId = cp.CompanyId
          WHERE CAST(pr.CreationDate AS DATE) = CAST(@CurrentDate AS DATE)
          AND c.CashierId = @CashierId
          AND Completed = 0
          AND pr.AgencyId = @AgencyId)
        PendingSum
       ,((
        (ABS((SELECT --Completado por el mismo cajero que lo creó, en este caso debe salir completado + y no afectar el total
            ISNULL(SUM(Total), 0) + ISNULL(SUM(OtherFees), 0)
          FROM [dbo].ProvisionalReceipts pr
          INNER JOIN Agencies A
            ON A.AgencyId = pr.AgencyId
          INNER JOIN Cashiers c
            ON c.CashierId = pr.CreatedBy
          INNER JOIN Users u
            ON u.UserId = c.UserId
          LEFT JOIN dbo.Companies cp
            ON pr.CompanyId = cp.CompanyId
          WHERE c.CashierId <> @CashierId
          AND Completed = 1
          AND pr.AgencyId = @AgencyId
          AND (CompletedBy = @CashierId)
          AND CAST(pr.CompletedOn AS DATE) = CAST(@CurrentDate AS DATE))
        ))
        -
        (-ABS((SELECT --Completado por diferente cajero al que lo creó, en este caso debe salir completado + y no afectar el total
            ISNULL(SUM(Total), 0) + ISNULL(SUM(OtherFees), 0)
          FROM [dbo].ProvisionalReceipts pr
          INNER JOIN Agencies A
            ON A.AgencyId = pr.AgencyId
          INNER JOIN Cashiers c
            ON c.CashierId = pr.CreatedBy
          INNER JOIN Users u
            ON u.UserId = c.UserId
          LEFT JOIN dbo.Companies cp
            ON pr.CompanyId = cp.CompanyId
          WHERE c.CashierId = @CashierId
          AND (CompletedBy = @CashierId)
          AND Completed = 1
          AND pr.AgencyId = @AgencyId
          AND CAST(pr.CompletedOn AS DATE) = CAST(@CurrentDate AS DATE))
        ))


        )) CompletedNoSum
       ,(

        --task 5204
        --CASO1- Todo lo que yo creo y me completan debe sumarme en total to pay como débito, 
        --solo no suman cuando lo creo yo y lo completo yo mismo el mismo día de creación
        (SELECT
            ISNULL(SUM(Total), 0) + ISNULL(SUM(OtherFees), 0)

          FROM [dbo].ProvisionalReceipts pr
          INNER JOIN Agencies A
            ON A.AgencyId = pr.AgencyId
          INNER JOIN Cashiers c
            ON c.CashierId = pr.CreatedBy
          INNER JOIN Users u
            ON u.UserId = c.UserId
          LEFT JOIN dbo.Companies cp
            ON pr.CompanyId = cp.CompanyId
          WHERE Completed = 1
          AND pr.AgencyId = @AgencyId
          AND c.CashierId = @CashierId
          AND CAST(pr.CreationDate AS DATE) = CAST(@CurrentDate AS DATE)
          AND ((pr.CompletedBy <> pr.CreatedBy)
          OR pr.CompletedBy = pr.CreatedBy
          AND CAST(pr.CompletedOn AS DATE) <> CAST(@CurrentDate AS DATE)))
        +

        --task 5204
        --CASO2- Todo lo que yo completo debe restarse en el total to pay como crédito, 
        --solo no resta cuando lo creo yo y lo completo yo mismo el mismo día de creación

        -(SELECT
            ISNULL(SUM(Total), 0) + ISNULL(SUM(OtherFees), 0)
          FROM [dbo].ProvisionalReceipts pr
          INNER JOIN Agencies A
            ON A.AgencyId = pr.AgencyId
          INNER JOIN Cashiers c
            ON c.CashierId = pr.CreatedBy
          INNER JOIN Users u
            ON u.UserId = c.UserId
          LEFT JOIN dbo.Companies cp
            ON pr.CompanyId = cp.CompanyId
          WHERE Completed = 1
          AND pr.AgencyId = @AgencyId
          AND (CompletedBy = @CashierId
          AND CAST(pr.CompletedOn AS DATE) = CAST(@CurrentDate AS DATE))
          AND ((CAST(pr.CompletedOn AS DATE) <> CAST(pr.CreationDate AS DATE))
          OR (CAST(pr.CompletedOn AS DATE) = CAST(pr.CreationDate AS DATE)
          AND CompletedBy <> CreatedBy)
          ))

        ) CompletedSum) AS query
  END;
GO