#!/bin/bash

DATA_FILE="tasks.txt"
DELIM="|"

[ -f "$DATA_FILE" ] || touch "$DATA_FILE"

# ===============================
# Error Handler
# ===============================
error() {
    echo "❌ Error: $1"
    return 1
}

# ===============================
# ID Generator
# ===============================
generate_id() {
    if [ ! -s "$DATA_FILE" ]; then
        echo 1
    else
        awk -F"$DELIM" '{print $1}' "$DATA_FILE" | sort -n | tail -1 | awk '{print $1+1}'
    fi
}

# ===============================
# Validation Functions
# ===============================

validate_priority() {
    [[ "$1" =~ ^(high|medium|low)$ ]]
}

validate_status() {
    [[ "$1" =~ ^(pending|in-progress|done)$ ]]
}

validate_date() {
    date -d "$1" >/dev/null 2>&1
}

# Title must start with letter
validate_title() {
    [[ "$1" =~ ^[A-Za-z] ]] || return 1
    [[ "$1" != *"$DELIM"* ]] || return 1
}

# ===============================
# Add Task
# ===============================
add_task() {
    read -p "Enter Title: " title
    [[ -z "$title" ]] && error "Title cannot be empty" && return
    validate_title "$title" || { error "Title must start with a letter and not contain |"; return; }

    read -p "Enter Priority (high/medium/low): " priority
    validate_priority "$priority" || { error "Invalid priority"; return; }

    read -p "Enter Due Date (YYYY-MM-DD): " date
    validate_date "$date" || { error "Invalid date format"; return; }

    id=$(generate_id)

    echo "$id$DELIM$title$DELIM$priority$DELIM$date$DELIMpending" >> "$DATA_FILE" \
        || error "Failed to write to file"

    echo "✅ Task added successfully."
}

# ===============================
# List Tasks with Filtering
# ===============================
list_tasks() {
    echo "1. Show All"
    echo "2. Filter by Status"
    echo "3. Filter by Priority"
    read -p "Choose: " choice

    printf "\n%-5s %-20s %-10s %-12s %-15s\n" "ID" "Title" "Priority" "DueDate" "Status"
    echo "---------------------------------------------------------------"

    case $choice in
        1)
            awk -F"$DELIM" '{printf "%-5s %-20s %-10s %-12s %-15s\n",$1,$2,$3,$4,$5}' "$DATA_FILE"
            ;;
        2)
            read -p "Enter status: " s
            validate_status "$s" || { error "Invalid status"; return; }
            awk -F"$DELIM" -v st="$s" '$5==st {printf "%-5s %-20s %-10s %-12s %-15s\n",$1,$2,$3,$4,$5}' "$DATA_FILE"
            ;;
        3)
            read -p "Enter priority: " p
            validate_priority "$p" || { error "Invalid priority"; return; }
            awk -F"$DELIM" -v pr="$p" '$3==pr {printf "%-5s %-20s %-10s %-12s %-15s\n",$1,$2,$3,$4,$5}' "$DATA_FILE"
            ;;
        *)
            error "Invalid choice"
            ;;
    esac
}

# ===============================
# Delete Task
# ===============================
delete_task() {
    read -p "Enter ID: " id

    grep -q "^$id$DELIM" "$DATA_FILE" || { error "Task not found"; return; }

    read -p "Confirm delete? (y/n): " c
    [[ "$c" != "y" ]] && return

    sed -i "/^$id$DELIM/d" "$DATA_FILE" || error "Delete failed"

    echo "✅ Task deleted."
}

# ===============================
# Update Task
# ===============================
update_task() {
    read -p "Enter ID: " id

    line=$(grep "^$id$DELIM" "$DATA_FILE")
    [[ -z "$line" ]] && { error "Task not found"; return; }

    IFS="$DELIM" read -r id title priority date status <<< "$line"

    echo "Press ENTER to keep old value"

    read -p "New Title [$title]: " nt
    read -p "New Priority [$priority]: " np
    read -p "New Date [$date]: " nd

    echo "ℹ️  Status must be one of: (pending / in-progress / done)"
    read -p "New Status [$status]: " ns

    title=${nt:-$title}
    priority=${np:-$priority}
    date=${nd:-$date}
    status=${ns:-$status}

    validate_title "$title" || { error "Invalid title"; return; }
    validate_priority "$priority" || { error "Invalid priority"; return; }
    validate_status "$status" || { error "Invalid status"; return; }
    validate_date "$date" || { error "Invalid date"; return; }

    sed -i "s/^$id.*/$id$DELIM$title$DELIM$priority$DELIM$date$DELIM$status/" "$DATA_FILE" \
        || error "Update failed"

    echo "✅ Task updated."
}

# ===============================
# Search (Title Only)
# ===============================
search_tasks() {
    read -p "Enter keyword: " keyword

    printf "\n%-5s %-20s %-10s %-12s %-15s\n" "ID" "Title" "Priority" "DueDate" "Status"
    echo "---------------------------------------------------------------"

    awk -F"$DELIM" -v k="$keyword" 'tolower($2) ~ tolower(k) {
        printf "%-5s %-20s %-10s %-12s %-15s\n",$1,$2,$3,$4,$5
    }' "$DATA_FILE"
}

# ===============================
# Reports
# ===============================
summary_report() {
    awk -F"$DELIM" '{count[$5]++} END {for (s in count) print s ":" count[s]}' "$DATA_FILE"
}

overdue_tasks() {
    today=$(date +%F)
    awk -F"$DELIM" -v today="$today" '$4 < today && $5!="done"' "$DATA_FILE"
}

priority_report() {
    awk -F"$DELIM" '{print $3 " -> " $2}' "$DATA_FILE" | sort
}

# ===============================
# Main Menu
# ===============================
while true; do
    echo ""
    echo "===== TASK MANAGER ====="
    echo "1 Add Task"
    echo "2 List Tasks"
    echo "3 Update Task"
    echo "4 Delete Task"
    echo "5 Search Task"
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
        *) error "Invalid choice" ;;
    esac
done