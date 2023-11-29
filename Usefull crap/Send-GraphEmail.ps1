<#
.SYNOPSIS
Sends an email using the Microsoft Graph API.

.DESCRIPTION
This function sends an email on behalf of a user using the Microsoft Graph API. 
The user's access token, recipient email address, subject, and body are required inputs.

.PARAMETER accessToken
The access token used for authenticating with the Microsoft Graph API.

.PARAMETER emailTo
The recipient's email address.

.PARAMETER emailSubject
The subject of the email.

.PARAMETER emailBody
The HTML content of the email body.

.PARAMETER saveToSentItems
(Optional) A switch to determine if the email should be saved to the sent items. Default is $true.

.PARAMETER userEmail
(Optional) The email address of the user on whose behalf the email is being sent. Default is 'jos.haarbos@stedergroup.com'.

.EXAMPLE
$token = "YOUR_ACCESS_TOKEN"
$to = "maarten@gmail.com"
$subject = "testietest"
$bodyHtml = "<h1>Hello!</h1><p>This is a test email.</p>"

Send-GraphEmail -accessToken $token -emailTo $to -emailSubject $subject -emailBody $bodyHtml

#>

function Send-GraphEmail {
    param(
        [Parameter(Mandatory=$true)]
        [string]$accessToken,

        [Parameter(Mandatory=$true)]
        [string]$emailTo,

        [Parameter(Mandatory=$true)]
        [string]$emailSubject,

        [Parameter(Mandatory=$true)]
        [string]$emailBody,

        [Parameter(Mandatory=$false)]
        [bool]$saveToSentItems = $true,

        [Parameter(Mandatory=$false)]
        [string]$userEmail = "jos.haarbos@stuff.com"
    )

    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type"  = "application/json"
    }

    $body = @{
        message = @{
            subject = $emailSubject
            body = @{
                contentType = "HTML"
                content = $emailBody
            }
            toRecipients = @(
                @{
                    emailAddress = @{
                        address = $emailTo
                    }
                }
            )
        }
        saveToSentItems = $saveToSentItems
    } | ConvertTo-Json -Depth 10

    $graphEndpoint = "https://graph.microsoft.com/v1.0/users/$userEmail/sendMail"

    try {
        Invoke-RestMethod -Uri $graphEndpoint -Headers $headers -Method POST -Body $body
        Write-Host "Email sent successfully."
    }
    catch {
        Write-Error "Error sending email: $_"
    }
}
