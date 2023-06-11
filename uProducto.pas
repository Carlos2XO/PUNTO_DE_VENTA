unit uProducto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, FMX.Edit,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.FMXUI.Wait,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TfrmProducto = class(TForm)
    ToolBar1: TToolBar;
    BtnLimpiar: TButton;
    BtnAtras: TButton;
    LTitulo: TLabel;
    Panel1: TPanel;
    VertScrollBox1: TVertScrollBox;
    Image4: TImage;
    LSubTitulo: TLabel;
    Panel2: TPanel;
    ECodigo: TEdit;
    ENombre: TEdit;
    ECantidad: TEdit;
    EPrecio: TEdit;
    EMarca: TEdit;
    Panel3: TPanel;
    ETipo: TEdit;
    BtnAgregarP: TButton;
    Panel4: TPanel;
    Label1: TLabel;
    procedure BtnAtrasClick(Sender: TObject);
    procedure BtnLimpiarClick(Sender: TObject);
    procedure BtnAgregarPClick(Sender: TObject);
    procedure VaciarCampos();
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProducto: TfrmProducto;

implementation

uses uMain;

{$R *.fmx}

procedure TfrmProducto.BtnAgregarPClick(Sender: TObject);
begin
  if ((ECodigo.Text <> '') and (ENombre.Text <> '') and (ECantidad.Text <> '')
    and (EPrecio.Text <> '') and (EMarca.Text <> '') and (ETipo.Text <> ''))
  then
  begin
    if frmLogin.tblProducto.Locate('idProducto', VarArrayOf([ECodigo.Text]), [])
    then
    begin
      ShowMessage
        ('Lo siento, pero el código de barra que has ingresado ya está en uso. Por favor, elige uno diferente para continuar.');
      ECodigo.Text := '';
    end
    else
    begin
      frmLogin.tblProducto.Append;
      frmLogin.tblProducto.FieldByName('idProducto').Value := ECodigo.Text.ToInteger;
      frmLogin.tblProducto.FieldByName('nombre').Value := ENombre.Text;
      frmLogin.tblProducto.FieldByName('cantidad').Value := ECantidad.Text;
      frmLogin.tblProducto.FieldByName('precio').Value := EPrecio.Text;
      frmLogin.tblProducto.FieldByName('marca').Value := EMarca.Text;
      frmLogin.tblProducto.FieldByName('tipo').Value := ETipo.Text;
      frmLogin.tblProducto.Post;
      ShowMessage('El producto se ha registrado con éxito en el inventario.');
      VaciarCampos();
    end;
  end
  else
  begin
    ShowMessage
      ('No has introducido los datos necesarios. Por favor, proporciona la información solicitada')
  end;
end;

// Para cerrar el frm.
procedure TfrmProducto.BtnAtrasClick(Sender: TObject);
begin
  close;
end;

// Para limpiar los campos del frm.
procedure TfrmProducto.BtnLimpiarClick(Sender: TObject);
begin
  VaciarCampos();
end;

procedure TfrmProducto.VaciarCampos();
begin
  ENombre.Text := '';
  ECodigo.Text := '';
  ECantidad.Text := '';
  EPrecio.Text := '';
  EMarca.Text := '';
  ETipo.Text := '';
end;

end.
