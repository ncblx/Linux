grep Access-Reject auth_log*.log > 1
awk '{print $8}' 1 >1.1
sort 1.1 | uniq --count
