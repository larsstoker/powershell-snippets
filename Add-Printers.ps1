function Add-Printers {
  param (
    # Location of the txt file containing the printers
    [Parameter(mandatory)]
    [string]
    $list,
    # Printserver name, only use this if you have a printserver
    [Parameter()]
    [string]
    $server
  )
  
  $list = Get-Content "$list"

  foreach ($printer in $list) {

    # If a printserver is specified, append that to the printername
    if ($server) {
      $printer = "\\$_\$printer"
    }
    
    # Get a list of existing printers
    $existing = Get-Printer | Select-Object -ExpandProperty Name

    if ($existing -notcontains $printer) {
      Add-Printer -ConnectionName $printer -ErrorVariable addErrors
      # Write to host if printer was added successfully
      if ($addErrors.Count -eq 0) {
        Write-Host "$printer added"
      }
      # If any errors were encountered, write to host
      else {
        Write-Host "$printer could not be added: $addErrors"
      }
    }
    # If new printer has already been added, write that to host
    else {
      Write-Host "$printer has already been added, skipping..."
    }
  }
}