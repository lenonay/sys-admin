## Busqueda en el visor de eventos:
```xml
  <QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
      *[System[(EventID=4624) and TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]
      and
      *[EventData[Data[@Name='TargetUserName'] and (Data='Asir2')]]
    </Select>
  </Query>
</QueryList>
```

## Comando de PowerShell
**Requiere permisos de Admin**
```ps1
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624} | Where-Object {($_.Properties[5].Value -eq 'Asir2')} | Select-Object TimeCreated, @{Name='Usuario';Expression={$_.Properties[5].Value}}
```
