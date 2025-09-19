unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Layouts, FMX.Controls.Presentation,
  System.Generics.Collections,
  uPhoto, FMX.Objects, FMX.MediaLibrary, System.Actions, FMX.ActnList,
  FMX.StdActns, FMX.MediaLibrary.Actions; // <- deine Foto-Klasse

type
  TMainForm = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    Layout1: TLayout;
    ListView1: TListView;
    ActionList1: TActionList;
    SpeedButton1: TSpeedButton;
    TakePhotoFromCameraAction1: TTakePhotoFromCameraAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TakePhotoFromCameraAction1DidFinishTaking(Image: TBitmap);
  private
    FPhotos: TObjectList<TPhoto>; // owns objects
    procedure CreateSampleData;
    procedure RefreshListView;
    function  LoadBitmapFromFile(const APath: string): TBitmap;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}
{$R *.iPhone55in.fmx IOS}
{$R *.iPhone47in.fmx IOS}
{$R *.iPhone4in.fmx IOS}

uses
  System.IOUtils,
  System.Math; // für NaN

function GetPlaceholderPath: string;
const
  CFileName = 'placeholder.jpg';
begin
{$IF DEFINED(IOS) OR DEFINED(ANDROID)}
  // Datei wird per Deployment nach StartUp\Documents kopiert:
  Result := TPath.Combine(TPath.GetDocumentsPath, CFileName);
{$ELSE}
  // Beim Desktop-Test direkt neben der EXE:
  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), CFileName);
{$ENDIF}
end;

{ --- Hilfsfunktionen --- }

function TMainForm.LoadBitmapFromFile(const APath: string): TBitmap;
begin
  Result := nil;
  if (APath = '') or (not TFile.Exists(APath)) then
    Exit;

  Result := TBitmap.Create;
  try
    Result.LoadFromFile(APath);
  except
    Result.Free;
    Result := nil;
  end;
end;

procedure TMainForm.RefreshListView;
var
  Item: TListViewItem;
  P: TPhoto;
  Bmp: TBitmap;
  ImagePath: string;
begin
  ListView1.BeginUpdate;
  try
    ListView1.Items.Clear;

    for P in FPhotos do
    begin
      Item := ListView1.Items.Add;

      // 1. Zeile: Datum
      Item.Text := P.TimestampAsText;

      // 2. + 3. Zeile: Titel (Note) + Koordinaten/Text
      Item.Detail := P.Note + sLineBreak + P.LocationAsText;

      // Bild setzen (links)
      ImagePath := P.ThumbPath;
      if ImagePath.IsEmpty then
        ImagePath := P.Path;
      Bmp := LoadBitmapFromFile(ImagePath);
      if Assigned(Bmp) then
        Item.Bitmap := Bmp;

      // (optional) etwas extra Abstand rechts vom Bild erzwingen:
      // ListView1.ItemAppearanceObjects.ItemObjects.Image.PlaceOffset.X := 16; // schon oben gesetzt
    end;
  finally
    ListView1.EndUpdate;
  end;
end;


procedure TMainForm.CreateSampleData;
var
  P: TPhoto;
  ImgPath: string;
begin
  ImgPath := GetPlaceholderPath;

  // Datensatz 1 – mit Standort
  P := TPhoto.Create;
  P.Id := 1;
  P.Path := ImgPath;
  P.ThumbPath := ImgPath;
  P.Timestamp := Now - (2/24); // vor 2 Stunden
  P.Lat := 48.1371;  // München
  P.Lon := 11.5754;
  P.Accuracy := 12;
  P.Note := 'München';
  FPhotos.Add(P);

  // Datensatz 2 – ohne Standort
  P := TPhoto.Create;
  P.Id := 2;
  P.Path := ImgPath;
  P.ThumbPath := ImgPath;
  P.Timestamp := Now - 1; // gestern
  P.Lat := NaN;
  P.Lon := NaN;
  P.Accuracy := NaN;
  P.Note := 'Berlin';
  FPhotos.Add(P);
end;

{ --- Events --- }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Objektliste mit Ownership
  FPhotos := TObjectList<TPhoto>.Create(True);
  CreateSampleData;
  RefreshListView;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FPhotos.Free;
end;



procedure TMainForm.TakePhotoFromCameraAction1DidFinishTaking(Image: TBitmap);
var
  P: TPhoto;
  TempPath: string;
begin
  // temporären Pfad für das Foto wählen
  TempPath := TPath.Combine(TPath.GetDocumentsPath,
               Format('photo_%d.png', [FPhotos.Count + 1]));
  Image.SaveToFile(TempPath);

  // neues Foto-Objekt erzeugen
  P := TPhoto.Create;
  P.Id := FPhotos.Count + 1;
  P.Path := TempPath;
  P.ThumbPath := TempPath;   // später evtl. eigene Thumbnails generieren
  P.Timestamp := Now;

  // Dummy-Daten für Standort und Note
  P.Lat := NaN;
  P.Lon := NaN;
  P.Accuracy := NaN;
  P.Note := 'Noch kein Kommentar';

  // zur Liste hinzufügen und UI aktualisieren
  FPhotos.Add(P);
  RefreshListView;
end;

end.

