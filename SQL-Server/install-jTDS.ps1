$jtds_version     = '1.3.3'
$dest_dir         = "$home/bin/sqldeveloper/jdbc/lib"
$prod_pref_dir    = "$env:appdata/SQL Developer/system19.2.1.247.2212/o.sqldeveloper"
$prod_pref_name   = "$prod_pref_dir/product-preferences.xml"

invoke-webRequest "https://github.com/milesibastos/jTDS/releases/download/v1.3.3/jtds-$jtds_version-dist.zip"    -o jtds.zip

expand-archive jtds.zip  jtds

$jtds_jar_name = "jtds-$jtds_version.jar"
copy-item "jtds/$jtds_jar_name" $dest_dir

pushd $prod_pref_dir
$jtds_jar_rel_path =  get-item "$dest_dir/$jtds_jar_name" | resolve-path -relative
popd

# ----- Write config.xml

[xml] $prod_pref_xml = get-content $prod_pref_name

$list_TPDRIVER = $prod_pref_xml.CreateNode('element', 'list', '') # 3rd parameter is namespace
$url           = $prod_pref_xml.CreateNode('element', 'url' , '')

$list_TPDRIVER.SetAttribute('n', 'TPDRIVER')
$url.SetAttribute('path'     , $jtds_jar_rel_path)
$url.SetAttribute('jar-entry',''                 )

$list_TPDRIVER.AppendChild($url)

$db_config = $prod_pref_xml.SelectSingleNode('//*[@n="DBConfig"]')
$db_config.AppendChild($list_TPDRIVER)

$prod_pref_xml.Save($prod_pref_name)
