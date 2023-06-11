program RCP;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {frmLogin},
  vkbdhelper in 'vkbdhelper.pas',
  uRegistrar in 'uRegistrar.pas' {frmRegistro},
  uMenu in 'uMenu.pas' {frmMenu},
  uProducto in 'uProducto.pas' {frmProducto},
  uInventario in 'uInventario.pas' {frmInventario};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmRegistro, frmRegistro);
  Application.CreateForm(TfrmMenu, frmMenu);
  Application.CreateForm(TfrmProducto, frmProducto);
  Application.CreateForm(TfrmInventario, frmInventario);
  Application.Run;
end.
