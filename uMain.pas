unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation, FMX.Edit, FMX.Platform,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client

  /// Helpers for Android implementations by FMX.
    , FMX.Helpers.Android
  // Java Native Interface permite a programas
  // ejecutados en la JVM interactue con otros lenguajes.
    , Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Net,
  Androidapi.JNI.JavaTypes, Androidapi.Helpers
  // Obtiene datos de telefonia del dispositivo
    , Androidapi.JNI.Telephony;

type
  TfrmLogin = class(TForm)
    ToolBar1: TToolBar;
    Panel1: TPanel;
    VertScrollBox1: TVertScrollBox;
    BtnLimpiar: TButton;
    BtnSalir: TButton;
    LTitulo: TLabel;
    Image1: TImage;
    LCorreoElectronico: TLabel;
    ECorreo: TEdit;
    LPassword: TLabel;
    EPassword: TEdit;
    CheckMP: TCheckBox;
    BtnIniciar: TButton;
    Panel2: TPanel;
    BtnOlvidasteTuPassword: TButton;
    Label1: TLabel;
    BtnRegistrar: TButton;
    LUsuario: TLabel;
    DB: TFDConnection;
    tblUsuario: TFDTable;
    tblProducto: TFDTable;
    procedure BtnSalirClick(Sender: TObject);
    procedure BtnLimpiarClick(Sender: TObject);
    procedure CheckMPChange(Sender: TObject);
    procedure ValidarCampos(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure BtnRegistrarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnIniciarClick(Sender: TObject);
    procedure BtnOlvidasteTuPasswordClick(Sender: TObject);

    // Para validar campos.
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SendSMS(target, message: string);

  var
    dbFileName: string;
  end;

var
  frmLogin: TfrmLogin;
  varContador: Integer = 0;

implementation

uses
  uRegistrar, // Para conectar con el frm.
  uMenu,
  System.IOUtils; // Para hacer uso de TPath.

{$R *.fmx}

// Esto se ejecuta al iniciar el programa/app siempre para establecer la BD.
procedure TfrmLogin.FormCreate(Sender: TObject);
begin
{$IF DEFINED(MSWINDOWS)}
  // Ubicacion de la bd en Windows.
  dbFileName := 'E:\Proyecto\db\puntoVenta.db;
{$ELSE}
  // Ubicacion de la bd en Android.
    dbFileName := TPath.Combine(TPath.GetDocumentsPath, 'puntoVenta.db');
{$ENDIF}
  // Asignar la base de datos.
  DB.Params.Database := dbFileName;
  try
    DB.Connected := true; // Conectarse a la BD.
    tblUsuario.Active := true; // Ativar la tabla.
    tblProducto.Active := true; // Ativar la tabla.
    DB.Open;
    tblUsuario.Open;
    tblProducto.Open;
  except
    // Se ejecuta si ocurre una falla al intentar conectarse a la BD.
    on E: Exception do
      ShowMessage('Error de conexion');
  end;
end;

procedure TfrmLogin.BtnIniciarClick(Sender: TObject);
begin
  // Buscar Registro con el correo y contraseña ingresados.
  if tblUsuario.Locate('correo;password',
    VarArrayOf([ECorreo.Text, EPassword.Text]), []) then
  begin
{$IF DEFINED(MSWINDOWS)}
    frmMenu.ShowModal;
{$ELSE}
    frmMenu.Show;
{$ENDIF}
    ECorreo.Text := '';
    EPassword.Text := '';
    CheckMP.IsChecked := false;
  end
  else
  begin
    ShowMessage
      ('El correo electronico o el password es inválido, verifica la información y prueba nuevamente.');
    // Número de intentos de inicio de sesión.
    varContador := varContador + 1;
    // Verificación de intentos de inicio de sesión.
    if ((varContador = 3)) then
    begin
      BtnIniciar.Enabled := false; // Deshabilitar el botón.
      ShowMessage('Intente de nuevo despues de 20 segundos.');
      // (Thread) para esperar 5 segundos y habilitar el botón nuevamente.
      TThread.CreateAnonymousThread(
        procedure
        begin
          Sleep(20000); // Esperar 20 segundos.
        end).Start;
      varContador := 0; // Reiniciar contador.
    end;
    EPassword.Text := '';
  end;

end;

// Para limpiar todos los campos del Login.
procedure TfrmLogin.BtnLimpiarClick(Sender: TObject);
begin
  ECorreo.Text := '';
  EPassword.Text := '';
  CheckMP.IsChecked := false;
end;

procedure TfrmLogin.SendSMS(target, message: string);
var
  smsManager: JSmsManager; // Declarar administrador de mensajes
  smsTo: JString; // Variable destinatario del SMS
begin
  try
    // inicializar administrador de mensajes
    smsManager := TJSmsManager.JavaClass.getDefault;
    // convertir target a tipo Jstring tipo de dato usado por JNI
    smsTo := StringToJString(target);
    // pasar parametros a administrador para enviar mensaje
    smsManager.sendTextMessage(smsTo, nil, StringToJString(message), nil, nil);
    ShowMessage('Mensaje enviado');
  except
    on E: Exception do
      ShowMessage(E.ToString);
  end;
end;

// Para enviar un SMS al numero de telefono que esta en la BD con la contraseña.
procedure TfrmLogin.BtnOlvidasteTuPasswordClick(Sender: TObject);
var
  varCelular: String; // Contendra el número registrado.
  varMensaje: String; // Contendra la nueva contraseña.
begin
  // Verificar si exixte el correo electronico ingresado.
  if tblUsuario.Locate('correo', ECorreo.Text, []) then
  begin
    // Obtener los datos originales de la BD.
    varCelular := tblUsuario.FieldByName('telefono').aSString;
    varMensaje := tblUsuario.FieldByName('password').aSString;

    // Llamar a SendSMS que recibe 2 paramentros
    // target: Destinatario de SMS; message: contenido del SMS;
    // Modificar. poner los datos de la base de datos, numero de telefono y la contraseña
    SendSMS(varCelular, 'Tu contraseña es: ' + varMensaje);
  end;
end;

procedure TfrmLogin.BtnRegistrarClick(Sender: TObject);
begin
{$IF DEFINED(MSWINDOWS)}
  frmRegistro.ShowModal;
{$ELSE}
  frmRegistro.Show;
{$ENDIF}
end;

// Para terminar con la ejecucion del programa
procedure TfrmLogin.BtnSalirClick(Sender: TObject);
begin
  DB.close;
  tblUsuario.close;
  tblProducto.close;
  close;
end;

// Para mostrar la contraseña escrita por el usuario.
procedure TfrmLogin.CheckMPChange(Sender: TObject);
begin
  EPassword.Password := not CheckMP.IsChecked;
end;

// Si todos los campos están llenos, habilitar el botón, de lo contrario, deshabilítar.
procedure TfrmLogin.ValidarCampos(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  BtnIniciar.Enabled := (ECorreo.Text <> '') and (EPassword.Text <> '');
end;

// Activa y desactiva las imagenes.
procedure TfrmLogin.FormResize(Sender: TObject);
var
  s: IFMXScreenService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, s)
  then
  begin
    case s.GetScreenOrientation of
      // Portrait Orientation: Mostrar imagenes.
      TScreenOrientation.Portrait:
        begin
          Image1.Visible := true;
        end;

      // Landscape Orientation: Ocultar imagenes.
      TScreenOrientation.Landscape:
        begin
          Image1.Visible := false;
        end;

      // InvertedPortrait Orientation: Mostrar imagenes.
      TScreenOrientation.InvertedPortrait:
        begin
          Image1.Visible := true;
        end;

      // InvertedLandscape Orientation: Ocultar imagenes.
      TScreenOrientation.InvertedLandscape:
        begin
          Image1.Visible := false;
        end;
    end;
  end;
end;

end.
