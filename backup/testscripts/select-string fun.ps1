foreach ($doc in $(ls F:\BigDump)) 

{
cat $doc | select-string -pattern "[a-z_]+@[a-z]+\.(be)" >> "E:\export\belgian.txt"
}