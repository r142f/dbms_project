INSERT INTO Instruments (InstrumentName)
VALUES ('piano'),
  ('violin'),
  ('orchestra'),
  ('viola'),
  ('cello'),
  ('clarinet'),
  ('horn');

INSERT INTO Forms (FormName)
VALUES ('nocturne'),
  ('prelude'),
  ('concerto'),
  ('duet'),
  ('pavane'),
  ('trio');

INSERT INTO Tempos (TempoName, TempoMinBPM, TempoMaxBPM)
VALUES ('larghissimo', 1, 24),
  ('adagissimo', 24, 40),
  ('grave', 25, 45),
  ('largo', 40, 60),
  ('lento', 45, 60),
  ('larghetto', 60, 66),
  ('adagio', 66, 76),
  ('adagietto', 70, 80),
  ('andante', 76, 108),
  ('andantino', 80, 108),
  ('moderato', 108, 120),
  ('allegretto', 112, 120),
  ('allegro', 120, 156),
  ('vivace', 156, 176),
  ('allegrissimo', 172, 176),
  ('vivacissimo', 172, 176),
  ('prestissimo', 200, 200);

INSERT INTO Styles (StyleName)
VALUES ('classicism'),
  ('romanticism'),
  ('impressionism');

CREATE OR REPLACE PROCEDURE InsertPiece (
  _ISWC Pieces.ISWC%TYPE,
  _name Pieces.PieceName%TYPE,
  _year Pieces.PieceYear%TYPE,
  _ComposersIds integer[],
  _InstrumentsNames varchar(63)[],
  _InstrumentsCounts integer[],
  _tonic Pieces.TonalityTonic%TYPE,
  _modus Pieces.TonalityModus%TYPE,
  _FormName Forms.FormName%Type,
  _TempoName Tempos.TempoName%Type,
  _StyleName Styles.StyleName%Type
)
  AS $$
DECLARE
  CId Composers.ComposerId%TYPE;
  IIdCountPair integer[2];
  i integer;
BEGIN
  INSERT INTO Pieces (
      ISWC,
      PieceName,
      PieceYear,
      ComposerId,
      InstrumentId,
      TonalityTonic,
      TonalityModus,
      FormId,
      TempoId,
      StyleId
    )
  VALUES (
      _ISWC,
      _name,
      _year,
      _ComposersIds[1],
      (
        SELECT InstrumentId
        FROM Instruments
        WHERE InstrumentName = _InstrumentsNames[1]
      ),
      _tonic,
      _modus,
      (
        SELECT FormId
        FROM Forms
        WHERE FormName = _FormName
      ),
      (
        SELECT TempoId
        FROM Tempos
        WHERE TempoName = _TempoName
      ),
      (
        SELECT StyleId
        FROM Styles
        WHERE StyleName = _StyleName
      )
    );

  FOREACH CId IN ARRAY _ComposersIds LOOP
    INSERT INTO ComposersPieces (ComposerId, ISWC)
    VALUES (CId, _ISWC);
  END LOOP;

  FOR i IN 1..cardinality(_InstrumentsNames) LOOP
    INSERT INTO InstrumentsPieces (InstrumentId, ISWC, InstrumentCount)
    VALUES (
        (
          SELECT InstrumentId
          FROM Instruments
          WHERE InstrumentName = _InstrumentsNames[i]
        ),
        _ISWC,
        _InstrumentsCounts[i]
      );
  END LOOP;
END;
$$
LANGUAGE plpgsql;

BEGIN TRANSACTION;
SET constraints ALL DEFERRED;

INSERT INTO Composers (ComposerName, ISWC)
VALUES ('Frederic Chopin', 'T-300.440.949-4'),
  ('Sergei Rachmaninoff', 'T-072.457.235-3'),
  ('Robert Schumann', 'T-932.530.905-5'),
  ('Auguste Franchomme', 'T-919.739.204-4'),
  ('Maurice Ravel', 'T-007.210.542-0'),
  ('Wolfgang Mozart', 'T-917.143.934-2');

CALL InsertPiece(
  'T-300.440.949-4',
  'Nocturne in C Sharp Minor (No. 20)',
  1830, 
  '{1}',
  ARRAY ['piano'],
  '{1}',
  'C-sharp',
  'minor',
  'nocturne',
  'lento',
  'romanticism'
);

CALL InsertPiece(
  'T-072.457.235-3',
  'Piano Concerto no. 2 op. 18',
  1900, 
  '{2}',
  ARRAY ['piano', 'orchestra'],
  '{1, 1}',
  'C',
  'minor',
  'concerto',
  'moderato',
  'romanticism'
);

CALL InsertPiece(
  'T-932.530.905-5',
  'Concertpiece for Four Horns and Orchestra, Op. 86',
  1849, 
  '{3}',
  ARRAY ['horn', 'orchestra'],
  '{4, 1}',
  'F',
  'major',
  'concerto',
  'vivace',
  'romanticism'
);

CALL InsertPiece(
  'T-932.532.733-1',
  'Prelude in B Minor (Op. 28 No. 6)',
  1839, 
  '{1}',
  ARRAY ['piano'],
  '{1}',
  'B',
  'minor',
  'prelude',
  'largo',
  'romanticism'
);

CALL InsertPiece(
  'T-919.739.204-4',
  'Grand Duo concertant in E major, B. 70',
  1832, 
  '{1, 4}',
  ARRAY ['piano', 'cello'],
  '{1, 1}',
  'E',
  'major',
  'duet',
  'largo',
  'romanticism'
);

CALL InsertPiece(
  'T-007.210.542-0',
  'Pavane for a Dead Princess',
  1899, 
  '{5}',
  ARRAY ['piano'],
  '{1}',
  'G',
  'major',
  'pavane',
  'largo',
  'impressionism'
);

CALL InsertPiece(
  'T-917.143.934-2',
  'Trio in E-flat major, K.498',
  1786, 
  '{6}',
  ARRAY ['clarinet', 'piano', 'viola'],
  '{1, 1, 1}',
  'E-flat',
  'major',
  'trio',
  'andante',
  'classicism'
);

COMMIT;
