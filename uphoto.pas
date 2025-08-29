unit uPhoto;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Math;

type
  // Datenklasse für ein Foto mit Metadaten
  TPhoto = class
  private
    FId: Integer;         // Primärschlüssel in SQLite
    FPath: string;        // Originalbild
    FThumbPath: string;   // Thumbnail-Bild (optional)
    FTimestamp: TDateTime;// Aufnahmezeit
    FLat: Double;         // Breitengrad
    FLon: Double;         // Längengrad
    FAccuracy: Double;    // Genauigkeit in Metern
    FNote: string;        // Benutzer-Notiz
  public
    property Id: Integer read FId write FId;
    property Path: string read FPath write FPath;
    property ThumbPath: string read FThumbPath write FThumbPath;
    property Timestamp: TDateTime read FTimestamp write FTimestamp;
    property Lat: Double read FLat write FLat;
    property Lon: Double read FLon write FLon;
    property Accuracy: Double read FAccuracy write FAccuracy;
    property Note: string read FNote write FNote;

    function HasLocation: Boolean;
    function LocationAsText: string;
    function TimestampAsText: string;
  end;

implementation

{ TPhoto }

function TPhoto.HasLocation: Boolean;
begin
  Result := (not IsNan(FLat)) and (not IsNan(FLon));
end;

function TPhoto.LocationAsText: string;
begin
  if not HasLocation then
    Exit('Ohne Standort');

  Result := FormatFloat('0.0000', FLat) + '° N, ' +
            FormatFloat('0.0000', FLon) + '° E';
  if not IsNan(FAccuracy) then
    Result := Result + Format('  •  ±%.0f m', [FAccuracy]);
end;

function TPhoto.TimestampAsText: string;
begin
  Result := FormatDateTime('dd.mm.yyyy, hh:nn', FTimestamp);
end;

end.

