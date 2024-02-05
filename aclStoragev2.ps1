param (
    [Parameter(Mandatory=$true)]
    [ValidateSet('adicionar','remover')] 
    [String] $addOrremove,
    [Parameter(Mandatory=$true)] 
    [String] $Subscription,  
    [Parameter(Mandatory=$true)] 
    [String] $userOrgroup,
    [Parameter(Mandatory=$true)] 
    [String] $objectId,
    [Parameter(Mandatory=$true)]
    [ValidateSet('leitura','escrita')] 
    [String] $typePermition,
    [Parameter(Mandatory=$true)] 
    [String] $storageName,
    [Parameter(Mandatory=$true)] 
    [String] $containerName,
    [Parameter(Mandatory=$true)]
    [String] $path
)
#Subscription
$SubscriptionId = Get-AutomationVariable -Name $Subscription
$idacl = Get-AutomationVariable -Name AclID

az login --identity

#incluindo group/user no grupo de ACL de primeira camada
$groupACL = az ad group member check --group $idacl --member-id $objectId -o json | ConvertFrom-Json

if ($groupACL.value -eq $False) {
    az ad group member add --group $idacl --member-id $objectId
    Write-Output "Adicionando ao <nome do grupo da primeira camada> o grupo: $objectId"
} else {
    Write-Output "O $objectId já existe no <nome do grupo da primeira camada>"
}

# set context
az account set --subscription $SubscriptionId
#função para entender o processo e aplicar conforme for especificado no parâmetro
if ($addOrremove.ToLower() -eq "adicionar") {
    Write-Output "Ação a ser realizada: ${addOrremove.ToLower()}"
    if ($typePermition -eq "leitura") {
        $permitionacl = "r-x"
        Write-Output "Permissão concedida: $permitionacl"
    } elseif ($typePermition -eq "escrita") {
        $permitionacl = "rwx"
        Write-Output "Permissão concedida: $permitionacl"
    }
    az storage fs access update-recursive --acl "default:${userOrgroup}:${objectId}:${permitionacl}" -p $path -f $containerName --account-name $storageName --auth-mode login && az storage fs access update-recursive --acl "${userOrgroup}:${objectId}:${permitionacl}" -p $path -f $containerName --account-name $storageName --auth-mode login   
} elseif ($addOrremove.ToLower() -eq "remover") {
    Write-Output "Ação a ser realizada: ${addOrremove.ToLower()}"
    az storage fs access remove-recursive --acl "default:${userOrgroup}:${objectId}" -p $path -f $containerName --account-name $storageName --auth-mode login && az storage fs access remove-recursive --acl "${userOrgroup}:${objectId}" -p $path -f $containerName --account-name $storageName --auth-mode login
} else {
    Write-Output "Parâmetro: $addOrremove inválido"
}