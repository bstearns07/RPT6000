# RPT 6000
![License](https://img.shields.io/badge/License-MIT-green)<br>

---

## 👤 Authors
Ben Stearns - [@bstearns07](https://github.com/bstearns07)<br>
Tristan Joubert - [@TJouber004](https://github.com/TJoubert004)
---

## 📑 Table of Contents
- [📌 Summary](#-summary)
- [✨ Features](#-features)
- [🧾Report Breakdown](#-report-breakdown)
- [⚙️ How It Works](#how-it-works)
- [🧰 Tech Stack](#-tech-stack)
- [🧠 Topics Covered](#-topics-covered)
- [📘 What I Learned](#-what-i-learned)
- [🖼 Screenshots](#-screenshots)

---

## 📌 Summary

The **Report 6000** application adds even more COBOL bells and whistles to make the code and report look more polished than ever before.
Not only does the code utilize more COBOL features to make the code more readable and flexible such as INITIALIZE, PACKED-DECIMAL, and REDIFINE statements, but now the report displays the salerep's name. How does it do that you make ask? Why, with a table lookup of course. A new data file has been added to the program, which is then read in by the program to find a rep's name by their id.<br>
<br>
For full program details, refer to [Program Requirements](./assets/Assignment_Instruction.pdf) 

---

## ✨ Features

- Sorted by branch number and sale representive number
- Customer sales totals by this year-to-date, last-year-to-date, change amount, and chance percent
- Final totals across all customer for this year-to-date, last-year-to-date, change amount, and chance percent
- Both branch AND sale representative sale totals
- More standadized COBOL coding syntax
- (new) Additional EVALUATE, PACKED-DECIMAL, and REDIFINE statements for more concise/flexible coding
- (new) Looks up a salerep's name by their id within a Table data structure
- (new) Copies data from other members
---

## 🧾 Report Breakdown

![rpt-5000](assets/report.png)

### 📊 Report Fields Overview
| Field | Description |
|------|-------------|
| 🏢 Branch | The branch that handled the sale |
| 👤 Sales Rep | The representative responsible for the sale |
| 🆔 Customer Number | Unique ID assigned to the customer |
| 📛 Customer Name | Name of the customer |
| 💰 Sales This YTD | Total sales for the current year-to-date |
| 📉 Sales Last YTD | Total sales for the previous year-to-date |

---

### 📈 Calculated Metrics
| Metric | Description | Formula |
|-------|------------|---------|
| 💵 Change Amount | Difference between current and previous YTD sales | `Sales This YTD - Sales Last YTD` |
| 📊 Change Percent | Percentage change between current and previous YTD sales | `(Change Amount * 100) / Sales Last YTD` |

---

### ⚠️ Special Case Handling
| Condition | Behavior |
|----------|----------|
| 🚫 Sales Last YTD = 0 | Change Percent is set to `999.99` to avoid division by zero |
---
## 🧰 Tech Stack

- Enterprise COBOL 6.4 (Semantic Markup)
- IBM z/OS mainframe for development and compiling
- ZOWE Explorer Studio Code extension

### 🧩 Core Concepts
- Report generation with standard alignments
- Reading data in from another mainframe member
- Proper setup of Environment and Data divisions for reading in data from other members

### 🛠 Development Tools
- Marist z/OS Mainframe environment
- Visual Studio Code with ZOWE Explorer extension

---
## How It Works

1. Upload the repository's associated .cbl, .jcl and CUSTMAST data members to your mainframe environment
2. Modify the JCL username on line 1 and the DSN names to match the filepaths for where the members are in your environment
3. Sumbit the JCL job for processing

---

## 🧠 Topics Covered



---

## 📘 What I Learned



---

## 🖼 Screenshots

### 🖼 Final Report
![rpt-6000](assets/report.png)


⬆️ [Back to Top](#-smartwatch-faq)
