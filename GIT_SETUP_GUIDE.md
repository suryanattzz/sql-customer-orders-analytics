# Git Setup Guide for SQL Project

This guide walks you through setting up version control for the **Customer Orders Schema and Reporting** project.

---

## 📋 Prerequisites

- [x] Git installed on your system ([download here](https://git-scm.com/downloads))
- [x] GitHub/GitLab/Bitbucket account (if pushing to remote)
- [x] Project files organized and ready to commit

---

## 🚀 Step-by-Step Setup

### **Step 1: Initialize Git Repository**

Open terminal/command prompt in the project directory:

```bash
cd "d:\Projects\SQL - Customer Orders Schema and Reporting"
git init
```

This creates a `.git` folder and initializes version control.

---

### **Step 2: Verify .gitignore**

The `.gitignore` file is already created to exclude:
- IDE configuration files (`.vscode/`)
- Temporary/backup files (`*.bak`, `*.tmp`)
- Database credentials (`.env`, `*credentials*`)
- Large dump files (optional)

**Verify it exists:**
```bash
ls -la .gitignore  # Linux/Mac
dir .gitignore     # Windows
```

**Important:** The `.gitignore` is configured to:
- ✅ **KEEP**: SQL scripts, CSV outputs, documentation, ERD diagrams
- ❌ **EXCLUDE**: `.vscode/` folder (IDE-specific settings)

---

### **Step 3: Configure Git Identity (First Time Only)**

If you haven't set up Git before:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Or configure for this project only (remove `--global`):
```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

---

### **Step 4: Stage Files for Initial Commit**

Add all project files:

```bash
git add .
```

**Check what will be committed:**
```bash
git status
```

You should see:
```
Changes to be committed:
  new file:   .gitignore
  new file:   README.md
  new file:   SQL_CHEAT_SHEET.md
  new file:   folder_structure.txt
  new file:   sql_week_01/00_create_database.sql
  new file:   sql_week_01/01_schema.sql
  ... (all your SQL files)
  new file:   outputs_csv/revenue_by_day.csv
  ... (and more files)
```

**Verify `.vscode/` is excluded** (should NOT appear in the list).

---

### **Step 5: Create Initial Commit**

Commit all files with a descriptive message:

```bash
git commit -m "Initial commit: Customer Orders Schema and Reporting project

- Week 01: Core schema with customers, products, orders, order_items
- Week 01: 6 reporting queries (non-optimized)
- Week 01: Database views and indexes
- Week 02: Extended schema with returns, promotions, inventory
- Week 02: 12 advanced analytics queries (non-optimized)
- Week 02: Comprehensive indexing strategy
- Documentation: README, SQL cheat sheet, ERD diagrams
- Data: 100+ rows per table with Indian customer data"
```

---

### **Step 6: Create Logical Commit History (Optional but Recommended)**

Instead of one large commit, you can create a structured history:

#### **Option A: Structured Multi-Commit Approach**

```bash
# Reset to start fresh
git reset

# Commit 1: Project setup
git add .gitignore GIT_SETUP_GUIDE.md README.md project_description.txt folder_structure.txt
git commit -m "docs: Initial project setup and documentation"

# Commit 2: Week 01 SQL scripts
git add sql_week_01/*.sql
git commit -m "feat: Week 01 SQL schema and reports

- Database schema with 4 core tables
- Insert scripts with 100+ rows per table
- 6 reporting queries (non-optimized)
- Views and indexes for performance"

# Commit 3: CSV outputs
git add outputs_csv/*.csv ERD\ Diagrams_week_01/
git commit -m "data: Week 01 CSV outputs and ERD diagrams"

# Commit 4: Week 02 SQL scripts
git add sql_week_02/*.sql
git commit -m "feat: Week 02 advanced analytics queries

- Extended schema with returns, promotions, inventory
- 12 advanced analytics queries (non-optimized)
- Comprehensive indexing strategy with explanations
- RFM scoring, cohort retention, margin analysis"

# Commit 5: Week 02 query files (non-optimized)
git add outputs_week_02/query_*.sql ERD\ Diagrams_week_02/
git commit -m "data: Week 02 query files and ERD diagrams"

# Commit 6: Documentation
git add SQL_CHEAT_SHEET.md SQL_QUICK_REFERENCE.sql
git commit -m "docs: Add SQL cheat sheet and quick reference"
```

#### **Option B: Single Commit (Simpler)**

Already done in Step 5 above.

---

### **Step 7: Create Branches (Optional)**

If you plan to continue development:

```bash
# Create and switch to a development branch
git checkout -b development

# Or create feature branches
git checkout -b feature/week-03-advanced-analytics
git checkout -b feature/stored-procedures
git checkout -b hotfix/data-consistency
```

**Recommended branching strategy:**
- `main` → Production-ready code
- `development` → Active development
- `feature/*` → New features
- `hotfix/*` → Bug fixes

---

### **Step 8: Connect to Remote Repository (GitHub/GitLab)**

#### **Option A: Create New Repository on GitHub**

1. Go to [GitHub](https://github.com/new)
2. Create repository: `customer-orders-sql-project`
3. **Do NOT initialize** with README (you already have one)
4. Copy the repository URL

#### **Option B: Use Existing Repository URL**

```bash
# Add remote origin
git remote add origin https://github.com/YOUR_USERNAME/customer-orders-sql-project.git

# Or use SSH
git remote add origin git@github.com:YOUR_USERNAME/customer-orders-sql-project.git

# Verify remote
git remote -v
```

---

### **Step 9: Push to Remote**

```bash
# Push main branch
git push -u origin main

# Or if you named your branch 'master'
git push -u origin master

# Push all branches
git push --all origin
```

**First-time authentication:**
- GitHub may prompt for username/password
- Use **Personal Access Token** instead of password ([create here](https://github.com/settings/tokens))
- Or configure SSH keys for passwordless authentication

---

### **Step 10: Verify on GitHub**

Visit your repository URL:
```
https://github.com/YOUR_USERNAME/customer-orders-sql-project
```

You should see:
- ✅ All SQL files organized by week
- ✅ README.md displayed on homepage
- ✅ CSV outputs and ERD diagrams
- ✅ Documentation files
- ❌ No `.vscode/` folder (excluded by .gitignore)

---

## 📦 Recommended Repository Structure

```
customer-orders-sql-project/
├── .gitignore                     ← Exclude unnecessary files
├── README.md                      ← Project overview
├── GIT_SETUP_GUIDE.md            ← This file
├── SQL_CHEAT_SHEET.md            ← SQL reference guide
├── SQL_QUICK_REFERENCE.sql       ← Quick SQL snippets
├── folder_structure.txt          ← Project structure
├── project_description.txt       ← Project requirements
│
├── sql_week_01/                  ← Week 1 SQL scripts
│   ├── 00_create_database.sql
│   ├── 01_schema.sql
│   ├── 02_insert_customers.sql
│   ├── ...
│   └── 08_indexes.sql
│
├── sql_week_02/                  ← Week 2 SQL scripts
│   ├── 00_create_database.sql
│   ├── 01_schema.sql
│   ├── ...
│   ├── 09_indexes_week_02.sql
│   └── INDEX_STRATEGY_GUIDE.md
│
├── outputs_csv/                  ← CSV outputs (table/report exports)
│   ├── revenue_by_day.csv
│   ├── top_products.csv
│   └── ...
│
├── outputs_week_02/              ← Week 2 query files (non-optimized)
│   ├── query_01_MOM%change.sql
│   ├── query_02_RFM_customer_score.sql
│   └── ...
│
├── ERD Diagrams_week_01/         ← Week 1 diagrams
└── ERD Diagrams_week_02/         ← Week 2 diagrams
```

---

## 🔄 Daily Git Workflow

### **Making Changes**

```bash
# 1. Check current status
git status

# 2. See what changed
git diff

# 3. Stage specific files
git add sql_week_02/new_query.sql

# Or stage all changes
git add .

# 4. Commit with descriptive message
git commit -m "feat: Add customer segmentation query"

# 5. Push to remote
git push origin main
```

### **Viewing History**

```bash
# View commit log
git log --oneline --graph --all

# View specific file history
git log --follow sql_week_01/01_schema.sql

# View changes in a commit
git show COMMIT_HASH
```

### **Undoing Changes**

```bash
# Discard local changes (not staged)
git checkout -- sql_week_01/06_reports.sql

# Unstage a file (keep changes)
git reset HEAD sql_week_01/06_reports.sql

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) ⚠️ DANGEROUS
git reset --hard HEAD~1
```

---

## 📝 Commit Message Conventions

Use semantic prefixes for clarity:

```bash
feat:     New feature or query
fix:      Bug fix or data correction
docs:     Documentation changes
refactor: Code restructuring (no functional change)
perf:     Performance optimization
test:     Add or update tests
chore:    Maintenance tasks (dependencies, build)
data:     Data updates (CSV exports, sample data)
```

**Examples:**
```bash
git commit -m "feat: Add RFM customer scoring query"
git commit -m "fix: Correct order total calculation logic"
git commit -m "docs: Update README with week 02 structure"
git commit -m "perf: Add indexes for cohort retention query"
git commit -m "data: Export updated revenue trend CSV"
```

---

## 🏷️ Tagging Releases

Mark important milestones:

```bash
# Tag week 01 completion
git tag -a v1.0-week01 -m "Week 01: Core schema and reports complete"
git push origin v1.0-week01

# Tag week 02 completion
git tag -a v2.0-week02 -m "Week 02: Advanced analytics and optimization"
git push origin v2.0-week02

# List all tags
git tag -l

# Checkout a specific version
git checkout v1.0-week01
```

---

## 🔒 Security Best Practices

### ⚠️ **NEVER commit:**
- Database credentials (`.env` files)
- Connection strings with passwords
- MySQL root passwords
- API keys or tokens
- Personal information (real customer data)

### ✅ **Safe to commit:**
- SQL schema files
- Sample/anonymous data
- Query scripts
- CSV exports (if anonymized)
- Documentation

### **If you accidentally committed credentials:**

```bash
# Remove from history (⚠️ rewrites history)
git filter-branch --tree-filter 'rm -f config/database.yml' HEAD

# Or use BFG Repo-Cleaner (recommended)
bfg --delete-files database.yml
```

Then **immediately change the exposed credentials!**

---

## 🤝 Collaborating with Others

### **Clone Repository**
```bash
git clone https://github.com/YOUR_USERNAME/customer-orders-sql-project.git
cd customer-orders-sql-project
```

### **Pull Latest Changes**
```bash
git pull origin main
```

### **Resolve Merge Conflicts**
```bash
# If conflicts occur during pull/merge
git status  # See conflicted files

# Edit files manually, look for:
<<<<<<< HEAD
Your changes
=======
Their changes
>>>>>>> branch-name

# After resolving
git add conflicted_file.sql
git commit -m "merge: Resolve conflicts in schema.sql"
```

---

## 📊 GitHub Repository Settings

### **Create Repository Description**
```
MySQL database project for customer orders, analytics, and reporting with 
advanced optimization queries, RFM scoring, cohort retention analysis, and 
comprehensive indexing strategy
```

### **Add Topics (Tags)**
```
mysql, sql, database, analytics, reporting, rfm-analysis, 
cohort-retention, query-optimization, indexing, data-analysis
```

### **Create Repository README.md Sections**
Ensure your README includes:
- [x] Project overview
- [x] Technologies used (MySQL 8.0)
- [x] Installation instructions
- [x] Usage examples
- [x] Project structure
- [x] Features (Week 01 & Week 02)
- [x] Contributing guidelines (optional)
- [x] License (optional)

---

## 🎓 Git Resources

- [Official Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Atlassian Git Tutorial](https://www.atlassian.com/git/tutorials)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)

---

## ✅ Quick Checklist

Before pushing to remote:

- [ ] `.gitignore` created and tested
- [ ] No credentials or sensitive data in files
- [ ] README.md is complete and up-to-date
- [ ] SQL scripts tested and working
- [ ] Folder structure is clean and organized
- [ ] Commit messages are descriptive
- [ ] `.vscode/` folder excluded
- [ ] CSV outputs reviewed (no sensitive data)

---

## 💡 Tips

1. **Commit often**: Small, focused commits are better than large ones
2. **Write clear messages**: Future you will thank you
3. **Review before pushing**: Use `git diff` and `git status`
4. **Use branches**: Keep `main` stable, experiment in branches
5. **Pull before push**: Always sync with remote first
6. **Tag releases**: Mark milestones with version tags

---

Ready to push your SQL project to the world! 🚀
