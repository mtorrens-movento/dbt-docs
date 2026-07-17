





WITH

src_raw AS (

    SELECT
        m.[Bank Code],
        m.[Bank Desc],
        m.[Company Code],
        m.[Company Desc],
        m.[Flow Code],
        m.[Date],
        m.[Book Date],
        m.[Signed Amount],
        m.[Importe Signo Div Cuenta],
        m.[Referencia],
        m.[_source_table],
        m.[_bronze_ingestion_timestamp],
        m.snapshot_date
    FROM [lh_bronze].[sharepoint].[hist_facts_tesoreria_movimientos] AS m
    WHERE m.snapshot_date = CAST('2026-07-12' AS DATE)

),

casting AS (

    SELECT
        TRY_CONVERT(INT, NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(100), [Bank Code]))),
        ''
    )) AS bank_code,
        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(255), [Bank Desc]))),
        ''
    ) AS bank_desc,

        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(50), [Company Code]))),
        ''
    ) AS company_code,
        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(255), [Company Desc]))),
        ''
    ) AS company_desc,

        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(50), [Flow Code]))),
        ''
    ) AS flow_code,

        COALESCE(
    TRY_CONVERT(DATE, TRY_CONVERT(VARCHAR(50), [Date]), 103),
    TRY_CONVERT(DATE, TRY_CONVERT(VARCHAR(50), [Date]), 23)
) AS movement_date,
        COALESCE(
    TRY_CONVERT(DATE, TRY_CONVERT(VARCHAR(50), [Book Date]), 103),
    TRY_CONVERT(DATE, TRY_CONVERT(VARCHAR(50), [Book Date]), 23)
) AS book_date,

        COALESCE(
    TRY_CONVERT(DECIMAL(18,0), [Signed Amount]),
    TRY_CONVERT(
        DECIMAL(18,0),
        NULLIF(
            REPLACE(
                REPLACE(
                    LTRIM(RTRIM(TRY_CONVERT(VARCHAR(100), [Signed Amount]))),
                    '.',
                    ''
                ),
                ',',
                ''
            ),
            ''
        )
    )
) AS signed_amount,
        COALESCE(
    TRY_CONVERT(DECIMAL(18,0), [Importe Signo Div Cuenta]),
    TRY_CONVERT(
        DECIMAL(18,0),
        NULLIF(
            REPLACE(
                REPLACE(
                    LTRIM(RTRIM(TRY_CONVERT(VARCHAR(100), [Importe Signo Div Cuenta]))),
                    '.',
                    ''
                ),
                ',',
                ''
            ),
            ''
        )
    )
) AS importe_signo_div_cuenta,

        NULLIF(
        LTRIM(RTRIM(TRY_CONVERT(VARCHAR(100), [Referencia]))),
        ''
    ) AS referencia,

        TRY_CONVERT(DATE, snapshot_date) AS source_snapshot_date,
        TRY_CONVERT(VARCHAR(255), [_source_table]) AS _source_table,
        TRY_CONVERT(DATETIME2(0), [_bronze_ingestion_timestamp]) AS _bronze_ingestion_timestamp

    FROM src_raw

),

valid_rows AS (

    SELECT *
    FROM casting
    WHERE bank_code IS NOT NULL
      AND company_code IS NOT NULL
      AND flow_code IS NOT NULL
      AND movement_date IS NOT NULL
      AND book_date IS NOT NULL
      AND signed_amount IS NOT NULL
      AND importe_signo_div_cuenta IS NOT NULL
      AND source_snapshot_date IS NOT NULL

),

business_keyed AS (

    SELECT
        CONVERT(
            VARCHAR(64),
            HASHBYTES(
                'SHA2_256',
                CONCAT(
                    'MOV|',
                    CONVERT(VARCHAR(50), bank_code), '|',
                    ISNULL(company_code, ''), '|',
                    ISNULL(flow_code, ''), '|',
                    CONVERT(VARCHAR(10), movement_date, 23), '|',
                    CONVERT(VARCHAR(10), book_date, 23), '|',
                    CONVERT(VARCHAR(50), signed_amount), '|',
                    CONVERT(VARCHAR(50), importe_signo_div_cuenta), '|',
                    ISNULL(referencia, '')
                )
            ),
            2
        ) AS movement_hash_key,

        bank_code,
        bank_desc,
        company_code,
        company_desc,
        flow_code,
        movement_date,
        book_date,
        signed_amount,
        importe_signo_div_cuenta,
        referencia,
        source_snapshot_date,
        _source_table,
        _bronze_ingestion_timestamp

    FROM valid_rows

),

deduped AS (

    SELECT
        movement_hash_key,

        CAST(1 AS INT) AS movement_occurrence_num,

        bank_code,
        MAX(bank_desc) AS bank_desc,

        company_code,
        MAX(company_desc) AS company_desc,

        flow_code,
        movement_date,
        book_date,
        signed_amount,
        importe_signo_div_cuenta,
        referencia,

        MAX(source_snapshot_date) AS source_snapshot_date,
        MAX(_source_table) AS _source_table,
        MAX(_bronze_ingestion_timestamp) AS _bronze_ingestion_timestamp

    FROM business_keyed

    GROUP BY
        movement_hash_key,
        bank_code,
        company_code,
        flow_code,
        movement_date,
        book_date,
        signed_amount,
        importe_signo_div_cuenta,
        referencia

)

SELECT
    movement_hash_key,
    movement_occurrence_num,

    bank_code,
    bank_desc,
    company_code,
    company_desc,
    flow_code,
    movement_date,
    book_date,
    signed_amount,
    importe_signo_div_cuenta,
    referencia,

    CONVERT(
    VARCHAR(64),
    HASHBYTES(
        'SHA2_256',CONCAT(COALESCE(TRY_CONVERT(VARCHAR(8000), bank_code), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), bank_desc), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), company_code), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), company_desc), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), flow_code), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), CONVERT(VARCHAR(10), movement_date, 23)), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), CONVERT(VARCHAR(10), book_date, 23)), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), signed_amount), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), importe_signo_div_cuenta), ''), '|',COALESCE(TRY_CONVERT(VARCHAR(8000), referencia), ''))),
    2
) AS hash_diff,

    source_snapshot_date,
    _source_table,
    _bronze_ingestion_timestamp

FROM deduped