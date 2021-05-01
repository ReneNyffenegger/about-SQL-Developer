#
#  Initial version 0.01
#
set-strictMode -version latest

$productPreferencesFile = "$env:appdata\SQL Developer\system19.2.1.247.2212\o.sqldeveloper\product-preferences.xml"

if (-not (test-path $productPreferencesFile) ) {
   write-host "$productPreferencesFile does not exist"
   return
}

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

set-DBConfig-value ''               'C:\Users\Rene\github\Oracle\SQLPATH\login.sql'  # Startup script
set-DBConfig-value 'NLS_DATE_FORM'  'yyyy-mm-dd hh24:mi:ss'
set-DBConfig-value 'NLS_TS_FORM'    'yyyy-mm-dd hh24:mi:ssXff'
set-DBConfig-value 'NLS_TS_TZ_FORM' 'yyyy-mm-dd hh24:mi:ssXff tzr'
set-DBConfig-value 'NULLDISPLAY'    '-'
set-DBConfig-value 'GLOGIN'         'true'

$doc.Save($productPreferencesFile)
