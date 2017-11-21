#!/usr/bin/env ruby

def memory_check
# memory used as a percentage
  `free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }'`
end

def disk_check
  `df -h | awk '$NF=="/"{printf "%s", $5}'`
end
