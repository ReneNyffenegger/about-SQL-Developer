#
#  Version 0.02
#
set-strictMode -version latest

$productPreferencesFile = get-childItem "$env:appdata\SQL Developer\system*\o.sqldeveloper\product-preferences.xml"

if ($productPreferencesFile -eq $null) {
   write-host "Product preference file does not exist or was not found."
   return
}

if ($productPreferencesFile -is [array]) {
   write-host "Unable to determine product preference file uniquely"
   return
}

write-host "product preferences file: $productPreferencesFile"

copy-item $productPreferencesFile "$productPreferencesFile.bak"

$nameTable = new-object System.Xml.NameTable
$nsMgr     = new-object System.Xml.XmlNamespaceManager $nameTable
$nsMgr.AddNamespace('ide', 'http://xmlns.oracle.com/ide/hash')


[xml] $doc = new-object xml
$doc.Load($productPreferencesFile)

$DBConfig = $doc.SelectSingleNode('/ide:preferences/hash[@n="DBConfig"]', $nsMgr)

if ($DBConfig -eq $null) {
 #
 # At least the element DBConfig is expected
 #
   write-host "DBConfig not found"
   return
}

function set-DBConfig-value($n, $v) {

   $node = $DBConfig.SelectSingleNode("value[@n='$n']")

   if ($node -eq $null) {
      $node = $doc.CreateElement('value')
      $node.SetAttribute('n', $n)
      $null = $DBConfig.AppendChild($node)
   }

   write-host "Changing $n from $($node.GetAttribute('v')) to $v"

   $node.SetAttribute('v', $v)
}

# set-DBConfig-value ''                        'C:\Users\Rene\github\Oracle\SQLPATH\login.sql'  # Startup script
# set-DBConfig-value 'DEFAULTPATH'             'C:\Users\Rene'
  set-DBConfig-value 'NLS_DATE_FORM'           'yyyy-mm-dd hh24:mi:ss'
  set-DBConfig-value 'NLS_TS_FORM'             'yyyy-mm-dd hh24:mi:ssXff'
  set-DBConfig-value 'NLS_TS_TZ_FORM'          'yyyy-mm-dd hh24:mi:ssXff tzr'
  set-DBConfig-value 'NULLDISPLAY'             '-'
  set-DBConfig-value 'NULLCOLOR'               'NONE'
  set-DBConfig-value 'GLOGIN'                  'true'
# set-DBConfig-value 'KERBEROS_CONFIG'         'C:\Oracle\network\admin\krb5.conf'
# set-DBConfig-value 'TNS_NAMES_DIR'           'C:\oracle\network\admin'
# set-DBConfig-value 'UNSHAREDWORKSHEETOPEN'   'true'
# set-DBConfig-value 'USE_THICK_DRIVER'        'true'

$doc.Save($productPreferencesFile)
