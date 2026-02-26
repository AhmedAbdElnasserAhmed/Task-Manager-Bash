#!/bin/bash

DATA_FILE="tasks.txt"
DELIM="|"

[ -f "$DATA_FILE" ] || touch "$DATA_FILE"

generate_id() {
    if [ ! -s "$DATA_FILE" ]; then
        echo 1
    else
        awk -F"$DELIM" '{print $1}' "$DATA_FILE" | sort -n | tail -1 | awk '{print $1+1}'
    fi
}

validate_priority() {
    [[ "$1" =~ ^(high|medium|low)$ ]]
}

add_task() {
    read -p "Enter Title: " title
    [[ -z "$title" ]] && { echo "Title cannot be empty"; return; }

    read -p "Enter Priority (high/medium/low): " priority
    validate_priority "$priority" || { echo "Invalid priority"; return; }

    read -p "Enter Due Date (YYYY-MM-DD): " date
    date -d "$date" >/dev/null 2>&1 || { echo "Invalid date"; return; }

    id=$(generate_id)
    echo "$id$DELIM$title$DELIM$priority$DELIM$date$DELIMpending" >> "$DATA_FILE"
    echo "Task added."
}

list_tasks() {
    printf "%-5s %-20s %-10s %-12s %-15s
" "ID" "Title" "Priority" "DueDate" "Status"
    echo "-------------------------------------------------------------"
    awk -F"$DELIM" '{printf "%-5s %-20s %-10s %-12s %-15s
",$1,$2,$3,$4,$5}' "$DATA_FILE"
}

delete_task() {
    read -p "Enter ID: " id
    grep -q "^$id$DELIM" "$DATA_FILE" || { echo "Not found"; return; }
    read -p "Confirm delete? (y/n): " c
    [[ "$c" != "y" ]] && return
    sed -i "/^$id$DELIM/d" "$DATA_FILE"
    echo "Deleted."
}

update_task() {
    read -p "Enter ID: " id
    line=$(grep "^$id$DELIM" "$DATA_FILE") || { echo "Not found"; return; }

    IFS="$DELIM" read -r id title priority date status <<< "$line"

    read -p "New Title [$title]: " nt
    read -p "New Priority [$priority]: " np
    read -p "New Date [$date]: " nd
    read -p "New Status [$status]: " ns

    title=${nt:-$title}
    priority=${np:-$priority}
    date=${nd:-$date}
    status=${ns:-$status}

    sed -i "s/^$id.*/$id$DELIM$title$DELIM$priority$DELIM$date$DELIM$status/" "$DATA_FILE"
    echo "Updated."
}

search_tasks() {
    read -p "Keyword: " k
    grep -i "$k" "$DATA_FILE"
}

summary_report() {
    awk -F"$DELIM" '{count[$5]++} END {for (s in count) print s, count[s]}' "$DATA_FILE"
}

overdue_tasks() {
    today=$(date +%F)
    awk -F"$DELIM" -v today="$today" '$4 < today && $5!="done"' "$DATA_FILE"
}

priority_report() {
    awk -F"$DELIM" '{print $3 " -> " $2}' "$DATA_FILE" | sort
}

while true; do
    echo "===== TASK MANAGER ====="
    echo "1 Add"
    echo "2 List"
    echo "3 Update"
    echo "4 Delete"
    echo "5 Search"
    echo "6 Summary Report"
    echo "7 Overdue Tasks"
    echo "8 Priority Report"
    echo "9 Exit"
    read -p "Choose: " ch

    case $ch in
        1) add_task ;;
        2) list_tasks ;;
        3) update_task ;;
        4) delete_task ;;
        5) search_tasks ;;
        6) summary_report ;;
        7) overdue_tasks ;;
        8) priority_report ;;
        9) exit ;;
        *) echo "Invalid";;
    esac
done
