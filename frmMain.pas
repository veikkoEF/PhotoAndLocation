unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Layouts, FMX.Controls.Presentation,
  System.Generics.Collections,
  uPhoto, FMX.Objects; // <- deine Foto-Klasse

type
  TMainForm = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    SpeedButton1: TSpeedButton;
    Layout1: TLayout;
    ListView1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
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
  System.Math; // f�r NaN

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

  // Datensatz 1 � mit Standort
  P := TPhoto.Create;
  P.Id := 1;
  P.Path := ImgPath;
  P.ThumbPath := ImgPath;
  P.Timestamp := Now - (2/24); // vor 2 Stunden
  P.Lat := 48.1371;  // M�nchen
  P.Lon := 11.5754;
  P.Accuracy := 12;
  P.Note := 'M�nchen';
  FPhotos.Add(P);

  // Datensatz 2 � ohne Standort
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

procedure TMainForm.SpeedButton1Click(Sender: TObject);
var
  P: TPhoto;
  ImgPath: string;
begin
  // Beispiel: per Button einen neuen Datensatz mit Platzhalter hinzuf�gen
  ImgPath := GetPlaceholderPath;

  P := TPhoto.Create;
  P.Id := FPhotos.Count + 1;
  P.Path := ImgPath;
  P.ThumbPath := ImgPath;
  P.Timestamp := Now;
  P.Lat := 52.5200; // Berlin
  P.Lon := 13.4050;
  P.Accuracy := 8;
  P.Note := 'Interessanter Ort';
  FPhotos.Add(P);

  RefreshListView;
end;

end.

