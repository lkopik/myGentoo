#!/bin/sh
 
curl -s https://goldprice.org/cryptocurrency-price | \
grep -e 'views-field views-field-field-crypto-price-1 views-align-right' \
| awk 'NR==2 {print substr( $0, -1, length($0)-6 )}' | sed  's/<[^>]*>//g' \
| awk '{$1=$1};1'
