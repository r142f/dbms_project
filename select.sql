CREATE OR REPLACE VIEW PiecesWithAllComposers(
    ISWC,
    PieceName,
    PieceYear,
    ComposerId,
    ComposerName,
    TonalityTonic,
    TonalityModus,
    FormId,
    TempoId,
    StyleId
  ) AS
SELECT p.ISWC,
  PieceName,
  PieceYear,
  cp.ComposerId,
  ComposerName,
  TonalityTonic,
  TonalityModus,
  FormId,
  TempoId,
  StyleId
FROM Pieces p
  JOIN ComposersPieces cp ON p.ISWC = cp.ISWC
  JOIN Composers c ON cp.composerid = c.composerid;

CREATE OR REPLACE VIEW PiecesWithAllComposersAndAllInstruments(
    ISWC,
    PieceName,
    PieceYear,
    ComposerId,
    ComposerName,
    InstrumentId,
    InstrumentName,
    instrumentCount,
    TonalityTonic,
    TonalityModus,
    FormId,
    TempoId,
    StyleId
  ) AS
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposerId,
  ComposerName,
  InstrumentId,
  InstrumentName,
  instrumentCount,
  TonalityTonic,
  TonalityModus,
  FormId,
  TempoId,
  StyleId
FROM PiecesWithAllComposers
  NATURAL JOIN InstrumentsPieces
  NATURAL JOIN Instruments;

CREATE OR REPLACE VIEW PiecesInformation(
    ISWC,
    PieceName,
    PieceYear,
    ComposerId,
    ComposerName,
    InstrumentId,
    InstrumentName,
    instrumentCount,
    TonalityTonic,
    TonalityModus,
    FormName,
    TempoName,
    StyleName
  ) AS
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposerId,
  ComposerName,
  InstrumentId,
  InstrumentName,
  instrumentCount,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesWithAllComposersAndAllInstruments
  NATURAL JOIN Forms
  NATURAL JOIN Tempos
  NATURAL JOIN Styles;

CREATE OR REPLACE VIEW PiecesInformationAggr(
    ISWC,
    PieceName,
    PieceYear,
    ComposersIds,
    ComposersNames,
    InstrumentsIds,
    Instruments,
    TonalityTonic,
    TonalityModus,
    FormName,
    TempoName,
    StyleName
  ) AS
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposersIds,
  ComposersNames,
  string_agg(InstrumentId::text, ', '::text) AS InstrumentsIds,
  string_agg(
    CONCAT(InstrumentCount, ' ', InstrumentName),
    ', '::text
  ) AS Instruments,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM (
    SELECT ISWC,
      PieceName,
      PieceYear,
      string_agg(ComposerId::text, ', '::text) AS ComposersIds,
      string_agg(ComposerName::text, ', '::text) AS ComposersNames,
      TonalityTonic,
      TonalityModus,
      FormId,
      TempoId,
      StyleId
    FROM PiecesWithAllComposers
    GROUP BY ISWC,
      PieceName,
      PieceYear,
      TonalityTonic,
      TonalityModus,
      FormId,
      TempoId,
      StyleId
  ) sq
  NATURAL JOIN InstrumentsPieces
  NATURAL JOIN Instruments
  NATURAL JOIN Forms
  NATURAL JOIN Tempos
  NATURAL JOIN Styles
GROUP BY ISWC,
  PieceName,
  PieceYear,
  ComposersIds,
  ComposersNames,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName;

-- GetPiecesInfoAggrByISWC
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposersNames,
  Instruments,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformationAggr
WHERE ISWC = 'T-932.530.905-5';

-- GetPiecesInfoAggrWithComposerId
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposersNames,
  Instruments,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformationAggr
  NATURAL JOIN (
    SELECT ISWC
    FROM ComposersPieces
    WHERE ComposerId = 1
  ) sq;

-- GetPiecesInfoByInstrumentName
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposerName,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformation pi
WHERE InstrumentName = 'piano'
  AND InstrumentCount = 1
  AND NOT EXISTS (
    SELECT ISWC
    FROM InstrumentsPieces
    WHERE ISWC = pi.ISWC
      AND InstrumentId <> pi.InstrumentId
  );

-- GetPiecesInfoWithInstrumentName
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposerName,
  InstrumentName,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformation
WHERE ISWC IN (
    SELECT ISWC
    FROM InstrumentsPieces
      NATURAL JOIN Instruments
    WHERE InstrumentName = 'horn'
  );

-- GetPiecesInfoAggrByYears
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposersNames,
  Instruments,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformationAggr
WHERE PieceYear > 1800
  AND PieceYear < 1900;

-- GetPiecesInfoByFormName
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposerName,
  InstrumentName,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformation
WHERE FormName = 'nocturne';

-- GetPiecesInfoByTempoName
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposerName,
  InstrumentName,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformation
WHERE TempoName = 'moderato';

-- GetPiecesInfoByStyleName
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposerName,
  InstrumentName,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformation
WHERE StyleName = 'romanticism';

-- GetPiecesInfoByFormNameAndComposerId
SELECT ISWC,
  PieceName,
  PieceYear,
  ComposerName,
  InstrumentName,
  TonalityTonic,
  TonalityModus,
  FormName,
  TempoName,
  StyleName
FROM PiecesInformation
WHERE FormName = 'nocturne'
  AND ComposerId = 1;

-- GetComposersIdsByStyleName
SELECT DISTINCT ComposerId,
  ComposerName
FROM PiecesWithAllComposers
  NATURAL JOIN Styles
WHERE StyleName = 'romanticism';

-- GetPiecesCountByComposerId
SELECT c.ComposerId,
  ComposerName,
  COUNT(*) AS PiecesCount
FROM ComposersPieces cp
  JOIN Composers c ON cp.ComposerId = c.ComposerId
GROUP BY c.ComposerId;

-- GetPiecesCountByComposerIdAndFormName
SELECT ComposerId,
  ComposerName,
  FormName,
  COUNT(*) AS PiecesCount
FROM PiecesWithAllComposers
  NATURAL JOIN Forms
GROUP BY ComposerId,
  ComposerName,
  FormName;

-- GetPiecesCountByComposerIdAndInstrumentName
SELECT ComposerId,
  ComposerName,
  InstrumentName,
  COUNT(*) AS PiecesCount
FROM PiecesWithAllComposersAndAllInstruments
GROUP BY ComposerId,
  ComposerName,
  InstrumentName;