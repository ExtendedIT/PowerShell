Import-Module AWSPowerShell
#Set the region of your cloudwatch
Set-AWSDefaultRegion -Region eu-central-1

#Feel free to change this to match any existing namespaces you might have.
$Namespace = 'service-monitor'

#Update the log path, use this for troubleshooting. 
$logpath = "C:\Scripts\Slog.txt"


#Use an AWS Service to get this systems Instance ID
$instanceId = (New-Object System.Net.WebClient).DownloadString("http://169.254.169.254/latest/meta-data/instance-id")

#
$instanceId | Out-File -FilePath $logpath -Append

# Associate current EC2 instance with your custom cloudwatch metric
$instanceDimension = New-Object -TypeName Amazon.CloudWatch.Model.Dimension;
$instanceDimension.Name = "instanceid";
$instanceDimension.Value = $instanceId;

    $metrics = @();

    #Adjust this to  pick up your service or services, this will work fine with multiple services. 
    $runningServices = Get-Service -Name MSSQLSERVER | ? { $_.Status -eq 'Running' }
    $runningServices | Out-File -FilePath $logpath -Append

    # For each running service, add a metric to metrics collection that adds a data point to a CloudWatch Metric named 'Status' with dimensions: instanceid, servicename
        $runningServices | % { 
        $dimensions = @();

        $serviceDimension = New-Object -TypeName Amazon.CloudWatch.Model.Dimension;
        $serviceDimension.Name = "service"
        $serviceDimension.Value = $_.Name;

        Write-Output "SD = $($serviceDimension.Value)" | Out-File -FilePath $logpath -Append  

        $dimensions += $instanceDimension;
        $dimensions += $serviceDimension;

        $metric = New-Object -TypeName Amazon.CloudWatch.Model.MetricDatum;
        $metric.Timestamp = [DateTime]::UtcNow;
        $metric.MetricName = 'Status';
        $metric.Value = 1;
        $metric.Dimensions = $dimensions;


        $metrics += $metric;    
        
        Write-Output "$metrics" | Out-File -FilePath $logpath -Append   

        Write-Output "Service: $($_.Name) is running" | Out-File -FilePath $logpath -Append
    }

    # This cmdlet doesn't fail gracefully so we will run it in a try / catch. 
    try {
    Write-CWMetricData -Namespace $Namespace -MetricData $metrics -Verbose
    } catch {
        Write-Output "CWMetric Failed" | Out-File -FilePath $logpath -Append 
    }
    # 
    