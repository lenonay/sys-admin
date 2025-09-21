########### Formas de ejecutar
# Desconectar: conhost.exe --headless powershell -NoExit -ExecutionPolicy Bypass -File C:\temp\printers\printer.ps1 -Disconnect 1
# Conectar: conhost.exe --headless powershell -NoExit -ExecutionPolicy Bypass -File C:\temp\printers\printer.ps1 -Spirit DRJTF

########### VARIABLES
param (
    [string]$Spirit = "Null",
    [string]$Path = "C:\temp\printers",
    [string]$Disconnect = 0
)
# Server de impresión
$Server = "\\maddcprnv01.alg.hyattdir.net"

# Spirit Validos
[array]$ValidSpirits = "ALTEN","ASORA", "ASCOA", "ALATG", "ALVFU", "ALSFU", "DRJTF", "SECBR"

# Log
$LogFile = "$Path\log.txt";

# Fecha de inicio
$InitDate = Get-Date

########### FUNCIONES ##############
function InitLog (){
    # Si no hay archivo lo creamos
    if(Test-Path $LogFile){
        # Vaciamos el Log si ya existe
        Set-Content -Path $LogFile -Value "Comienzo: $InitDate"
    } Else {
        New-Item -ItemType File -Path $LogFile -Value "Comienzo: $InitDate"
    }
}

function AddLog([string]$Text, [bool]$Title = $false) {
    if($Title) { $Text = "##################### $Text #####################" }

    Add-Content -Path $LogFile -Value $Text
}

function EndLog(){
    $EndDate = Get-Date

    # Calculamos en el timepo transcurrido
    $ElapsedRaw = $(New-TimeSpan -Start $InitDate -End $EndDate)

    AddLog -Text "-@-" -Title $true
    AddLog -Text "Finalizado $(Get-Date)"
    AddLog -Text "Tiempo transcurrido: $($ElapsedRaw.Minutes) minutos $($ElapsedRaw.Seconds) segundos"
}

function ShowUse(){
    Write-Host "Uso correcto del Script:"
    Write-Host "powershell.exe -ExecutionPolicy Bypass -File 'C:\temp\printers\printer.ps1' -Spirit 'CODIGO'"
    Read-Host "Presione Enter para cerrrar"
}

function DisconnectAll(){
    # Mostramos que estamos desconectando en el Log
    AddLog -Text "COMENZANDO DESCONEXION" -Title $true
    
    # Vamos a recuperar todas las impresoras de MADDC
    [array]$Printers = Get-Printer | Where-Object { $_.ComputerName -like "*maddc*" }
    

    # Si hay al menos 1 iteramos
    if($Printers.Count -ge 0){
        $Printers.ForEach({
            # Por cada una la vamos eliminando
            Remove-Printer -Name $_.Name

            # Añadimos al registro que hemos eliminado esa impresora
            AddLog -Text "Impresora: $($_.Name), desconectada"
        })
    }
}

function CheckDisconnect() {
    # Si tenemos que desconectar llamamos a la funcion
    if($Disconnect -eq 1){
        DisconnectAll

        EndLog
        # Nos salimos
        Exit
    }
}

function CheckSpirit(){
# Comprobamos que el spirit sea válido
    if($ValidSpirits -notcontains $Spirit){
        # Metemos al Log
        AddLog -Text "El Spirit no es valido: ($($Spirit))"

        # Mostramos al usuario
        Write-Host "Spirit no valido"
        ShowUse # Mostramos el uso

        Exit # Salimos
    } 
}

function GetPrintersName {
    # Recuperamos todas las impresoras que coincidan con el patrón de nombre Spirit
    $Printers = Get-Printer -ComputerName $Server | Where-Object { $_.Name -like "$Spirit*" }

    # Añadimos el número total de impresoras al log
    AddLog -Text "Numero de impresoras encontradas ($Spirit): $($Printers.Count)"

    # Manejamos la cantidad de impresoras recuperadas
    switch ($Printers.Count) {
        0 {
            # Si no hay ninguna, devolvemos un array vacío
            return @()
        }
        1 {
            # Si hay una sola impresora, devolvemos un array con su nombre
            return @($Printers[0].Name)
        }
        default {
            # Si hay más de una, devolvemos un array con todos los nombres
            return $Printers | ForEach-Object { $_.Name }
        }
    }
}


function Main(){
    # Inicializamos el log
    InitLog

    # Revisamos si tenemos que conectar o desconectar
    CheckDisconnect

    # Comprobamos que el script sea valido
    CheckSpirit


    # Recuperamos las impresoras
    $AvaliablePrinters = GetPrintersName

    AddLog -Text "COMENZANDO CONEXION" -Title $true

    # Iteramos y añadimos cada impresora disponible
    foreach ($Printer in $AvaliablePrinters) {
        $PrinterPath = "$Server\$Printer"

        Try {
            Add-Printer -ConnectionName $PrinterPath

            AddLog -Text "$Printer, conectada correctamente"
        
        } Catch {
            AddLog -Text "Fallo al conectar: $Printer"
        }
    }
    
    EndLog
}
########## CUERPO ############
Main