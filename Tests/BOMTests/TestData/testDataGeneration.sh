#!/bin/bash

echo "Creating file without BOM"
echo 'Test data' >> no_bom.txt

# UTF-8
echo "Creating UTF-8 Files with BOM"
printf '\xEF\xBB\xBF' > utf8_bom.txt
echo 'Test data' >> utf8_bom.txt

# UTF-16
echo "Creating UTF-16-BE Files with BOM" 
printf '\xFE\xFF' > utf16be_bom.txt
echo 'Test data' >> utf16be_bom.txt

echo "Creating UTF-16-LE Files with BOM" 
printf '\xFF\xFE' > utf16le_bom.txt
echo 'Test data' >> utf16le_bom.txt

# UTF-32
echo "Creating UTF-32-BE Files with BOM"
printf '\x00\x00\xFE\xFF' > utf32be_bom.txt
echo 'Test data' >> utf32be_bom.txt

echo "Creating UTF-32-LE Files with BOM"
printf '\xFF\xFE\x00\x00' > utf32le_bom.txt
echo 'Test data' >> utf32le_bom.txt
