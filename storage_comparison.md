# Week 7 Task 1: Storage Method Comparison

## Different Ways to Store Data in Mobile Apps

I looked at four main storage methods that we can use in mobile apps. Here is what I found:

### Shared Preferences
**What it is:** Stores small pieces of data like settings or user preferences.

**Good things:**
- Really easy to use - just a few lines of code
- Fast - no waiting around
- Lightweight - doesn't slow down the app

**Not so good:**
- Can only store simple things like text, numbers, true/false
- Not safe for passwords or personal info
- Can't search or query data

**When to use:** User settings, theme preferences, login status

### SQLite Database
**What it is:** A proper database that sits on the phone.

**Good things:**
- Full database - can do complex queries
- Works without internet
- Fast even with lots of data
- Keeps data safe and consistent

**Not so good:**
- You have to design tables first
- Need to write SQL queries
- No automatic cloud backup

**When to use:** Student records, inventory, anything with structured data

### Firebase (Cloud)
**What it is:** Google's cloud database.

**Good things:**
- Syncs across devices automatically
- Has built-in login system
- Grows with your app

**Not so good:**
- Need internet to sync
- Costs money if you have lots of users
- You're locked into Google's system

**When to use:** Chat apps, real-time updates, multi-device apps

### Internal Storage
**What it is:** Storing files on the phone.

**Good things:**
- Very secure - other apps can't see it
- No setup required
- Good for files and images

**Not so good:**
- Can't search through data easily
- You manage everything manually
- Not good for structured data

**When to use:** Saving photos, documents, PDFs, reports

### My Recommendation
For the Student Management App, I chose **SQLite** because:
1. Students might not have internet access on campus
2. It's fast - important when dealing with many students
3. We can do complex queries for reports
4. It's free - no monthly cloud costs
5. Data stays on the phone, which is more private
