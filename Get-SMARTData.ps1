function Get-SMARTData {
	#Searchterm for $list
	$queryhash = @{
		NameSpace   = 'root\wmi'
		Class       = 'MSStorageDriver_FailurePredictStatus'
		ErrorAction = 'Continue'
	}
	#Search disks
	$list = Get-WmiObject @queryhash
	#Run Script
	if ($list) {
		$list | ForEach-Object {
			#Transform InstanceName to format usable by Get-WMIObject
			$drive = ($_.InstanceName).replace("_0", "")
			#Get the drive info from GWMI
			$disk = Get-WMIObject win32_diskdrive | Where-Object {
				$_.PNPDeviceID -like "$drive*"
			}
			#Get additional info (temp, hours, etc)
			$advanced = Get-PhysicalDisk -FriendlyName $disk.Model | Get-StorageReliabilityCounter
			#PredicFailure true/false to 0/1
			$PredictFailure = if (($_.PredictFailure) -like 'true') {
				0
			}
			elseif (($_.PredictFailure -like 'false')) {
				1
			}
			#For each disk create a pscustomobject
			$disk | ForEach-Object {
				$metrics = @{}
				$metrics.DriveName = $disk.Model
				$metrics.SerialNumber = ($disk.SerialNumber).Trimstart()
				$metrics.FailureImminent = $PredictFailure
				$metrics.Reason = $_.Reason
				$metrics.MediaType = $disk.MediaType
				$metrics.InterFace = $disk.InterfaceType
				$metrics.Partitions = $disk.Partitions
				$metrics.Size = $disk.Size
				$metrics.Temp = $advanced.Temperature
				$metrics.Hours = $advanced.PowerOnHours
				$metrics.MnfDate = $advanced.ManufactureDate
				$metrics.ReadErrors = $advanced.ReadErrorsTotal
				$metrics.WriteErrors = $advanced.WriteErrorsTotal
				""
				$metrics
			}
		}
	}
}

Get-SMARTData