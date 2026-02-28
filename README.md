# 📝 Bash Task Manager

A complete interactive **Task Management System** built using Bash scripting.  
This project allows users to manage daily tasks through a terminal-based menu with full CRUD operations, filtering, and reports.

---

## 🚀 Features

### ✅ Core Features
- Add new tasks with:
  - Auto-generated unique ID
  - Title validation
  - Priority selection
  - Due date validation
  - Default status = `pending`

- View tasks in a formatted table

- Update existing tasks:
  - Modify title, priority, date, or status

- Delete tasks with confirmation

- Search tasks by **title keyword**

---

### 🔍 Filtering
Users can filter tasks by:
- Status (pending / in-progress / done)
- Priority (high / medium / low)

---

### 📊 Reports
The system includes built-in reports:

- Task Summary (count per status)
- Overdue Tasks detection
- Priority Report

---

### 🛡️ Input Validation
The script ensures:

- Title:
  - Cannot be empty
  - Must start with a letter
  - Cannot contain the `|` delimiter

- Priority must be:
high / medium / low


- Status must be:

pending / in-progress / done


- Due date must be valid format:

YYYY-MM-DD


---

### ⚠️ Error Handling
- Clear error messages displayed for invalid inputs
- Prevents invalid operations
- Ensures safe file updates

---

## 📂 Data Storage

All tasks are stored in a single file:


tasks.txt


Format per line:


ID|Title|Priority|DueDate|Status


---

## ▶️ How to Run

### 1️⃣ Make script executable

```bash
chmod +x task_manager.sh

2️⃣ Run the program
./task_manager.sh

🛠️ Technologies Used

- Bash Scripting

- awk

- sed

- grep

- date command

📌 Project Type

Mini Task Manager — DevOps / Bash Scripting Practice Project

👨‍💻 Author

Ahmed Abd Elnasser