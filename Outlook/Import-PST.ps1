function Import-PST {
	param (
		[Parameter(Mandatory)]
		[string]$pst
	)
	Add-type -AssemblyName "Microsoft.Office.Interop.Outlook"
	$outlook = new-object -comobject outlook.application
	$namespace = $outlook.GetNameSpace("MAPI")
	$namespace.AddStore($pst)
}